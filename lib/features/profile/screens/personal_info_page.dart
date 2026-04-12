import 'package:flutter/material.dart';
import 'package:securewealth_twin/features/home/widgets/home_navigation_widgets.dart';

class PersonalInfoPage extends StatelessWidget {
  const PersonalInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: kForest),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: kForest,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: kForest),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.power_settings_new_rounded, color: kForest),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: kSub.withOpacity(0.1), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Header Section
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: kAccent.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_outline_rounded, color: kForest, size: 48),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'John Doe',
                    style: TextStyle(
                      color: kForest,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Customer ID: CUST00123456',
                    style: TextStyle(
                      color: kSub,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Information Card
            Container(
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
                  _buildInfoRow(Icons.person_outline_rounded, 'Full Name', 'John Doe'),
                  _buildDivider(),
                  _buildInfoRow(Icons.calendar_today_outlined, 'Date of Birth', '15 March 1990'),
                  _buildDivider(),
                  _buildInfoRow(Icons.phone_outlined, 'Phone Number', '+91 98765 43210'),
                  _buildDivider(),
                  _buildInfoRow(Icons.email_outlined, 'Email', 'johndoe@email.com'),
                  _buildDivider(),
                  _buildInfoRow(Icons.location_on_outlined, 'Address', '42, MG Road, New Delhi, 110001'),
                  _buildDivider(),
                  _buildInfoRow(Icons.credit_card_outlined, 'PAN', 'ABCDE1234F'),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: kForest, size: 22),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: kSub,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: kForest,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: kSub.withOpacity(0.1));
  }
}
