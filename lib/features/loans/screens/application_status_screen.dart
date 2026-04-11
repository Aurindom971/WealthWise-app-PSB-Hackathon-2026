import 'package:flutter/material.dart';
import '../../home/widgets/home_navigation_widgets.dart';
import 'loan_statement_screen.dart';

class ApplicationStatusScreen extends StatelessWidget {
  final String loanType;
  final String loanId;

  const ApplicationStatusScreen({
    super.key,
    required this.loanType,
    required this.loanId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
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
            BottomNav(
              currentIndex: -1,
              onTap: (i) => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
      decoration: const BoxDecoration(
        color: kMid,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.analytics_outlined, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loanType,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    loanId,
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrackerCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
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
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: Colors.grey.withOpacity(0.1),
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LoanStatementScreen(
                loanType: loanType,
                loanId: loanId,
              ),
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: kSub.withOpacity(0.2)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'View Loan Details',
              style: TextStyle(color: kMid, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: kMid.withOpacity(0.8)),
          ],
        ),
      ),
    );
  }
}
