import 'package:flutter/material.dart';
import '../../home/widgets/home_navigation_widgets.dart';
import '../../loans/widgets/loan_header.dart';

class TrackClaimsScreen extends StatelessWidget {
  const TrackClaimsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> claims = [
      {
        'id': 'CLM-2024-001',
        'type': 'Health Insurance',
        'date': 'Mar 15, 2026',
        'amount': '₹25,000',
        'status': 'Under Review',
        'statusColor': const Color(0xFFD68E24),
        'statusBg': const Color(0xFFFFF0E0),
      },
      {
        'id': 'CLM-2024-002',
        'type': 'Vehicle Insurance',
        'date': 'Feb 28, 2026',
        'amount': '₹1,20,000',
        'status': 'Approved',
        'statusColor': const Color(0xFF139757),
        'statusBg': const Color(0xFFF0F9F5),
      },
      {
        'id': 'CLM-2024-003',
        'type': 'Travel Insurance',
        'date': 'Jan 10, 2026',
        'amount': '₹8,500',
        'status': 'Processing',
        'statusColor': const Color(0xFF537DE8),
        'statusBg': const Color(0xFFF0F4FF),
      },
    ];

    return Scaffold(
      backgroundColor: kCream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: TopBar(
                onHomeTap: () => Navigator.popUntil(context, (route) => route.isFirst),
                onLogoutTap: () => Navigator.popUntil(context, (route) => route.isFirst),
              ),
            ),
            LoanHeader(
              title: 'Claims Tracking',
              subtitle: 'Monitor your active status',
              icon: Icons.history_rounded,
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(18),
                itemCount: claims.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final claim = claims[index];
                  return _buildClaimCard(claim);
                },
              ),
            ),
            BottomNav(
              currentIndex: -1,
              onTap: (i) => Navigator.popUntil(context, (route) => route.isFirst),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClaimCard(Map<String, dynamic> claim) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                claim['id'],
                style: const TextStyle(color: kSub, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: claim['statusBg'],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  claim['status'],
                  style: TextStyle(
                    color: claim['statusColor'],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            claim['type'],
            style: const TextStyle(
              color: kInk,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                claim['date'],
                style: const TextStyle(color: kSub, fontSize: 14),
              ),
              Text(
                claim['amount'],
                style: const TextStyle(
                  color: kInk,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
