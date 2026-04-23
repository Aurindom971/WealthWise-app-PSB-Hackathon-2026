import 'package:flutter/material.dart';
import 'package:securewealth_twin/features/home/widgets/home_navigation_widgets.dart';
import '../../loans/widgets/loan_header.dart';
import '../../home/screens/notifications_screen.dart';

class AccountDetailsPage extends StatelessWidget {
  const AccountDetailsPage({super.key});

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
              subtitle: "Account Details",
              icon: Icons.description_outlined,
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Container(
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
                    children: [
                      _buildRow('Account Holder', 'Rajesh Kumar'),
                      _buildDivider(),
                      _buildRow('Account Number', '0012345678901234'),
                      _buildDivider(),
                      _buildRow('Account Type', 'Savings Account'),
                      _buildDivider(),
                      _buildRow('Branch', 'Connaught Place, New Delhi'),
                      _buildDivider(),
                      _buildRow('IFSC Code', 'PSIB0000001'),
                      _buildDivider(),
                      _buildRow('MICR Code', '110023002'),
                      _buildDivider(),
                      _buildRow('Opening Date', '15 March 2019'),
                      _buildDivider(),
                      _buildRow('Nomination', 'Registered'),
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

  Widget _buildRow(String label, String value, {bool isBoldValue = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: kSub,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: kForest,
              fontSize: 14,
              fontWeight: isBoldValue ? FontWeight.w800 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: kSub.withOpacity(0.1),
      indent: 16,
      endIndent: 16,
    );
  }
}

