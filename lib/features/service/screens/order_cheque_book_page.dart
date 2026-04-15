import 'package:flutter/material.dart';
import 'package:securewealth_twin/features/home/widgets/home_navigation_widgets.dart';
import '../../loans/widgets/loan_header.dart';
import '../../home/screens/notifications_screen.dart';
import 'manage_deliverables_page.dart';

class OrderChequeBookPage extends StatelessWidget {
  const OrderChequeBookPage({super.key});

  void _requestChequeBook(BuildContext context) {
    // Add to static state
    ManageDeliverablesPage.trackedOrders.add({
      'title': 'Cheque Book',
      'status': 'In Progress',
      'date': 'Oct 12, 2023',
    });

    // Show SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chequebook has been ordered'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );

    // Optional: Pop back after a short delay
    Future.delayed(const Duration(seconds: 1), () {
      if (context.mounted) {
        Navigator.pop(context);
      }
    });
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
              subtitle: "Order Cheque Book",
              icon: Icons.book_outlined,
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow('Account', 'XXXX1234 (Savings)'),
                          const SizedBox(height: 20),
                          _buildDetailRow('Leaves', '25 leaves'),
                          const SizedBox(height: 20),
                          _buildDetailRow(
                            'Delivery Address',
                            'Branch Address (Connaught Place)',
                          ),
                          const SizedBox(height: 32),
                          GestureDetector(
                            onTap: () => _requestChequeBook(context),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: kForest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Text(
                                  'Request Cheque Book',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: kSub, fontSize: 14)),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: kForest,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

