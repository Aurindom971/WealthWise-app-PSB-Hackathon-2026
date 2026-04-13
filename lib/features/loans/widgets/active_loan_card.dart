import 'package:flutter/material.dart';
import '../../home/widgets/home_navigation_widgets.dart';

class ActiveLoanCard extends StatelessWidget {
  final String type;
  final String loanId;
  final String principal;
  final String outstanding;
  final String emi;
  final String nextDue;
  final String paidText;
  final double progress;
  final String? interestRate;
  final String? tenure;
  final String? startDate;
  final VoidCallback onViewStatement;
  final VoidCallback? onTrackStatus;

  const ActiveLoanCard({
    super.key,
    required this.type,
    required this.loanId,
    required this.principal,
    required this.outstanding,
    required this.emi,
    required this.nextDue,
    required this.paidText,
    required this.progress,
    this.interestRate,
    this.tenure,
    this.startDate,
    required this.onViewStatement,
    this.onTrackStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF6F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.credit_card_rounded,
                    color: Color(0xFF1F7A5A), size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(type,
                        style: const TextStyle(
                            color: kInk,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    Text(loanId,
                        style: const TextStyle(color: kSub, fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFEAF6F0)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('On Time',
                    style: TextStyle(
                        color: Color(0xFF1F7A5A),
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Row 1: Principal and Outstanding
          Row(
            children: [
              Expanded(
                child: _DetailBox(
                  label: 'Principal',
                  value: principal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DetailBox(
                  label: 'Outstanding',
                  value: outstanding,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Row 2: Monthly EMI and Next Due
          Row(
            children: [
              Expanded(
                child: _DetailBox(
                  label: 'Monthly EMI',
                  value: emi,
                  icon: Icons.trending_up,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DetailBox(
                  label: 'Next Due',
                  value: nextDue,
                  icon: Icons.calendar_today_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Interest, Tenure, Started Row
          if (interestRate != null || tenure != null || startDate != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (interestRate != null)
                    _MiniDetail(label: 'Interest', value: interestRate!),
                  if (tenure != null)
                    _MiniDetail(label: 'Tenure', value: tenure!),
                  if (startDate != null)
                    _MiniDetail(label: 'Started', value: startDate!),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Progress Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(paidText,
                  style: const TextStyle(
                      color: Color(0xFF1F7A5A),
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              Text('${(progress * 100).toInt()}%',
                  style: const TextStyle(
                      color: kInk,
                      fontSize: 13,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFF2F0EB),
              color: const Color(0xFF245C3F),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 20),
          
          // Action Buttons
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onViewStatement,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kMid,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: const Text('View Statement', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
              const SizedBox(height: 10),
              if (onTrackStatus != null) ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onTrackStatus,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: kSub.withValues(alpha: 0.2)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Track Status',
                            style: TextStyle(
                                color: kMid.withValues(alpha: 0.8),
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(width: 6),
                        Icon(Icons.arrow_forward_ios_rounded,
                            size: 14, color: kMid.withValues(alpha: 0.8)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const _DetailBox({required this.label, required this.value, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: const Color(0xFF1F7A5A), size: 14),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: const TextStyle(
                  color: kSub,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: kInk,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniDetail extends StatelessWidget {
  final String label;
  final String value;

  const _MiniDetail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: kSub, fontSize: 10),
        ),
        Text(
          value,
          style: const TextStyle(
            color: kInk,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
