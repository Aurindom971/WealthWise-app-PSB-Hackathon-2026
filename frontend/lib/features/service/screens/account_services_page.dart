import 'package:flutter/material.dart';
import 'package:securewealth_twin/features/home/widgets/home_navigation_widgets.dart';
import 'package:securewealth_twin/features/cards_and_forex/widgets/statement_modal.dart';
import '../../loans/widgets/loan_header.dart';
import '../../home/screens/notifications_screen.dart';
import 'nominee_management_page.dart';
import 'modify_account_details_page.dart';

class AccountServicesPage extends StatelessWidget {
  const AccountServicesPage({super.key});

  void _navigateToPlaceholder(BuildContext context, String title) {
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
                  icon: Icons.info_outline,
                  onBack: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Center(
                    child: Text('Under construction',
                        style: TextStyle(color: kSub)),
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

  Widget _buildTile(BuildContext context, String title, IconData icon) {
    return GestureDetector(
      onTap: () {
        if (title == 'Download statement') {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const StatementModal(),
          );
        } else if (title == 'Nominee management') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NomineeManagementPage(),
            ),
          );
        } else if (title == 'Modify account details') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ModifyAccountDetailsPage(),
            ),
          );
        } else {
          _navigateToPlaceholder(context, title);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
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
              child: Icon(icon, color: kForest, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: kForest,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: kSub, size: 20),
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
              subtitle: "Accounts Services",
              icon: Icons.account_balance_outlined,
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  _buildTile(
                      context, 'Download statement', Icons.file_download_outlined),
                  _buildTile(
                      context, 'Nominee management', Icons.shield_outlined),
                  _buildTile(
                      context, 'Modify account details', Icons.sync_rounded),
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
