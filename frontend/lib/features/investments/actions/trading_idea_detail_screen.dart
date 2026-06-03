import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../send/screens/send_transfer_screen.dart';
import '../../home/widgets/home_navigation_widgets.dart';

class TradingIdeaDetailScreen extends StatelessWidget {
  static const Color kForest = Color(0xFF1F5D3A);
  static const Color kCream = Color(0xFFF2F0EB);

  final String title;
  final String subtitle;
  final String price;
  final String percentageChange;
  final double entryPrice;
  final double sl;
  final double target;
  final double fundsRequired;
  final String timePosted;
  final String updatedTime;
  final String provider;

  const TradingIdeaDetailScreen({
    super.key,
    required this.title,
    this.subtitle = 'Short Term \u2022 Oversold Condition',
    required this.price,
    required this.percentageChange,
    required this.entryPrice,
    required this.sl,
    required this.target,
    required this.fundsRequired,
    this.timePosted = '29 May, 03:18 PM',
    this.updatedTime = '29 May, 03:20 PM',
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: TopBar(
                searchText: 'Search Option Details',
                onHomeTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
                onLogoutTap: () => Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false),
                onNotificationTap: () {},
              ),
            ),
            // Top Bar / Navigation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Icon(Icons.arrow_back, size: 18, color: kForest),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Trading Idea',
                    style: TextStyle(
                      color: kForest,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    // Header Card
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: const Text(
                            'B',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  color: kForest,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    subtitle,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.grey.shade600,
                                    size: 14,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    // SL Target range slider visual (Second Image)
                    _buildSliderWidget(),
                    const SizedBox(height: 32),
                    Divider(color: Colors.grey.shade300, height: 1),
                    const SizedBox(height: 24),
                    // Timestamps Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildTimestampItem('Time Posted', timePosted),
                        _buildTimestampItem('Updated Time', updatedTime),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Divider(color: Colors.grey.shade300, height: 1),
                    const SizedBox(height: 32),
                    // Charts, Alerts, Details Action Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildActionButton(context, Icons.candlestick_chart_rounded, 'Charts', () => _showChartsModal(context)),
                        _buildActionButton(context, Icons.alarm_rounded, 'Alerts', () => _showAlertsDialog(context)),
                        _buildActionButton(context, Icons.info_outline_rounded, 'Details', () => _showDetailsModal(context)),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBottomDrawer(context),
          BottomNav(
            currentIndex: 3,
            onTap: (index) {
              if (index == 3) return;
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/home',
                (route) => false,
                arguments: {'index': index},
              );
            },
            onLogoutTap: () => Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false),
            onNotificationTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSliderWidget() {
    // Math to position bubbles relative to SL and Target values
    double currentVal = double.tryParse(price) ?? entryPrice;
    double totalRange = target - sl;
    if (totalRange <= 0) totalRange = 1.0;
    
    double entryRatio = ((entryPrice - sl) / totalRange).clamp(0.0, 1.0);
    double currentRatio = ((currentVal - sl) / totalRange).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current Price bubble
        LayoutBuilder(
          builder: (context, constraints) {
            double containerWidth = constraints.maxWidth;
            double pinOffset = containerWidth * currentRatio;
            // Prevent overflow at boundaries
            double bubbleLeft = (pinOffset - 60).clamp(0.0, containerWidth - 120);

            return Stack(
              clipBehavior: Clip.none,
              children: [
                SizedBox(height: 70, width: containerWidth),
                Positioned(
                  left: bubbleLeft,
                  top: 0,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF1ED),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: kForest),
                        ),
                        child: Text(
                          '$price $percentageChange',
                          style: const TextStyle(
                            color: kForest,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      CustomPaint(
                        size: const Size(10, 8),
                        painter: TrianglePainter(kForest),
                      ),
                    ],
                  ),
                ),
                // Pin connecting bubble to line
                Positioned(
                  left: pinOffset,
                  top: 32,
                  child: Container(
                    width: 2,
                    height: 20,
                    color: kForest,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 4),
        // Entry Price bubble
        LayoutBuilder(
          builder: (context, constraints) {
            double containerWidth = constraints.maxWidth;
            double pinOffset = containerWidth * entryRatio;
            double bubbleLeft = (pinOffset - 40).clamp(0.0, containerWidth - 80);

            return Stack(
              clipBehavior: Clip.none,
              children: [
                SizedBox(height: 36, width: containerWidth),
                Positioned(
                  left: bubbleLeft,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      'Entry: ${entryPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                // Tiny connecting dot
                Positioned(
                  left: pinOffset - 2,
                  top: 24,
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 4),
        // Multi-color colored bar (Red/Orange/Green segments)
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(height: 8, color: Colors.red.shade700),
              ),
              const SizedBox(width: 2),
              Expanded(
                flex: 2,
                child: Container(height: 8, color: Colors.orange),
              ),
              const SizedBox(width: 2),
              Expanded(
                flex: 5,
                child: Container(height: 8, color: Colors.green),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Stop Loss & Target labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'SL:$sl',
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              'Target:$target',
              style: const TextStyle(
                color: kForest,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimestampItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: kForest,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Icon(icon, color: kForest, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  void _showChartsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        int selectedTimeframe = 0;
        final List<List<FlSpot>> chartPoints = [
          [
            const FlSpot(0, 70.0),
            const FlSpot(1, 72.5),
            const FlSpot(2, 71.0),
            const FlSpot(3, 73.8),
            const FlSpot(4, 72.0),
            const FlSpot(5, 71.5),
          ],
          [
            const FlSpot(0, 65.0),
            const FlSpot(1, 68.0),
            const FlSpot(2, 74.0),
            const FlSpot(3, 70.5),
            const FlSpot(4, 71.5),
          ],
          [
            const FlSpot(0, 55.0),
            const FlSpot(1, 62.0),
            const FlSpot(2, 59.0),
            const FlSpot(3, 68.0),
            const FlSpot(4, 71.5),
          ],
        ];

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.55,
              decoration: const BoxDecoration(
                color: kCream,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: kForest,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Premium Chart Analysis',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '₹ $price',
                          style: const TextStyle(
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: ['1D', '1W', '1M'].asMap().entries.map((entry) {
                      int index = entry.key;
                      String label = entry.value;
                      bool isSelected = selectedTimeframe == index;
                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            selectedTimeframe = index;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? kForest : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? kForest : Colors.grey.shade200,
                            ),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              color: isSelected ? Colors.white : kForest,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0, top: 10),
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: chartPoints[selectedTimeframe],
                              isCurved: true,
                              color: kForest,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                color: kForest.withValues(alpha: 0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAlertsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        double triggerPrice = double.tryParse(price.replaceAll(',', '')) ?? entryPrice;
        bool isGreater = true;
        TextEditingController priceCtrl = TextEditingController(text: triggerPrice.toStringAsFixed(2));

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: kCream,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              title: const Text(
                'Set Price Alert',
                style: TextStyle(
                  color: kForest,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Trigger Condition',
                    style: TextStyle(
                      color: kForest,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setDialogState(() => isGreater = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isGreater ? kForest : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isGreater ? kForest : Colors.grey.shade200,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '>= (Above)',
                              style: TextStyle(
                                color: isGreater ? Colors.white : kForest,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setDialogState(() => isGreater = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: !isGreater ? kForest : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: !isGreater ? kForest : Colors.grey.shade200,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '<= (Below)',
                              style: TextStyle(
                                color: !isGreater ? Colors.white : kForest,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Trigger Price (₹)',
                    style: TextStyle(
                      color: kForest,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: priceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: kForest,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        content: Text(
                          'Price alert set for $title at ₹${priceCtrl.text} when it goes ${isGreater ? "above" : "below"}!',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kForest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Set Alert',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDetailsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.65,
          decoration: const BoxDecoration(
            color: kCream,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  color: kForest,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Option Contract Metrics & Greeks',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildMetricsCard('Implied Volatility (IV)', '24.5%', 'Measures the market\'s expectation of future volatility.'),
                    _buildMetricsCard('Put-Call Ratio (PCR)', '1.15', 'Bullish sentiment indicator (>1 indicates more puts than calls).'),
                    _buildMetricsCard('Open Interest (OI)', '1,250,000 contracts', 'Total outstanding active contracts in the market.'),
                    const SizedBox(height: 16),
                    const Text(
                      'Option Greeks',
                      style: TextStyle(
                        color: kForest,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildGreekCard('Delta', '0.58', 'Sensitivity to underlying price change')),
                        const SizedBox(width: 12),
                        Expanded(child: _buildGreekCard('Gamma', '0.0024', 'Rate of change in Delta')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildGreekCard('Theta', '-12.50', 'Daily time decay rate')),
                        const SizedBox(width: 12),
                        Expanded(child: _buildGreekCard('Vega', '8.42', 'Sensitivity to implied volatility change')),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricsCard(String label, String value, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: kForest,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: kForest,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreekCard(String name, String value, String desc) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: kForest,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomDrawer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Funds Required:',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '₹${fundsRequired.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                style: const TextStyle(
                  color: kForest,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BankTransferScreen(
                      toAccount: "987654321012",
                      toIfsc: "PSIB0001234",
                      toNominee: provider,
                      toBank: "Punjab National Bank",
                      amount: fundsRequired.toStringAsFixed(2),
                      purpose: "Option Trade Buy",
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981), // Buy green
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Buy',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Powered by $provider',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
              ),
              const SizedBox(width: 4),
              Icon(Icons.info_outline, color: Colors.grey.shade500, size: 12),
            ],
          ),
        ],
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;
  TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
