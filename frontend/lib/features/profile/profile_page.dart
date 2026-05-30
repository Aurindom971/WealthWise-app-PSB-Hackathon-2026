import 'package:flutter/material.dart';
import 'package:wealthwise/features/home/widgets/home_navigation_widgets.dart';
import 'package:wealthwise/features/profile/screens/account_details_page.dart';
import 'package:wealthwise/features/profile/screens/feedback_page.dart';
import 'package:wealthwise/features/profile/screens/personal_info_page.dart';
import 'package:wealthwise/features/profile/screens/relationship_manager_page.dart';
import 'package:wealthwise/features/profile/screens/terms_conditions_page.dart';
import 'package:wealthwise/features/profile/screens/whats_new_page.dart';
import 'package:wealthwise/features/profile/screens/your_requests_page.dart';
import 'package:wealthwise/features/profile/screens/personal_fraud_risk_report_page.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback? onServicesTap;
  const ProfilePage({super.key, this.onServicesTap});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _obscureKyc = true;

  void _navigateToPlaceholder(String title) {
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

  Widget _buildTile(String title, IconData icon, [Widget? target]) {
    return GestureDetector(
      onTap: () {
        if (title == 'Services' && widget.onServicesTap != null) {
          widget.onServicesTap!();
        } else if (target != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => target),
          );
        } else {
          _navigateToPlaceholder(title);
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
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: kCard,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: kAccent.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: kForest,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rajesh Kumar',
                      style: TextStyle(
                        color: kForest,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          _obscureKyc ? 'KYC No: XXXXXXXX' : 'KYC No: 12345678',
                          style: const TextStyle(color: kSub, fontSize: 13),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () =>
                              setState(() => _obscureKyc = !_obscureKyc),
                          child: Icon(
                            _obscureKyc
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: kSub,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PersonalInfoPage(),
                        ),
                      ),
                      child: const Text(
                        'View profile',
                        style: TextStyle(
                          color: kMid,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildTile(
          'Relationship manager',
          Icons.people_outline_rounded,
          const RelationshipManagerPage(),
        ),
        _buildTile(
          'Personal Fraud Risk Report',
          Icons.shield_outlined,
          const PersonalFraudRiskReportPage(),
        ),
        _buildTile(
          'Account details',
          Icons.description_outlined,
          const AccountDetailsPage(),
        ),
        _buildTile(
          'Your requests',
          Icons.assignment_outlined,
          const YourRequestsPage(),
        ),
        _buildTile(
          'Feedback',
          Icons.chat_bubble_outline_rounded,
          const FeedbackPage(),
        ),
        _buildTile(
          'Terms and Condition',
          Icons.article_outlined,
          const TermsConditionsPage(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'App version: 29.8.7',
              style: TextStyle(color: kSub.withOpacity(0.8), fontSize: 12),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WhatsNewPage()),
              ),
              child: const Text(
                'What\'s new',
                style: TextStyle(
                  color: kMid,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
