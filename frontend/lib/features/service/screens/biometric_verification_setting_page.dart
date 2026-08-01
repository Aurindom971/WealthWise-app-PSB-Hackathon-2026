import 'package:flutter/material.dart';
import '../../../core/services/biometric_service.dart';
import '../../home/screens/notifications_screen.dart';
import '../../home/widgets/home_navigation_widgets.dart';
import '../../loans/widgets/loan_header.dart';

class BiometricVerificationSettingPage extends StatefulWidget {
  const BiometricVerificationSettingPage({super.key});

  @override
  State<BiometricVerificationSettingPage> createState() =>
      _BiometricVerificationSettingPageState();
}

class _BiometricVerificationSettingPageState
    extends State<BiometricVerificationSettingPage> {
  bool _isLoading = true;
  bool _hasFingerprint = false;
  bool _isEnabled = true;

  @override
  void initState() {
    super.initState();
    _checkBiometricStatus();
  }

  Future<void> _checkBiometricStatus() async {
    final hasFingerprint =
        await BiometricService.instance.hasEnrolledFingerprint();
    final isEnabled =
        await BiometricService.instance.isBiometricPaymentEnabled();

    if (mounted) {
      setState(() {
        _hasFingerprint = hasFingerprint;
        _isEnabled = isEnabled;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    setState(() {
      _isEnabled = value;
    });
    await BiometricService.instance.setBiometricPaymentEnabled(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: TopBar(
                onHomeTap: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                onLogoutTap: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                onNotificationTap: () => showNotifications(context),
              ),
            ),
            LoanHeader(
              title: "",
              subtitle: "Biometric Verification",
              icon: Icons.fingerprint_rounded,
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: kForest),
                    )
                  : !_hasFingerprint
                      ? _buildNoFingerprintView()
                      : _buildBiometricSettingsView(),
            ),
            BottomNav(
              currentIndex: -1,
              onTap: (i) =>
                  Navigator.popUntil(context, (route) => route.isFirst),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoFingerprintView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fingerprint_rounded,
                size: 64,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "No fingerprint found on your device",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kForest,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Please register a fingerprint in your device security settings to enable biometric authentication for payments above ₹20,000.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: kSub,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBiometricSettingsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.fingerprint_rounded,
                    color: kForest,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Biometric Payment Lock",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: kForest,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Require fingerprint for transactions over ₹20,000",
                        style: TextStyle(
                          fontSize: 12,
                          color: kSub,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isEnabled,
                  activeColor: kForest,
                  onChanged: _toggleBiometric,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kAccent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: kForest.withOpacity(0.15),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.shield_outlined, color: kForest, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "About Biometric Verification",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: kForest,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  "• Payments exceeding ₹20,000 will require device fingerprint verification after entering your 4-digit PIN.\n\n"
                  "• This extra layer of security ensures your high-value transfers remain protected even if your PIN is compromised.\n\n"
                  "• You can toggle this feature on or off at any time.",
                  style: TextStyle(
                    fontSize: 13,
                    color: kForest,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
