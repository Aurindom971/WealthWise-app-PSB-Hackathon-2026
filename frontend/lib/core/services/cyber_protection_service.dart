import 'package:flutter/foundation.dart';

enum RiskLevel { low, medium, high }

class RiskAssessment {
  final int score;
  final RiskLevel level;
  final String reason;

  RiskAssessment({required this.score, required this.level, required this.reason});
}

class CyberProtectionService {
  /// Analyzes a transaction and determines if it should be allowed, warned, or blocked.
  RiskAssessment evaluateRisk({
    required double amount,
    required double typicalAverageAmount,
    required bool isNewDevice,
    required int actionSpeedSeconds,
    required int failedOtpAttempts,
    required bool isFirstTimeInvestment,
  }) {
    int score = 0;
    List<String> reasons = [];

    // 1. Device Trust
    if (isNewDevice) {
      score += 30;
      reasons.add("Action initiated from an unrecognized device.");
    }

    // 2. Transaction Anomalies
    if (amount > typicalAverageAmount * 3) {
      score += 40;
      reasons.add("Amount is unusually high compared to typical history.");
    } else if (amount > typicalAverageAmount * 1.5) {
      score += 15;
    }

    // 3. Action Speed (Bots/Scripts vs Humans)
    if (actionSpeedSeconds < 2) {
      score += 20;
      reasons.add("Abnormal action speed detected (potential bot).");
    }

    // 4. OTP/Authentication struggles
    if (failedOtpAttempts > 0) {
      score += (failedOtpAttempts * 10);
      reasons.add("Multiple failed authentication attempts.");
    }

    // 5. First time investment flag
    if (isFirstTimeInvestment && amount > 10000) {
      score += 15;
      reasons.add("High amount for a first-time investment action.");
    }

    // Cap score at 100
    if (score > 100) score = 100;

    RiskLevel level;
    if (score >= 70) {
      level = RiskLevel.high;
    } else if (score >= 40) {
      level = RiskLevel.medium;
    } else {
      level = RiskLevel.low;
    }

    String finalReason = reasons.isNotEmpty 
        ? reasons.join(" ") 
        : "Behaviour aligns with normal patterns.";

    debugPrint("Risk Eval -> Score: $score | Level: $level");
    return RiskAssessment(score: score, level: level, reason: finalReason);
  }
}
