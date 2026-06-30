import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import '../utils/location_helper.dart';

class PanicModeService {
  PanicModeService._privateConstructor();
  static final PanicModeService instance = PanicModeService._privateConstructor();

  bool _isPanicMode = false;
  bool get isPanicMode => _isPanicMode;

  set isPanicMode(bool value) {
    _isPanicMode = value;
  }

  // Detect panic password
  bool isPanicPassword(String password) {
    return password == 'me@123';
  }

  // Exit panic mode (reset state)
  void exitPanicMode() {
    _isPanicMode = false;
  }

  // Mock data for Panic Mode
  double get mockTotalBalance => 12450.0;
  double get mockSavingsBalance => 7900.0;
  double get mockInvestments => 18500.0;
  double get mockTotalLoan => 0.0;

  List<Map<String, dynamic>> getMockAccounts() {
    return [
      {
        'account_id': 99887766,
        'account_type': 'savings',
        'balance': 7900.0,
      },
      {
        'account_id': 88776655,
        'account_type': 'current',
        'balance': 4550.0, // 7900 + 4550 = 12450
      }
    ];
  }

  List<Map<String, dynamic>> getMockCards() {
    return [
      {
        'card_id': 12345,
        'card_type': 'debit',
        'card_network': 'RuPay',
        'card_number': '•••• •••• •••• 2345',
        'masked_number': '•••• •••• •••• 2345',
        'card_holder_name': 'Rajesh Kumar',
        'is_active': true,
        'is_frozen': false,
      }
    ];
  }

  List<Map<String, dynamic>> getMockInvestmentsList() {
    return [
      {
        'investment_id': 101,
        'investment_type': 'mutual_fund',
        'asset_name': 'PSB Dynamic Equity Fund',
        'amount': 18500.0,
      }
    ];
  }

  List<Map<String, dynamic>> getMockRecentTransactions() {
    final now = DateTime.now();
    return [
      {
        'counterparty_name': 'Coffee Shop',
        'transaction_type': 'debit',
        'amount': 240.0,
        'payment_method': 'UPI',
        'reference_details': 'UPI Ref: 602345',
        'status': 'successful',
        'category': 'merchant',
        'location': 'Mumbai, India',
        'created_at': now.subtract(const Duration(minutes: 15)).toUtc().toIso8601String(),
      },
      {
        'counterparty_name': 'Grocery Store',
        'transaction_type': 'debit',
        'amount': 890.0,
        'payment_method': 'Card',
        'reference_details': 'Card: ••2345',
        'status': 'successful',
        'category': 'merchant',
        'location': 'Delhi, India',
        'created_at': now.subtract(const Duration(hours: 2)).toUtc().toIso8601String(),
      },
      {
        'counterparty_name': 'Electricity Bill',
        'transaction_type': 'debit',
        'amount': 1540.0,
        'payment_method': 'UPI',
        'reference_details': 'UPI Ref: 602987',
        'status': 'successful',
        'category': 'merchant',
        'location': 'Bengaluru, India',
        'created_at': now.subtract(const Duration(days: 1)).toUtc().toIso8601String(),
      },
    ];
  }

  // Silently trigger and log the security event to the backend
  Future<void> triggerPanicEvent(String cusId) async {
    try {
      final supabase = Supabase.instance.client;

      // Fetch location if available
      final locResult = await LocationHelper.getMandatoryLocation().catchError((e) {
        return LocationResult(isSuccess: false, error: e.toString());
      });

      String publicIp = 'unknown';
      try {
        final res = await http.get(Uri.parse('https://api.ipify.org')).timeout(const Duration(seconds: 2));
        if (res.statusCode == 200) {
          publicIp = res.body.trim();
        }
      } catch (_) {}

      // Call the supabase RPC or insert directly into location_history as a PANIC event
      // Note: We need to write this to security_events or location_history
      // Let's insert to location_history with activity_type = 'PANIC_MODE_TRIGGERED'
      await supabase.rpc('log_login_location', params: {
        'p_cus_id': cusId,
        'p_lat': locResult.position?.latitude ?? 0.0,
        'p_lng': locResult.position?.longitude ?? 0.0,
        'p_city': locResult.city ?? 'Unknown',
        'p_state': locResult.state ?? 'Unknown',
        'p_country': locResult.country ?? 'Unknown',
        'p_device_info': '${Platform.operatingSystem} ${Platform.operatingSystemVersion} (PANIC_MODE_TRIGGERED)',
        'p_ip_address': publicIp,
      });

      // Also let's try to write to security_events if possible, but location_history with PANIC_MODE_TRIGGERED device_info is extremely reliable.
      debugPrint('[PanicModeService] Security event logged silently.');
    } catch (e) {
      debugPrint('[PanicModeService] Silent logging error (bypassed): $e');
    }
  }

  // Mock response for AI Chat queries during Panic Mode
  String getMockAIChatReply(String message) {
    final query = message.toLowerCase();

    if (query.contains('balance')) {
      return 'Your current balance is ₹12,450.';
    }
    if (query.contains('savings')) {
      return 'Your savings account balance is ₹7,900.';
    }
    if (query.contains('invest') || query.contains('portfolio')) {
      return 'Your total investments are ₹18,500.';
    }
    if (query.contains('transaction') || query.contains('spend') || query.contains('recent')) {
      return 'Your recent transactions are:\n- Coffee Shop: ₹240\n- Grocery: ₹890\n- Electricity Bill: ₹1,540.';
    }
    if (query.contains('loan') || query.contains('debt')) {
      return 'You currently do not have any active loans.';
    }
    if (query.contains('help') || query.contains('hello') || query.contains('hi')) {
      return 'Hello, I am SAGE. How can I assist you with your accounts or portfolio today?';
    }

    return 'Your total balance across accounts is ₹12,450. Your savings balance is ₹7,900, and your total investment value is ₹18,500. Is there anything else I can help you analyze?';
  }
}
