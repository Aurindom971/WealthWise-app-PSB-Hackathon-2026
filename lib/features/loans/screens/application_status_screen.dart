import 'package:flutter/material.dart';
import '../../home/widgets/home_navigation_widgets.dart';
import '../../home/screens/home_screen.dart';
import '../widgets/loan_header.dart';

class ApplicationStatusScreen extends StatelessWidget {
  final String loanType;
  final String loanId;
  final VoidCallback onBack;

  const ApplicationStatusScreen({
    super.key,
    required this.loanType,
    required this.loanId,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LoanHeader(
          title: 'Application Status',
          subtitle: loanType,
          icon: Icons.analytics_outlined,
          onBack: onBack,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Track Your Application',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kInk),
                ),
                const SizedBox(height: 16),
                _buildTrackerCard(),
                const SizedBox(height: 32),
                _buildBottomButton(context),
              ],
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildTrackerCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Loan Status Tracker', style: TextStyle(color: kInk, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          _buildStatusItem(
            title: 'Application',
            status: 'Completed',
            color: const Color(0xFF3BB77E),
            icon: Icons.description_outlined,
            isFirst: true,
          ),
          _buildStatusItem(
            title: 'Verification',
            status: 'Completed',
            color: const Color(0xFF3BB77E),
            icon: Icons.fact_check_outlined,
          ),
          _buildStatusItem(
            title: 'Approval',
            status: 'In Progress',
            color: kInk,
            icon: Icons.visibility_outlined,
          ),
          _buildStatusItem(
            title: 'Disbursement',
            status: 'Pending',
            color: kSub,
            icon: Icons.attach_money_rounded,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem({
    required String title,
    required String status,
    required Color color,
    required IconData icon,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: Colors.grey.withValues(alpha: 0.1),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kInk),
              ),
              const SizedBox(height: 4),
              Text(
                status,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onBack,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: kSub.withValues(alpha: 0.2)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.arrow_back_ios_rounded, size: 14, color: kMid.withOpacity(0.8)),
            const SizedBox(width: 8),
            const Text(
              'Back to Dashboard',
              style: TextStyle(color: kMid, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
