import 'dart:convert';
import 'package:crypto/crypto.dart';

class SecurityUtil {
  /// Hashes a string using SHA-256.
  static String hashValue(String value) {
    if (value.isEmpty) return "";
    var bytes = utf8.encode(value);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Checks if a string matches a SHA-256 hash pattern (64 hex characters).
  static bool isHash(String value) {
    if (value.length != 64) return false;
    final hashRegex = RegExp(r'^[a-fA-F0-9]{64}$');
    return hashRegex.hasMatch(value);
  }
}
