class Insight {
  final String title;
  final String description;
  final String why;
  final InsightType type;

  Insight({
    required this.title,
    required this.description,
    required this.why,
    required this.type,
  });
}

enum InsightType { warning, opportunity, info }

class WealthIntelligenceService {
  /// Generates dynamic financial insights based on user mock data.
  List<Insight> generateInsights({
    required double totalBalance,
    required double monthlySpends,
    required double monthlyIncome,
    required List<double> recentTransactions, 
  }) {
    List<Insight> insights = [];

    // Opportunity: High liquidity, zero investment
    if (totalBalance > monthlyIncome * 1.5) {
      insights.add(Insight(
        title: "Idle Cash Detected",
        description: "Consider moving ₹${(totalBalance * 0.2).toStringAsFixed(0)} into a Liquid Mutual Fund.",
        why: "Your balance is significantly higher than your monthly needs. Inflation is reducing the value of idle cash.",
        type: InsightType.opportunity,
      ));
    }

    // Warning: Overspending
    if (monthlySpends > monthlyIncome * 0.8) {
      insights.add(Insight(
        title: "High Spending Alert",
        description: "You have spent 80% of your primary income this month.",
        why: "We noticed higher than usual outward transactions in the last week.",
        type: InsightType.warning,
      ));
    }

    // Habit building
    insights.add(Insight(
      title: "Start a Micro-SIP",
      description: "Invest ₹500/week to build discipline.",
      why: "Frequent small investments average out market volatility and build a strong habit.",
      type: InsightType.info,
    ));

    return insights;
  }
  
  /// Generates a quick AI explanation for an action.
  String explainRecommendation(String actionType) {
    switch (actionType) {
      case 'FD':
        return "Fixed Deposits provide guaranteed returns and low risk perfectly suited for your emergency fund.";
      case 'Equity':
        return "Based on your young age profile, allocating 60% to equity increases long term wealth generation despite short term volatility.";
      default:
        return "This aligns with your previously stated goal of balanced capital appreciation.";
    }
  }
}
