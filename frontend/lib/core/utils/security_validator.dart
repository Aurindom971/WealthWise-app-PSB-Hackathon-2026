import 'package:flutter/foundation.dart';

class SecurityValidator {
  // --- CONFIGURATION ---
  static const int maxTotalPayloadSize = 50 * 1024; // 50KB
  static const int maxFieldLength = 500; // Default for comments/purposes
  static const int maxNameLength = 100;
  static const int maxIdLength = 20;

  /// Sanitizes a string by trimming, removing control characters, 
  /// and escaping HTML tags to prevent XSS.
  static String sanitize(String input) {
    if (input.isEmpty) return '';
    
    // 1. Trim whitespace
    String result = input.trim();
    
    // 2. Remove non-printable/control characters
    result = result.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
    
    // 3. Simple HTML Escaping (XSS protection)
    result = result
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
        
    return result;
  }

  /// Rejects a payload if it is oversized or contains malformed data.
  static bool inspectPayload(Map<String, dynamic> payload) {
    String payloadStr = payload.toString();
    if (payloadStr.length > maxTotalPayloadSize) {
      debugPrint("[Security] Payload rejected: Total size exceeds ${maxTotalPayloadSize} bytes.");
      return false;
    }
    
    // Additional heuristic checks can be added here
    return true;
  }

  // --- SPECIFIC VALIDATORS ---

  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return emailRegex.hasMatch(email) && email.length <= 100;
  }

  static bool isValidPhone(String phone) {
    // Basic check for digits and length
    final phoneNum = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return phoneNum.length >= 10 && phoneNum.length <= 15;
  }

  static bool isValidAmount(String amount) {
    final amt = double.tryParse(amount.replaceAll(',', ''));
    return amt != null && amt > 0 && amt < 1000000000; // 1 Billion cap
  }

  static bool isValidAccountNumber(String acc) {
    final cleanAcc = acc.replaceAll(RegExp(r'[^0-9]'), '');
    return cleanAcc.length >= 8 && cleanAcc.length <= 20;
  }
  
  static bool isValidPan(String pan) {
    return RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(pan.toUpperCase());
  }
}
