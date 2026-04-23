import 'package:flutter/material.dart';
import 'package:wealthwise/features/home/widgets/home_navigation_widgets.dart';
import 'package:wealthwise/features/service/screens/account_services_page.dart';
import 'package:wealthwise/features/service/screens/card_services_page.dart';
import 'package:wealthwise/features/service/screens/manage_deliverables_page.dart';
import 'package:wealthwise/features/service/screens/order_cheque_book_page.dart';
import 'package:wealthwise/features/service/screens/manage_autopay_page.dart';
import 'package:wealthwise/features/service/screens/report_suspicious_activity_page.dart';
import 'package:wealthwise/features/service/screens/pin_passwords_page.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  void _navigateToPlaceholder(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(title, style: const TextStyle(color: kForest)),
            backgroundColor: kCard,
            iconTheme: const IconThemeData(color: kForest),
            elevation: 0,
          ),
          backgroundColor: kCream,
          body: const Center(
            child: Text('Under construction', style: TextStyle(color: kSub)),
          ),
        ),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context,
    String title,
    IconData icon, [
    Widget? target,
  ]) {
    return GestureDetector(
      onTap: () {
        if (target != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => target),
          );
        } else {
          _navigateToPlaceholder(context, title);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
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
                color: kAccent.withOpacity(0.15),
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
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      children: [
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Services',
                  style: TextStyle(
                    color: kForest,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 60,
                  height: 3,
                  decoration: BoxDecoration(
                    color: kForest,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
          ],
        ),
        const SizedBox(height: 24),
        _buildTile(
          context,
          'Order cheque book',
          Icons.menu_book_rounded,
          const OrderChequeBookPage(),
        ),
        _buildTile(
          context,
          'Accounts services',
          Icons.account_balance_outlined,
          const AccountServicesPage(),
        ),
        _buildTile(
          context,
          'Manage autopay',
          Icons.autorenew_rounded,
          const ManageAutopayPage(),
        ),
        _buildTile(
          context,
          'Cards services',
          Icons.credit_card_outlined,
          const CardServicesPage(),
        ),
        _buildTile(
          context,
          'Manage deliverables',
          Icons.inventory_2_outlined,
          const ManageDeliverablesPage(),
        ),
        _buildTile(
          context,
          'Pin and passwords management',
          Icons.vpn_key_outlined,
          const PinPasswordsPage(),
        ),
        _buildTile(
          context,
          'Report suspicious activities',
          Icons.privacy_tip_outlined,
          const ReportSuspiciousActivityPage(),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
