import 'package:flutter/material.dart';

enum UtilityType {
  electricity,
  water,
  broadband,
  fastag,
  gas,
  mobile,
}

class UtilityProvider {
  final UtilityType type;
  final String name;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const UtilityProvider({
    required this.type,
    required this.name,
    required this.icon,
    required this.color,
    required this.bgColor,
  });
}

class Bill {
  final String id;
  final String providerName;
  final String consumerId;
  final double amount;
  final DateTime dueDate;
  final UtilityType type;
  bool isPaid;

  Bill({
    required this.id,
    required this.providerName,
    required this.consumerId,
    required this.amount,
    required this.dueDate,
    required this.type,
    this.isPaid = false,
  });

  IconData get typeIcon {
    switch (type) {
      case UtilityType.electricity: return Icons.bolt_rounded;
      case UtilityType.water: return Icons.water_drop_rounded;
      case UtilityType.broadband: return Icons.router_rounded;
      case UtilityType.fastag: return Icons.minor_crash_rounded;
      case UtilityType.gas: return Icons.local_fire_department_rounded;
      case UtilityType.mobile: return Icons.phone_android_rounded;
    }
  }

  Color get iconColor {
    switch (type) {
      case UtilityType.electricity: return const Color(0xFFFFB300);
      case UtilityType.water: return const Color(0xFF0288D1);
      case UtilityType.broadband: return const Color(0xFF7B1FA2);
      case UtilityType.fastag: return const Color(0xFF388E3C);
      case UtilityType.gas: return const Color(0xFFF4511E);
      case UtilityType.mobile: return const Color(0xFF1E88E5);
    }
  }

  String get dueDescription {
    final days = dueDate.difference(DateTime.now()).inDays;
    if (days < 0) return 'Overdue by ${days.abs()} days';
    if (days == 0) return 'Due today';
    return 'Due in $days days';
  }
}

class RecentPayment {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final DateTime date;
  final UtilityType type;

  const RecentPayment({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.type,
  });
}

enum BillRechargeSubState {
  main,
  utilityDetails,
  upcomingBills,
  paymentGateway,
}
