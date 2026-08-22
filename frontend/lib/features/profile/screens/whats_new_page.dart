import 'package:flutter/material.dart';
import 'package:wealthwise/features/home/widgets/home_navigation_widgets.dart';
import '../../loans/widgets/loan_header.dart';
import '../../home/screens/notifications_screen.dart';

class WhatsNewPage extends StatelessWidget {
  const WhatsNewPage({super.key});

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
              subtitle: "What's New",
              icon: Icons.new_releases_outlined,
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  const Text(
                    'App version: 29.8.7 • Latest updates',
                    style: TextStyle(
                      color: kSub,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildUpdateCard(
                    Icons.shield_outlined,
                    'Added WealthWise AI',
                    'AI-powered financial insights and fraud detection',
                  ),
                  _buildUpdateCard(
                    Icons.dashboard_customize_outlined,
                    'Updated UI',
                    'Refreshed design with improved navigation and accessibility',
                  ),
                  _buildUpdateCard(
                    Icons.lock_outline_rounded,
                    'Added Smart Lock',
                    'Biometric and device-based security for your accounts',
                  ),
                  _buildUpdateCard(
                    Icons.analytics_outlined,
                    'Added Investments Tab',
                    'Track and manage your investments from the bottom bar',
                  ),
                  _buildUpdateCard(
                    Icons.bug_report_outlined,
                    'Fixed Bugs',
                    'Resolved known issues for a smoother experience',
                  ),
                  _buildUpdateCard(
                    Icons.security_outlined,
                    'Security Update',
                    'Enhanced encryption and session management',
                  ),
                  const SizedBox(height: 20),
                ],
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

  Widget _buildUpdateCard(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: kForest, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
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
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: kSub,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.check_circle_outline_rounded,
            color: kForest,
            size: 20,
          ),
        ],
      ),
    );
  }
}

