import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'otp_security_service.dart';

class SecurityService {
  SecurityService._privateConstructor();
  static final SecurityService instance = SecurityService._privateConstructor();

  // --- LOGIN ATTEMPT LIMITS ---
  static const int maxAttempts = 3;
  static const Duration lockoutDuration = Duration(minutes: 5);

  // Track attempts: Map<cusId, (count, lastAttemptTime)>
  Map<String, (int, DateTime)> _attempts = {};

  // For persistence
  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/security_attempts.json');
  }

  Future<void> _loadAttempts() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final content = await file.readAsString();
        final Map<String, dynamic> jsonMap = json.decode(content);
        _attempts = jsonMap.map((key, value) {
          final parts = value as Map<String, dynamic>;
          return MapEntry(key, (
            parts['count'] as int,
            DateTime.parse(parts['time'] as String),
          ));
        });
        debugPrint(
          "[Security] Loaded ${_attempts.length} attempt records from storage.",
        );
      }
    } catch (e) {
      debugPrint("[Security] Error loading attempts: $e");
    }
  }

  Future<void> _saveAttempts() async {
    try {
      final file = await _localFile;
      final jsonMap = _attempts.map((key, value) {
        return MapEntry(key, {
          'count': value.$1,
          'time': value.$2.toIso8601String(),
        });
      });
      await file.writeAsString(json.encode(jsonMap));
    } catch (e) {
      debugPrint("[Security] Error saving attempts: $e");
    }
  }

  String? checkLockout(String cusId) {
    if (!_attempts.containsKey(cusId)) return null;

    final (count, lastTime) = _attempts[cusId]!;
    debugPrint(
      "[Security] Checking lockout for $cusId: count=$count, lastTime=$lastTime",
    );

    if (count < maxAttempts) return null;

    final diff = DateTime.now().difference(lastTime);
    if (diff >= lockoutDuration) {
      debugPrint("[Security] Lockout expired for $cusId. Resetting.");
      _attempts.remove(cusId);
      _saveAttempts();
      return null;
    }

    final remaining = lockoutDuration.inMinutes - diff.inMinutes;
    return "Too many failed attempts. Please try again in ${remaining > 0 ? remaining : 1} minute(s).";
  }

  void recordFailedAttempt(String cusId) {
    final now = DateTime.now();
    if (_attempts.containsKey(cusId)) {
      final (count, _) = _attempts[cusId]!;
      _attempts[cusId] = (count + 1, now);
    } else {
      _attempts[cusId] = (1, now);
    }
    debugPrint(
      "[Security] Recorded failure for $cusId. Total attempts: ${_attempts[cusId]!.$1}",
    );
    _saveAttempts();
    OtpSecurityService.instance.recordFailedAttempt();
  }

  void resetAttempts(String cusId) {
    if (_attempts.containsKey(cusId)) {
      debugPrint("[Security] Resetting attempts for $cusId after success.");
      _attempts.remove(cusId);
      _saveAttempts();
    }
  }

  // --- SESSION INACTIVITY TIMEOUT ---
  static const Duration inactivityLimit = Duration(minutes: 2);
  static const Duration warningDuration = Duration(seconds: 30);
  
  Timer? _inactivityTimer;
  bool _isWarningShowing = false;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<void> initialize() async {
    await _loadAttempts();
    debugPrint("[Security] Service Initialized.");
  }

  void resetInactivityTimer() {
    _inactivityTimer?.cancel();

    // If warning is showing, dismiss it
    if (_isWarningShowing) {
      _isWarningShowing = false;
      final context = navigatorKey.currentContext;
      if (context != null) {
        // Pop the dialog
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    // Only start timer if user is logged in
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      // Phase 1: Wait for (Limit - Warning) = 1m 30s
      const phase1 = Duration(seconds: 90);
      _inactivityTimer = Timer(phase1, _showInactivityWarning);
    }
  }

  void _showInactivityWarning() {
    final context = navigatorKey.currentContext;
    if (context == null) {
      _handleTimeout();
      return;
    }

    _isWarningShowing = true;
    int secondsLeft = warningDuration.inSeconds;
    Timer? countdownTimer;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Initialize periodic timer for countdown
            countdownTimer ??= Timer.periodic(const Duration(seconds: 1), (timer) {
              if (secondsLeft > 0) {
                if (context.mounted) {
                  setState(() => secondsLeft--);
                }
              } else {
                timer.cancel();
                if (_isWarningShowing) {
                  // Final Timeout
                  Navigator.of(context, rootNavigator: true).pop();
                  _handleTimeout();
                }
              }
            });

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Row(
                children: [
                  Icon(Icons.timer_outlined, color: Colors.orange.shade700, size: 28),
                  const SizedBox(width: 12),
                  const Text("Session Timeout", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Your session will expire in $secondsLeft seconds due to inactivity.",
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
                  ),
                  const SizedBox(height: 24),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 80,
                        width: 80,
                        child: CircularProgressIndicator(
                          value: secondsLeft / warningDuration.inSeconds,
                          strokeWidth: 8,
                          backgroundColor: Colors.grey.shade100,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            secondsLeft > 10 ? const Color(0xFF2E7D5B) : Colors.red,
                          ),
                        ),
                      ),
                      Text(
                        "$secondsLeft",
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // This will trigger resetInactivityTimer which pops the dialog
                    resetInactivityTimer();
                  },
                  child: const Text("Stay Signed In", style: TextStyle(color: Color(0xFF2E7D5B), fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      countdownTimer?.cancel();
      _isWarningShowing = false;
    });
  }

  Future<void> _handleTimeout() async {
    debugPrint("[Security] Inactivity timeout reached. Triggering Logout.");

    try {
      await OtpSecurityService.instance.recordLogout();
      await Supabase.instance.client.auth.signOut();

      final context = navigatorKey.currentContext;
      if (context != null) {
        debugPrint("[Security] Navigating to Login Screen...");
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("SECURITY: Session expired due to inactivity."),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        debugPrint(
          "[Security] CRITICAL: navigatorKey context is null. Reverting to basic navigation fallback.",
        );
      }
    } catch (e) {
      debugPrint("[Security] Logout Error: $e");
    }
  }

  void stopInactivityTimer() {
    _inactivityTimer?.cancel();
  }
}
