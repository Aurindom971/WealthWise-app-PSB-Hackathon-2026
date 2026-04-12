import 'package:flutter/material.dart';
import '../../home/widgets/home_navigation_widgets.dart';
import '../../loans/widgets/loan_header.dart';

class InsurancePlanData {
  final String title;
  final String price;
  final List<String> features;

  InsurancePlanData({
    required this.title,
    required this.price,
    required this.features,
  });
}

class InsuranceCategoryData {
  final String title;
  final String description;
  final IconData icon;
  final List<InsurancePlanData> plans;

  InsuranceCategoryData({
    required this.title,
    required this.description,
    required this.icon,
    required this.plans,
  });
}

class InsuranceCategoryScreen extends StatelessWidget {
  final InsuranceCategoryData category;

  const InsuranceCategoryScreen({super.key, required this.category});

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
                onHomeTap: () => Navigator.popUntil(context, (route) => route.isFirst),
                onLogoutTap: () => Navigator.popUntil(context, (route) => route.isFirst),
              ),
            ),
            LoanHeader(
              title: 'Insurance category'.toUpperCase(),
              subtitle: category.title,
              icon: category.icon,
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Available Plans',
                      style: TextStyle(
                        color: kInk,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Plans List
                    ...category.plans.map((plan) => _buildPlanCard(plan)).toList(),
                    const SizedBox(height: 32),
                  ],
                ),
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

  Widget _buildPlanCard(InsurancePlanData plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          Text(
            plan.title,
            style: const TextStyle(
              color: kInk,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            plan.price,
            style: const TextStyle(
              color: Color(0xFFD68E24),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ...plan.features.map((feature) => _buildFeatureItem(feature)).toList(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: kMid,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                elevation: 0,
              ),
              child: const Text(
                'Buy Now',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: kMid, size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(color: Color(0xFF333333), fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// Global Category Data
final Map<String, InsuranceCategoryData> insuranceCategoryDataMap = {
  'Health Insurance': InsuranceCategoryData(
    title: 'Health Insurance',
    description: 'Comprehensive medical coverage for you and your family',
    icon: Icons.favorite_outline,
    plans: [
      InsurancePlanData(
        title: 'Basic Health',
        price: '₹299/mo',
        features: ['₹2L coverage', 'OPD cover', 'Annual checkup'],
      ),
      InsurancePlanData(
        title: 'Super Health Plus',
        price: '₹499/mo',
        features: ['₹5L coverage', 'Cashless hospitalization', 'Free checkups'],
      ),
      InsurancePlanData(
        title: 'Premium Health Max',
        price: '₹999/mo',
        features: ['₹10L coverage', 'International cover', 'No co-pay'],
      ),
    ],
  ),
  'Life Insurance': InsuranceCategoryData(
    title: 'Life Insurance',
    description: "Secure your family's future with guaranteed protection",
    icon: Icons.shield_outlined,
    plans: [
      InsurancePlanData(
        title: 'Life Basic',
        price: '₹399/mo',
        features: ['₹25L cover', 'Death benefit', 'Maturity bonus'],
      ),
      InsurancePlanData(
        title: 'Life Shield 1Cr',
        price: '₹849/mo',
        features: ['₹1Cr cover', 'Tax benefits', 'Accidental cover'],
      ),
    ],
  ),
  'Vehicle Insurance': InsuranceCategoryData(
    title: 'Vehicle Insurance',
    description: 'Comprehensive protection for your vehicle',
    icon: Icons.directions_car_outlined,
    plans: [
      InsurancePlanData(
        title: 'Third Party',
        price: '₹199/mo',
        features: ['Legal coverage', 'Third party liability', 'Basic protection'],
      ),
      InsurancePlanData(
        title: 'Comprehensive',
        price: '₹599/mo',
        features: ['Full damage cover', 'Theft protection', 'Roadside assistance'],
      ),
    ],
  ),
  'Term Insurance': InsuranceCategoryData(
    title: 'Term Insurance',
    description: 'Pure life coverage at affordable cost',
    icon: Icons.assignment_outlined,
    plans: [
      InsurancePlanData(
        title: 'Term Basic',
        price: '₹299/mo',
        features: ['₹50L cover', 'Pure protection', 'Low premiums'],
      ),
      InsurancePlanData(
        title: 'Term Plus',
        price: '₹549/mo',
        features: ['₹1Cr cover', 'Critical illness', 'Premium waiver'],
      ),
    ],
  ),
  'Travel Insurance': InsuranceCategoryData(
    title: 'Travel Insurance',
    description: 'Travel worry-free with complete coverage',
    icon: Icons.flight_takeoff_outlined,
    plans: [
      InsurancePlanData(
        title: 'Domestic Guard',
        price: '₹99/trip',
        features: ['Domestic trips', 'Lost baggage', 'Trip delay'],
      ),
      InsurancePlanData(
        title: 'Travel Guard Pro',
        price: '₹299/trip',
        features: ['Worldwide cover', 'Cancellation cover', 'Emergency medical'],
      ),
    ],
  ),
};
