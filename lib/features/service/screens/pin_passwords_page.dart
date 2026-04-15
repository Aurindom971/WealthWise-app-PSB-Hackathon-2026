import 'package:flutter/material.dart';
import 'package:securewealth_twin/features/home/widgets/home_navigation_widgets.dart';
import 'package:securewealth_twin/features/service/screens/change_atm_pin_page.dart';
import 'package:securewealth_twin/features/service/screens/change_password_page.dart';
import '../../loans/widgets/loan_header.dart';
import '../../home/screens/notifications_screen.dart';

class PinPasswordsPage extends StatelessWidget {
  const PinPasswordsPage({super.key});

  void _navigateToUnderConstruction(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: kCream,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
                  subtitle: title,
                  icon: Icons.construction_rounded,
                  onBack: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.construction_rounded,
                              size: 60, color: kMid),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Feature Under Construction',
                          style: TextStyle(
                            color: kForest,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'We are working hard to bring this to you!',
                          style: TextStyle(color: kSub, fontSize: 14),
                        ),
                      ],
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
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, String title, IconData icon,
      {Widget? target, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap();
        } else if (target != null) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => target));
        } else {
          _navigateToUnderConstruction(context, title);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
              child: Icon(icon, color: kForest, size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: kForest,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: kSub, size: 24),
          ],
        ),
      ),
    );
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
              subtitle: "Pin & Passwords",
              icon: Icons.lock_person_outlined,
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildTile(context, 'Change ATM PIN', Icons.vpn_key_outlined,
                      target: const ChangeAtmPinPage()),
                  _buildTile(context, 'Change login password',
                      Icons.lock_outline_rounded,
                      target: const ChangePasswordPage()),
                  _buildTile(
                    context,
                    'Reset transaction password',
                    Icons.sync_rounded,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24)),
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: kAccent.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.mail_outline_rounded,
                                      color: kForest, size: 40),
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'Email Sent!',
                                  style: TextStyle(
                                    color: kForest,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'We have emailed you the information about the steps to change your transaction password.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: kSub,
                                    fontSize: 15,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    decoration: BoxDecoration(
                                      color: kMid,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Done',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
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
}
