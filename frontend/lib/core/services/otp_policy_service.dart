import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// Manages smart OTP policy for login.
class OtpPolicyService {
  OtpPolicyService._privateConstructor();
  static final OtpPolicyService instance =
      OtpPolicyService._privateConstructor();

  static const Duration _otpExpiry = Duration(days: 15);
  static const Duration _gracePeriod = Duration(minutes: 5);

  Future<File> get _dataFile async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/otp_policy.json');
  }

  Future<Map<String, dynamic>> _load() async {
    try {
      final file = await _dataFile;
      if (await file.exists()) {
        final raw = await file.readAsString();
        return json.decode(raw) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('[OtpPolicy] Load error: $e');
    }
    return {};
  }

  Future<void> _save(Map<String, dynamic> data) async {
    try {
      final file = await _dataFile;
      await file.writeAsString(json.encode(data));
    } catch (e) {
      debugPrint('[OtpPolicy] Save error: $e');
    }
  }

  Future<bool> requiresOtp({
    required String currentIp,
    required String deviceFingerprint,
    required bool hadRecentFailure,
  }) async {
    final data = await _load();

    if (hadRecentFailure) {
      debugPrint('[OtpPolicy] Recent failed attempt detected. OTP required.');
      return true;
    }

    final lastOtpStr = data['last_otp_verified_at'] as String?;
    if (lastOtpStr == null) {
      debugPrint('[OtpPolicy] First login on device. OTP required.');
      return true;
    }

    final lastKnownIp = data['last_known_ip'] as String? ?? 'unknown';
    if (currentIp != 'unknown' &&
        lastKnownIp != 'unknown' &&
        currentIp != lastKnownIp) {
      debugPrint(
        '[OtpPolicy] IP changed ($lastKnownIp -> $currentIp). OTP required.',
      );
      return true;
    }

    final lastOtp = DateTime.tryParse(lastOtpStr);
    if (lastOtp == null) {
      debugPrint('[OtpPolicy] Invalid OTP timestamp. OTP required.');
      return true;
    }
    if (DateTime.now().difference(lastOtp) >= _otpExpiry) {
      debugPrint(
        '[OtpPolicy] OTP expired (>= ${_otpExpiry.inDays} days). OTP required.',
      );
      return true;
    }

    final lastFingerprint = data['device_fingerprint'] as String? ?? '';
    if (lastFingerprint.isNotEmpty && lastFingerprint != deviceFingerprint) {
      debugPrint('[OtpPolicy] Device fingerprint changed. OTP required.');
      return true;
    }

    final lastLogoutStr = data['last_logout_at'] as String?;
    if (lastLogoutStr != null) {
      final lastLogout = DateTime.tryParse(lastLogoutStr);
      if (lastLogout != null) {
        final sinceLogout = DateTime.now().difference(lastLogout);
        if (sinceLogout <= _gracePeriod) {
          debugPrint(
            '[OtpPolicy] Grace period active (${sinceLogout.inSeconds}s since logout). OTP skipped.',
          );
          return false;
        }
      }
    }

    debugPrint('[OtpPolicy] All checks passed. OTP not required.');
    return false;
  }

  Future<void> recordOtpVerified({
    required String ip,
    required String deviceFingerprint,
  }) async {
    final data = await _load();
    data['last_otp_verified_at'] = DateTime.now().toIso8601String();
    data['last_known_ip'] = ip;
    data['device_fingerprint'] = deviceFingerprint;
    data.remove('last_logout_at');
    await _save(data);
    debugPrint('[OtpPolicy] OTP verified. Trust state persisted.');
  }

  Future<void> recordLogout() async {
    final data = await _load();
    data['last_logout_at'] = DateTime.now().toIso8601String();
    await _save(data);
    debugPrint('[OtpPolicy] Logout recorded for grace period calculation.');
  }
}
