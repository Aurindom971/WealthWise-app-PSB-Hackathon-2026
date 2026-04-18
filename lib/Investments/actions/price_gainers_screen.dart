import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PriceGainersScreen extends StatefulWidget {
  const PriceGainersScreen({super.key});

  @override
  State<PriceGainersScreen> createState() => _PriceGainersScreenState();
}

class _PriceGainersScreenState extends State<PriceGainersScreen> {
  final Color kForest = const Color(0xFF1B422B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: kForest, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price Gainers',
              style: TextStyle(color: kForest, fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const Text(
              'Updated real-time',
              style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: kForest,
        icon: const Icon(Icons.bolt, color: Colors.white),
        label: const Text('Quick Trade', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildMomentumSlider(),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 32, 20, 16),
              child: Text(
                'Top Performers',
                style: TextStyle(color: Color(0xFF1B422B), fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            _buildGridCards(),
            const SizedBox(height: 100), // Padding for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildMomentumSlider() {
    return SizedBox(
      height: 120,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.85),
        itemCount: 5,
        itemBuilder: (context, index) {
          final stocks = ['RELIANCE', 'HDFC BANK', 'TCS', 'INFY', 'ICICI'];
          final changes = ['+5.2%', '+4.8%', '+3.9%', '+3.5%', '+3.2%'];
          return _buildMomentumCard(stocks[index], changes[index]);
        },
      ),
    );
  }

  Widget _buildMomentumCard(String symbol, String change) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kForest, const Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kForest.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '# Momentum',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                symbol,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Text(
            change,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildGridCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          final symbols = ['ADANIENT', 'WIPRO', 'TITAN', 'AXISBANK', 'LT', 'M&M'];
          return _buildGlassCard(symbols[index]);
        },
      ),
    );
  }

  Widget _buildGlassCard(String symbol) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(symbol, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const Spacer(),
              SizedBox(
                height: 40,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          const FlSpot(0, 1),
                          const FlSpot(1, 3),
                          const FlSpot(2, 2.5),
                          const FlSpot(3, 4.5),
                          const FlSpot(4, 3.8),
                          const FlSpot(5, 6),
                        ],
                        isCurved: true,
                        color: Colors.green,
                        barWidth: 2,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(show: true, color: Colors.green.withValues(alpha: 0.1)),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('₹2,450', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(
                    '+5.40%',
                    style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
