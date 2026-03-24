import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ActionCard extends StatelessWidget {
  final String title;
  final String amount;
  final Color backgroundColor;

  const ActionCard({
    super.key,
    required this.title,
    required this.amount,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)
        ]
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(amount, style: const TextStyle(fontSize: 16, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
