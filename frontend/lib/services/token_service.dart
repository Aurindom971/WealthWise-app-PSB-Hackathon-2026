import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  static final TokenService instance = TokenService._internal();
  final _secureStorage = const FlutterSecureStorage();
  
  static const _keyToken = 'aquarium_session_token';
  static const _keyUser = 'aquarium_user_data';

  TokenService._internal();

  /// Saves the RAW session token securely.
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _keyToken, value: token);
  }

  /// Retrieves the stored RAW session token.
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _keyToken);
  }

  /// Saves user metadata securely.
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _secureStorage.write(key: _keyUser, value: jsonEncode(userData));
  }

  /// Retrieves stored user metadata.
  Future<Map<String, dynamic>?> getUserData() async {
    final data = await _secureStorage.read(key: _keyUser);
    if (data != null && data.isNotEmpty) {
      try {
        return jsonDecode(data) as Map<String, dynamic>;
      } catch (_) {}
    }
    return null;
  }

  /// Deletes stored session token and user data.
  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _keyToken);
    await _secureStorage.delete(key: _keyUser);
  }

  /// Checks if a session token is securely stored.
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
