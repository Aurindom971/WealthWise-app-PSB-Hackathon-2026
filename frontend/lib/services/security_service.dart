import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../providers/auth_provider.dart';
import 'local_db_service.dart';

class SecurityService {
  static final _supabase = Supabase.instance.client;

  /// Internal cache for settings to avoid over-fetching
  static Map<String, dynamic>? _cachedSettings;
  static DateTime? _lastFetch;

  static Future<Map<String, dynamic>?> getSettings() async {
    try {
      // Use cache for 30 seconds to be responsive but accurate
      if (_cachedSettings != null &&
          _lastFetch != null &&
          DateTime.now().difference(_lastFetch!) < const Duration(seconds: 30)) {
        return _cachedSettings;
      }

      // Fetch from local database instead of Supabase to avoid table missing errors
      final response = await LocalDbService.getSettings('smart_lock');
      
      if (response != null) {
        _cachedSettings = response;
      } else {
        // Defaults if no local settings exist
        _cachedSettings = {
          'night_lock_enabled': false,
          'card_freeze_enabled': false,
          'online_enabled': false,
          'upi_enabled': false,
          'pos_enabled': false,
          'atm_enabled': false,
        };
      }
      
      _lastFetch = DateTime.now();
      return _cachedSettings;
    } catch (e) {
      debugPrint('SecurityService getSettings Error: $e');
      return null;
    }
  }

  static bool isNightLockActive(String? startTime, String? endTime) {
    if (startTime == null || endTime == null) return false;

    try {
      final now = DateTime.now();
      final nowMinutes = now.hour * 60 + now.minute;

      final startParts = startTime.split(':');
      final endParts = endTime.split(':');

      final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
      final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

      if (startMinutes < endMinutes) {
        return nowMinutes >= startMinutes && nowMinutes < endMinutes;
      } else {
        // Overnights (e.g. 23:00 to 06:00)
        return nowMinutes >= startMinutes || nowMinutes < endMinutes;
      }
    } catch (e) {
      debugPrint('isNightLockActive Parse Error: $e');
      return false;
    }
  }

  static Future<bool> canPerformTransaction() async {
    final settings = await getSettings();
    if (settings == null) return true;

    // 1. Global Freeze check
    if (settings['card_freeze_enabled'] == true) return false;

    // 2. Night Lock check
    if (settings['night_lock_enabled'] == true) {
      if (isNightLockActive(settings['night_lock_start'], settings['night_lock_end'])) {
        return false;
      }
    }

    return true;
  }

  /// Returns true if UPI transactions are specifically blocked
  static Future<bool> isUpiLockActive() async {
    if (!await canPerformTransaction()) return true;
    final settings = await getSettings();
    return settings?['upi_enabled'] == true;
  }

  /// Returns true if Online/Bank transfers are specifically blocked
  static Future<bool> isOnlineLockActive() async {
    if (!await canPerformTransaction()) return true;
    final settings = await getSettings();
    return settings?['online_enabled'] == true;
  }

  static Future<void> updateSmartLockSettings(Map<String, dynamic> settings) async {
    try {
      // Save settings LOCALLY
      await LocalDbService.saveSettings('smart_lock', settings);
      
      // Update cache immediately for smooth UI
      _cachedSettings = {
        ...?_cachedSettings,
        ...settings,
      };
      _lastFetch = DateTime.now();
    } catch (e) {
      debugPrint('SecurityService update Error: $e');
    }
  }

