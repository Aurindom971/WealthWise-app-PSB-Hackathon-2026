import 'package:flutter/material.dart';
import '../../home/widgets/home_navigation_widgets.dart';
import '../../home/screens/home_screen.dart';
import '../widgets/loan_header.dart';
import '../widgets/active_loan_card.dart';
import 'loan_statement_screen.dart';
import 'application_status_screen.dart';

class ActiveLoansScreen extends StatelessWidget {
  final VoidCallback onBack;
  final Function(String, String) onViewStatement;
  final Function(String, String) onTrackStatus;

  const ActiveLoansScreen({
    super.key, 
    required this.onBack, 
    required this.onViewStatement,
    required this.onTrackStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LoanHeader(
          title: 'Active Loans',
          subtitle: 'Review your status',
          icon: Icons.track_changes_rounded,
          onBack: onBack,
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: kMid.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: kMid.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: kMid, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'You have 3 loans currently active and being tracked.',
                            style: TextStyle(color: kInk.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Loans List
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    children: [
                      ActiveLoanCard(
                        type: 'Personal Loan',
                        loanId: 'PL-2024-00891',
                        principal: '₹5,00,000',
                        outstanding: '₹2,75,000',
                        emi: '₹15,000',
                        nextDue: '5 Apr 2026',
                        paidText: '9 of 20 EMIs paid',
                        progress: 0.45,
                        interestRate: '10.5% p.a.',
                        tenure: '20 months',
                        startDate: 'Jul 2024',
                        onViewStatement: () => onViewStatement('Personal Loan', 'PL-2024-00891'),
                        onTrackStatus: () => onTrackStatus('Personal Loan', 'PL-2024-00891'),
                      ),
                      const SizedBox(height: 16),
                      ActiveLoanCard(
                        type: 'Car Loan',
                        loanId: 'CL-2023-01234',
                        principal: '₹8,00,000',
                        outstanding: '₹5,60,000',
                        emi: '₹18,500',
                        nextDue: '10 Apr 2026',
                        paidText: '18 of 60 EMIs paid',
                        progress: 0.30,
                        interestRate: '9.5% p.a.',
                        tenure: '60 months',
                        startDate: 'Oct 2023',
                        onViewStatement: () => onViewStatement('Car Loan', 'CL-2023-01234'),
                        onTrackStatus: () => onTrackStatus('Car Loan', 'CL-2023-01234'),
                      ),
                      const SizedBox(height: 16),
                      ActiveLoanCard(
                        type: 'Education Loan',
                        loanId: 'EL-2023-00567',
                        principal: '₹3,00,000',
                        outstanding: '₹1,20,000',
                        emi: '₹8,500',
                        nextDue: '15 Apr 2026',
                        paidText: '22 of 36 EMIs paid',
                        progress: 0.61,
                        interestRate: '9.0% p.a.',
                        tenure: '36 months',
                        startDate: 'Jun 2023',
                        onViewStatement: () => onViewStatement('Education Loan', 'EL-2023-00567'),
                        onTrackStatus: () => onTrackStatus('Education Loan', 'EL-2023-00567'),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

