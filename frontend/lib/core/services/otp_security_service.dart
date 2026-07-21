import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class OtpSecurityService {
  OtpSecurityService._privateConstructor();
  static final OtpSecurityService instance = OtpSecurityService._privateConstructor();

  Future<File> get _configFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/otp_security_state.json');
  }

  Future<Map<String, dynamic>> _readState() async {
    try {
      final file = await _configFile;
      if (await file.exists()) {
        final content = await file.readAsString();
        return json.decode(content) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('[OtpSecurityService] Error reading state: $e');
    }
    return {};
  }

  Future<void> _writeState(Map<String, dynamic> state) async {
    try {
      final file = await _configFile;
      await file.writeAsString(json.encode(state));
    } catch (e) {
      debugPrint('[OtpSecurityService] Error writing state: $e');
    }
  }

  /// Record user logout time to enforce the 5-minute grace period
  Future<void> recordLogout() async {
    final state = await _readState();
    state['last_logout_timestamp'] = DateTime.now().toIso8601String();
    await _writeState(state);
    debugPrint('[OtpSecurityService] Recorded logout timestamp: ${state['last_logout_timestamp']}');
  }

  /// Record password change to require OTP once on next login
  Future<void> recordPasswordChanged() async {
    final state = await _readState();
    state['password_changed_pending_otp'] = true;
    await _writeState(state);
    debugPrint('[OtpSecurityService] Recorded password change pending OTP.');
  }

  /// Record failed login attempt (wrong password entered)
  Future<void> recordFailedAttempt() async {
    final state = await _readState();
    state['failed_attempt_pending_otp'] = true;
    await _writeState(state);
    debugPrint('[OtpSecurityService] Recorded failed login attempt pending OTP.');
  }

  /// Check if the user is within the 5-minute logout grace period
  Future<bool> isWithinLogoutGracePeriod() async {
    final state = await _readState();
    final logoutStr = state['last_logout_timestamp'] as String?;
    if (logoutStr == null) return false;

    final logoutTime = DateTime.tryParse(logoutStr);
    if (logoutTime == null) return false;

    final diff = DateTime.now().difference(logoutTime);
    return diff < const Duration(minutes: 5);
  }

  /// Evaluate whether an OTP is required based on specified conditions
  Future<bool> shouldRequireOtp({
    required String currentDeviceId,
    required String currentIp,
    required String currentSimId,
    required int currentFingerprintCount,
  }) async {
    final state = await _readState();

    final bool passwordChangedPending = state['password_changed_pending_otp'] == true;
    final bool failedAttemptPending = state['failed_attempt_pending_otp'] == true;

    // Condition 1: Failed attempt recorded earlier
    if (failedAttemptPending) {
      debugPrint('[OtpSecurityService] Triggering OTP due to previous failed login attempt.');
      return true;
    }

    // Condition 2: Password changed
    if (passwordChangedPending) {
      debugPrint('[OtpSecurityService] Triggering OTP due to recent password change.');
      return true;
    }

    // Condition 3: Not verified in the last 15 days
    final lastVerifiedStr = state['last_verified_timestamp'] as String?;
    if (lastVerifiedStr == null) {
      debugPrint('[OtpSecurityService] Triggering OTP: First time verification.');
      return true;
    }
    final lastVerifiedTime = DateTime.tryParse(lastVerifiedStr);
    if (lastVerifiedTime == null || DateTime.now().difference(lastVerifiedTime) > const Duration(days: 15)) {
      debugPrint('[OtpSecurityService] Triggering OTP: Over 15 days since last verification.');
      return true;
    }

    // Condition 4: New device detected
    final lastDeviceId = state['last_device_id'] as String?;
    if (lastDeviceId != null && lastDeviceId != currentDeviceId) {
      debugPrint('[OtpSecurityService] Triggering OTP: New device detected.');
      return true;
    }

    // Condition 5: New network connection (IP) detected
    final lastIp = state['last_network_ip'] as String?;
    if (lastIp != null && lastIp != currentIp) {
      debugPrint('[OtpSecurityService] Triggering OTP: New network IP detected.');
      return true;
    }

    // Condition 6: New SIM card detected
    final lastSimId = state['last_sim_id'] as String?;
    if (lastSimId != null && lastSimId != currentSimId) {
      debugPrint('[OtpSecurityService] Triggering OTP: New SIM card detected.');
      return true;
    }

    // Condition 7: New fingerprint added on device
    final lastFpCount = state['last_fingerprint_count'] as int?;
    if (lastFpCount != null && lastFpCount != currentFingerprintCount) {
      debugPrint('[OtpSecurityService] Triggering OTP: New fingerprint detected on device.');
      return true;
    }

    // Grace Period Check: Only applied if NO other OTP trigger condition above was true.
    final bool inGracePeriod = await isWithinLogoutGracePeriod();
    if (inGracePeriod) {
      debugPrint('[OtpSecurityService] Skipping OTP due to 5-minute logout grace period.');
      return false;
    }

    return false;
  }

  /// Record successful OTP verification and update baseline security markers
  Future<void> recordOtpVerifiedSuccess({
    required String currentDeviceId,
    required String currentIp,
    required String currentSimId,
    required int currentFingerprintCount,
  }) async {
    final state = await _readState();
    state['last_verified_timestamp'] = DateTime.now().toIso8601String();
    state['last_device_id'] = currentDeviceId;
    state['last_network_ip'] = currentIp;
    state['last_sim_id'] = currentSimId;
    state['last_fingerprint_count'] = currentFingerprintCount;
    state['password_changed_pending_otp'] = false; // OTP asked only once after password change
    state['failed_attempt_pending_otp'] = false;
    await _writeState(state);
    debugPrint('[OtpSecurityService] OTP Verified successfully. Security baseline updated.');
  }
}
