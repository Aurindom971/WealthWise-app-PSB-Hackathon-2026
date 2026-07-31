import 'package:flutter/material.dart';
import 'package:wealthwise/features/home/widgets/home_navigation_widgets.dart';
import '../screens/kyc_verification_page.dart';

/// Shows an interactive popout dialog asking the user to verify/complete their RBI KYC.
void showKycPromptDialog(BuildContext context, {String actionTitle = 'Add Account / User'}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => AlertDialog(
      backgroundColor: kCream,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kForest.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: kForest,
              size: 40,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'KYC Verification Required',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: kForest,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'To $actionTitle and enable full banking transactions under RBI directives, please complete or update your RBI KYC verification details.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: kSub,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield_outlined, color: Color(0xFF2E7D32), size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Instant C-KYC Sync & Aadhaar e-KYC Verification',
                    style: TextStyle(color: Color(0xFF1B5E20), fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: kSub),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Remind Later',
                    style: TextStyle(color: kSub, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kForest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const KycVerificationPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Verify KYC Now',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
