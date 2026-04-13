import 'package:flutter/material.dart';
import '../../home/widgets/home_navigation_widgets.dart';
import '../../home/screens/notifications_screen.dart';
import '../widgets/active_loan_card.dart';
import 'loan_statement_screen.dart';
import 'application_status_screen.dart';

class ActiveLoansScreen extends StatelessWidget {
  const ActiveLoansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: TopBar(
                onHomeTap: () => Navigator.pop(context),
                onLogoutTap: () => Navigator.pop(context),
                onNotificationTap: () => showNotifications(context),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 30),
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
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                            padding: EdgeInsets.zero,
                            alignment: Alignment.centerLeft,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Application Tracker',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Review the status of your loan applications',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline, color: Colors.white70, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'You have 3 loans currently active and being tracked.',
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

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
                            onViewStatement: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoanStatementScreen(
                                  loanType: 'Personal Loan',
                                  loanId: 'PL-2024-00891',
                                ),
                              ),
                            ),
                            onTrackStatus: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ApplicationStatusScreen(
                                  loanType: 'Personal Loan',
                                  loanId: 'PL-2024-00891',
                                ),
                              ),
                            ),
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
                            onViewStatement: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoanStatementScreen(
                                  loanType: 'Car Loan',
                                  loanId: 'CL-2023-01234',
                                ),
                              ),
                            ),
                            onTrackStatus: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ApplicationStatusScreen(
                                  loanType: 'Car Loan',
                                  loanId: 'CL-2023-01234',
                                ),
                              ),
                            ),
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
                            onViewStatement: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoanStatementScreen(
                                  loanType: 'Education Loan',
                                  loanId: 'EL-2023-00567',
                                ),
                              ),
                            ),
                            onTrackStatus: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ApplicationStatusScreen(
                                  loanType: 'Education Loan',
                                  loanId: 'EL-2023-00567',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Nav
            BottomNav(
              currentIndex: -1,
              onTap: (i) => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

