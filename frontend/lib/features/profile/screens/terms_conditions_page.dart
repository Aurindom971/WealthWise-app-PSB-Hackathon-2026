import 'package:flutter/material.dart';
import 'package:wealthwise/features/home/widgets/home_navigation_widgets.dart';
import '../../loans/widgets/loan_header.dart';
import '../../home/screens/notifications_screen.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

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
              subtitle: "Terms and Conditions",
              icon: Icons.article_outlined,
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection(
                        '1. Acceptance of Terms',
                        "By accessing and using Punjab & Sind Bank's mobile banking application, you agree to be bound by these Terms and Conditions. If you do not agree, please discontinue use of the application immediately.",
                      ),
                      _buildSection(
                        '2. Account Security',
                        'You are responsible for maintaining the confidentiality of your login credentials, PIN, and OTP. Punjab & Sind Bank shall not be liable for any unauthorized transactions conducted using your credentials.',
                      ),
                      _buildSection(
                        '3. Services Provided',
                        'The application provides services including but not limited to: account balance inquiry, fund transfers, bill payments, cheque book requests, and account statements. Services may be modified or discontinued at any time without prior notice.',
                      ),
                      _buildSection(
                        '4. Transaction Limits',
                        'Daily transaction limits are subject to regulatory guidelines and bank policies. The bank reserves the right to modify these limits at any time. Customers will be notified of any changes through the application or registered communication channels.',
                      ),
                      _buildSection(
                        '5. Privacy Policy',
                        'Your personal and financial information is collected and processed in accordance with our Privacy Policy. We use state-of-the-art encryption to protect your data during transmission and storage.',
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Last updated: October 2023',
                        style: TextStyle(
                          color: kSub,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: kForest,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              color: kInk,
              fontSize: 14,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