  static Future<void> toggleGlobalCardFreeze(bool isFrozen) async {
    try {
      // 1. Update local persistence
      await updateSmartLockSettings({'card_freeze_enabled': isFrozen});

      // 2. Fetch all cards via RPC to bypass direct table access restrictions
      final userEmail = AuthProvider.instance.currentUser?['email'] ?? _supabase.auth.currentUser?.email;
      if (userEmail == null || userEmail.toString().isEmpty) return;

      final cardsResponse = await _supabase.rpc('get_cards_data', params: {
        'user_email': userEmail,
      });

      if (cardsResponse != null && cardsResponse['cards'] != null) {
        final List<dynamic> cards = cardsResponse['cards'];
        
        // 3. Batch toggle each card individually via RPC
        // Doing this sequentially to ensure DB consistency and bypass RLS
        for (final card in cards) {
          final cardId = card['card_id'];
          if (cardId != null) {
            await _supabase.rpc('toggle_freeze_card', params: {
              'p_card_id': cardId,
              'p_freeze_status': isFrozen,
            });
          }
        }
      }
          
      debugPrint('SecurityService: Global card freeze synchronized via RPC ($isFrozen)');
    } catch (e) {
      debugPrint('SecurityService global freeze sync error: $e');
    }
  }

  /// Synchronizes ATM limits across all cards when ATM block is toggled
  static Future<void> syncGlobalAtmLimits(bool block) async {
    try {
      final userEmail = AuthProvider.instance.currentUser?['email'] ?? _supabase.auth.currentUser?.email;
      if (userEmail == null || userEmail.toString().isEmpty) return;

      if (block) {
        // --- PHASE: BLOCKING & BACKUP ---
        // 1. Fetch all cards to get their current settings before zeroing
        final response = await _supabase.rpc('get_cards_data', params: {
          'user_email': userEmail,
        });

        if (response != null && response['cards'] != null) {
          final List<dynamic> cards = response['cards'];
          final Map<String, int> backups = {};

          for (final card in cards) {
            final cardId = card['card_id'];
            if (cardId != null) {
              // Store current limit as backup
              backups[cardId.toString()] = (card['atm_limit'] ?? 25000).toInt();

              // Update to 0
              await _supabase.rpc('update_card_settings', params: {
                'id_card': cardId,
                'is_dom_on': card['domestic_enabled'] ?? true,
                'is_intl_on': card['international_enabled'] ?? false,
                'lim_atm': 0, // THE BLOCK
                'lim_merch': (card['merchant_limit'] ?? 100000).toInt(),
                'lim_tap': (card['contactless_limit'] ?? 5000).toInt(),
                'lim_online': (card['online_limit'] ?? 200000).toInt(),
              });
            }
          }
          // Save backups to local storage
          await updateSmartLockSettings({'atm_backups': backups});
          debugPrint('SecurityService: All card ATM limits backed up and synchronized to 0');
        }
      } else {
        // --- PHASE: UNBLOCKING & RESTORE ---
        // 1. Get backups from settings
        final settings = await getSettings();
        final Map<String, dynamic>? backups = settings?['atm_backups'];

        if (backups == null || backups.isEmpty) {
          debugPrint('SecurityService: No ATM backups found for restoration.');
          return;
        }

        // 2. Fetch all current card states to preserve other settings
        final response = await _supabase.rpc('get_cards_data', params: {
          'user_email': userEmail,
        });

        if (response != null && response['cards'] != null) {
          final List<dynamic> cards = response['cards'];

          for (final card in cards) {
            final cardId = card['card_id'].toString();
            if (backups.containsKey(cardId)) {
              final int originalLimit = backups[cardId] as int;
              
              // Restore previous limit
              await _supabase.rpc('update_card_settings', params: {
                'id_card': card['card_id'],
                'is_dom_on': card['domestic_enabled'] ?? true,
                'is_intl_on': card['international_enabled'] ?? false,
                'lim_atm': originalLimit, // THE RESTORE
                'lim_merch': (card['merchant_limit'] ?? 100000).toInt(),
                'lim_tap': (card['contactless_limit'] ?? 5000).toInt(),
                'lim_online': (card['online_limit'] ?? 200000).toInt(),
              });
            }
          }
          // Clear backups after successful restore
          await updateSmartLockSettings({'atm_backups': null});
          debugPrint('SecurityService: All card ATM limits restored from backups');
        }
      }
    } catch (e) {
      debugPrint('SecurityService ATM sync error: $e');
    }
  }
}
