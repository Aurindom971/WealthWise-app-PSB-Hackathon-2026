import 'package:flutter/material.dart';
import '../../home/widgets/home_navigation_widgets.dart';
import '../../loans/widgets/loan_header.dart';

class AllPlansScreen extends StatelessWidget {
  const AllPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> allPlans = [
      {
        'title': 'Super Health Plus',
        'isPopular': true,
        'price': '₹499',
        'unit': '/month',
        'features': [
          '₹5L coverage for family',
          'Cashless hospitalization',
          'Free health checkups',
        ],
      },
      {
        'title': 'Life Shield 1Cr',
        'isPopular': false,
        'price': '₹849',
        'unit': '/month',
        'features': [
          '₹1 Cr life cover',
          'Tax benefits under 80C',
          'Accidental coverage included',
        ],
      },
      {
        'title': 'Travel Guard Pro',
        'isPopular': false,
        'price': '₹299',
        'unit': '/trip',
        'features': [
          'Worldwide coverage',
          'Trip cancellation protection',
          'Emergency medical assistance',
        ],
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
              title: 'Recommended'.toUpperCase(),
              subtitle: 'All Insurance Plans',
              icon: Icons.list_alt_rounded,
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(18),
                itemCount: allPlans.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final plan = allPlans[index];
                  return _buildAllPlanCard(plan);
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

  Widget _buildAllPlanCard(Map<String, dynamic> plan) {
    return Container(
      padding: const EdgeInsets.all(24),
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
                plan['title'],
                style: const TextStyle(
                  color: kInk,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (plan['isPopular'])
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0E0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Popular',
                    style: TextStyle(
                      color: Color(0xFFD68E24),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                plan['price'],
                style: const TextStyle(
                  color: Color(0xFFD68E24),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                ' ${plan['unit']}',
                style: const TextStyle(
                  color: kSub,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...((plan['features'] as List<String>).map((feature) => _buildAllFeatureItem(feature))),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: kMid,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: const Text(
                'View Details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: kMid, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF333333),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
