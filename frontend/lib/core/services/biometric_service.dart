import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:path_provider/path_provider.dart';

class BiometricService {
  BiometricService._privateConstructor();
  static final BiometricService instance =
      BiometricService._privateConstructor();

  final LocalAuthentication _auth = LocalAuthentication();

  // File to persist the last successfully logged-in user credentials (for biometrics login)
  Future<File> get _configFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/biometric_config.json');
  }

  /// Store the last successfully logged in Customer ID and Password
  Future<void> saveLastUser(String cusId, String password) async {
    try {
      final file = await _configFile;
      await file.writeAsString(
        json.encode({'last_cus_id': cusId, 'last_password': password}),
      );
      debugPrint('[BiometricService] Saved last user credentials for $cusId');
    } catch (e) {
      debugPrint('[BiometricService] Error saving last user credentials: $e');
    }
  }

  /// Retrieve the last successfully logged in Customer ID and Password
  Future<Map<String, String>?> getLastUserCredentials() async {
    try {
      final file = await _configFile;
      if (await file.exists()) {
        final content = await file.readAsString();
        final data = json.decode(content) as Map<String, dynamic>;
        return {
          'cusId': data['last_cus_id']?.toString() ?? '',
          'password': data['last_password']?.toString() ?? '',
        };
      }
    } catch (e) {
      debugPrint('[BiometricService] Error reading last credentials: $e');
    }
    return null;
  }

  /// Check if fingerprint authentication is available and if fingerprint data is enrolled on the device.
  Future<bool> hasEnrolledFingerprint() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();

      if (!canAuthenticateWithBiometrics || !isDeviceSupported) {
        return false;
      }

      final List<BiometricType> availableBiometrics = await _auth
          .getAvailableBiometrics();
      debugPrint(
        '[BiometricService] Enrolled Biometrics found: $availableBiometrics',
      );

      return availableBiometrics.contains(BiometricType.fingerprint) ||
          availableBiometrics.contains(BiometricType.strong);
    } catch (e) {
      debugPrint('[BiometricService] Error checking enrolled fingerprints: $e');
      return false;
    }
  }

  /// Trigger biometric authentication
  Future<bool> authenticate({String? reason}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason ??
            'Please authenticate using your fingerprint to sign in securely.',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } catch (e) {
      debugPrint('[BiometricService] Biometric authentication error: $e');
      return false;
    }
  }

  /// Get biometric payment toggle state (defaults to true)
  Future<bool> isBiometricPaymentEnabled() async {
    try {
      final file = await _configFile;
      if (await file.exists()) {
        final content = await file.readAsString();
        final data = json.decode(content) as Map<String, dynamic>;
        return data['biometric_payment_enabled'] ?? true;
      }
    } catch (e) {
      debugPrint('[BiometricService] Error reading biometric toggle: $e');
    }
    return true;
  }

  /// Save biometric payment toggle state
  Future<void> setBiometricPaymentEnabled(bool enabled) async {
    try {
      final file = await _configFile;
      Map<String, dynamic> data = {};
      if (await file.exists()) {
        final content = await file.readAsString();
        data = json.decode(content) as Map<String, dynamic>;
      }
      data['biometric_payment_enabled'] = enabled;
      await file.writeAsString(json.encode(data));
    } catch (e) {
      debugPrint('[BiometricService] Error saving biometric toggle: $e');
    }
  }
}
