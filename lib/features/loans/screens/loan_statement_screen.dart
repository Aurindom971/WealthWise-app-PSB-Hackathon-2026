import 'package:flutter/material.dart';
import '../../home/widgets/home_navigation_widgets.dart';
import '../../home/screens/home_screen.dart';
import '../widgets/loan_header.dart';

class LoanStatementScreen extends StatelessWidget {
  final String loanType;
  final String loanId;
  final VoidCallback onBack;

  const LoanStatementScreen({
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
          title: 'Loan Statement',
          subtitle: loanType,
          icon: Icons.receipt_long_rounded,
          onBack: onBack,
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryBox(
                        label: 'Outstanding',
                        value: '₹2,75,000',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryBox(
                        label: 'Monthly EMI',
                        value: '₹15,000',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Repayment Progress Card
                const _SectionHeader(title: 'Repayment Progress'),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: kCard,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('9 of 20 EMIs paid',
                              style: TextStyle(
                                  color: Color(0xFF1F7A5A),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                          Text('45%',
                              style: TextStyle(
                                  color: kInk,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: const LinearProgressIndicator(
                          value: 0.45,
                          backgroundColor: Color(0xFFF2F0EB),
                          color: Color(0xFF1F7A5A),
                          minHeight: 10,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(child: _MiniSummary(label: 'Principal Paid', value: '₹99,041')),
                          Expanded(child: _MiniSummary(label: 'Interest Paid', value: '₹35,959')),
                          Expanded(child: _MiniSummary(label: 'EMIs Left', value: '11')),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 28),
                
                // Loan Details Card
                const _SectionHeader(title: 'Loan Details'),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: kCard,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Column(
                    children: [
                      _DetailRow(label: 'Principal Amount', value: '₹5,00,000'),
                      _DetailRow(label: 'Interest Rate', value: '10.5% p.a.'),
                      _DetailRow(label: 'Tenure', value: '20 months'),
                      _DetailRow(label: 'Disbursed', value: '₹5,00,000'),
                      _DetailRow(label: 'Start Date', value: 'Jul 2024'),
                      _DetailRow(label: 'Next Due Date', value: '5 Apr 2026', isLast: true),
                    ],
                  ),
                ),
                
                const SizedBox(height: 28),
                
                // EMI Schedule Section
                const _SectionHeader(title: 'EMI Schedule'),
                const _ScheduleItem(
                  date: 'Jul 2024',
                  principal: '₹10,625',
                  interest: '₹4,375',
                  balance: '₹4,89,375',
                  status: 'Paid',
                ),
                const _ScheduleItem(
                  date: 'Aug 2024',
                  principal: '₹10,718',
                  interest: '₹4,282',
                  balance: '₹4,78,657',
                  status: 'Paid',
                ),
                const _ScheduleItem(
                  date: 'Sep 2024',
                  principal: '₹10,812',
                  interest: '₹4,188',
                  balance: '₹4,67,845',
                  status: 'Paid',
                  isLast: true,
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: kSub,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: kInk,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: kInk,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _MiniSummary extends StatelessWidget {
  final String label;
  final String value;
  const _MiniSummary({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: kSub, fontSize: 10, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: kInk, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;
  const _DetailRow({required this.label, required this.value, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: kSub, fontSize: 13, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: kInk, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _ScheduleItem extends StatelessWidget {
  final String date;
  final String principal;
  final String interest;
  final String balance;
  final String status;
  final bool isLast;

  const _ScheduleItem({
    required this.date,
    required this.principal,
    required this.interest,
    required this.balance,
    required this.status,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFFEAF6F0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Color(0xFF1F7A5A), size: 14),
              ),
              const SizedBox(width: 12),
              Text(date, style: const TextStyle(color: kInk, fontSize: 15, fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF6F0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(status, style: const TextStyle(color: Color(0xFF1F7A5A), fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MiniScheduleBox(label: 'Principal', value: principal),
              _MiniScheduleBox(label: 'Interest', value: interest),
              _MiniScheduleBox(label: 'Balance', value: balance, isEnd: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniScheduleBox extends StatelessWidget {
  final String label;
  final String value;
  final bool isEnd;
  const _MiniScheduleBox({required this.label, required this.value, this.isEnd = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: kSub, fontSize: 10, fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: kInk, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
