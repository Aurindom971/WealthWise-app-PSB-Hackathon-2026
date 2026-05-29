import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// Sparkline Painter for lightweight, high-performance drawing
class SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;

  SparklinePainter(this.data, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final path = Path();

    double minVal = data.reduce((a, b) => a < b ? a : b);
    double maxVal = data.reduce((a, b) => a > b ? a : b);
    double range = maxVal - minVal;
    if (range == 0) range = 1.0;

    double dx = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      double x = i * dx;
      double y = size.height - ((data[i] - minVal) / range * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SparklinePainter oldDelegate) =>
      oldDelegate.data != data || oldDelegate.color != color;
}

// Single Market Index Data Model
class MarketIndexData {
  final String name;
  final String value;
  final String percentageChange;
  final bool isUp;
  final List<double> sparklineData;
  final String high;
  final String low;
  final String prevClose;

  MarketIndexData({
    required this.name,
    required this.value,
    required this.percentageChange,
    required this.isUp,
    required this.sparklineData,
    required this.high,
    required this.low,
    required this.prevClose,
  });
}

// Sparkline Widget wrapper
class Sparkline extends StatelessWidget {
  final List<double> data;
  final Color color;
  final double width;
  final double height;

  const Sparkline({
    super.key,
    required this.data,
    required this.color,
    this.width = 60,
    this.height = 30,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: SparklinePainter(data, color),
      ),
    );
  }
}

// Horizontal Indices Carousel (Reused in invest.dart and MarketIndicesScreen)
class MarketIndicesCarousel extends StatelessWidget {
  final List<MarketIndexData> indices;
  final Function(MarketIndexData)? onTapIndex;

  const MarketIndicesCarousel({
    super.key,
    required this.indices,
    this.onTapIndex,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: indices.map((indexData) {
          final isUp = indexData.isUp;
          final color = isUp ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
          return GestureDetector(
            onTap: () {
              if (onTapIndex != null) {
                onTapIndex!(indexData);
              }
            },
            child: Container(
              width: 170,
              margin: const EdgeInsets.only(right: 12, bottom: 4, top: 4),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.015),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Left: Index Name, Bottom Left: Current Value
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          indexData.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F5D3A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          indexData.value,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Right Side: Sparkline + percentage change
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Sparkline(
                        data: indexData.sparklineData,
                        color: color,
                        width: 50,
                        height: 22,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        indexData.percentageChange,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class MarketIndicesScreen extends StatefulWidget {
  const MarketIndicesScreen({super.key});

  @override
  State<MarketIndicesScreen> createState() => _MarketIndicesScreenState();
}

class _MarketIndicesScreenState extends State<MarketIndicesScreen> {
  final Color kDarkGreen = const Color(0xFF1F5D3A);
  final Color kCreamBg = const Color(0xFFF2F0EB);

  late List<MarketIndexData> indicesData;
  late MarketIndexData selectedIndex;

  @override
  void initState() {
    super.initState();
    indicesData = [
      MarketIndexData(
        name: 'NIFTY 50',
        value: '22,450.20',
        percentageChange: '+0.45%',
        isUp: true,
        sparklineData: [22350.0, 22390.0, 22380.0, 22410.0, 22430.0, 22450.2],
        high: '22,480.10',
        low: '22,340.50',
        prevClose: '22,348.80',
      ),
      MarketIndexData(
        name: 'SENSEX',
        value: '73,885.60',
        percentageChange: '+0.38%',
        isUp: true,
        sparklineData: [73600.0, 73720.0, 73680.0, 73800.0, 73840.0, 73885.6],
        high: '74,010.50',
        low: '73,550.20',
        prevClose: '73,605.10',
      ),
      MarketIndexData(
        name: 'NIFTY BANK',
        value: '48,115.30',
        percentageChange: '-0.25%',
        isUp: false,
        sparklineData: [48300.0, 48250.0, 48280.0, 48190.0, 48140.0, 48115.3],
        high: '48,390.40',
        low: '48,050.10',
        prevClose: '48,235.80',
      ),
      MarketIndexData(
        name: 'NIFTY IT',
        value: '34,910.15',
        percentageChange: '+1.20%',
        isUp: true,
        sparklineData: [34400.0, 34550.0, 34600.0, 34750.0, 34820.0, 34910.15],
        high: '35,050.60',
        low: '34,350.00',
        prevClose: '34,495.20',
      ),
    ];
    selectedIndex = indicesData[0];
  }

  @override
  Widget build(BuildContext context) {
    final chartColor = selectedIndex.isUp ? const Color(0xFF16A34A) : const Color(0xFFDC2626);

    return Scaffold(
      backgroundColor: kCreamBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.chevron_left, size: 28, color: kDarkGreen),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Market Pulse',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: kDarkGreen,
                    ),
                  ),
                ],
              ),
            ),

            // Horizontal Carousel
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: MarketIndicesCarousel(
                indices: indicesData,
                onTapIndex: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),
            ),

            const SizedBox(height: 16),

            // Detailed interactive chart of the selected index
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Sparkline/Details Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.01),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedIndex.name,
                                    style: TextStyle(
                                      color: kDarkGreen,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'INDEX MARKET TREND',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: chartColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  selectedIndex.percentageChange,
                                  style: TextStyle(
                                    color: chartColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            selectedIndex.value,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF111827),
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Large interactive LineChart
                          SizedBox(
                            height: 180,
                            child: LineChart(
                              LineChartData(
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  drawHorizontalLine: true,
                                  getDrawingHorizontalLine: (value) => FlLine(
                                    color: Colors.grey.shade100,
                                    strokeWidth: 1,
                                  ),
                                ),
                                titlesData: const FlTitlesData(
                                  show: false,
                                ),
                                borderData: FlBorderData(show: false),
                                minX: 0,
                                maxX: (selectedIndex.sparklineData.length - 1).toDouble(),
                                minY: selectedIndex.sparklineData.reduce((a, b) => a < b ? a : b) - 20,
                                maxY: selectedIndex.sparklineData.reduce((a, b) => a > b ? a : b) + 20,
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: selectedIndex.sparklineData.asMap().entries.map((entry) {
                                      return FlSpot(entry.key.toDouble(), entry.value);
                                    }).toList(),
                                    isCurved: true,
                                    color: chartColor,
                                    barWidth: 3.5,
                                    isStrokeCapRound: true,
                                    dotData: FlDotData(
                                      show: true,
                                      getDotPainter: (spot, percent, barData, index) {
                                        return FlDotCirclePainter(
                                          radius: 3,
                                          color: chartColor,
                                          strokeWidth: 1,
                                          strokeColor: Colors.white,
                                        );
                                      },
                                    ),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      gradient: LinearGradient(
                                        colors: [
                                          chartColor.withValues(alpha: 0.2),
                                          chartColor.withValues(alpha: 0.0),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Market Metrics Details Row
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Market Summary',
                            style: TextStyle(
                              color: kDarkGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow('Today\'s High', selectedIndex.high),
                          Divider(color: Colors.grey.shade100, height: 20),
                          _buildDetailRow('Today\'s Low', selectedIndex.low),
                          Divider(color: Colors.grey.shade100, height: 20),
                          _buildDetailRow('Prev. Close', selectedIndex.prevClose),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: kDarkGreen,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
