import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../home/widgets/home_navigation_widgets.dart';

class InvestmentTransactionScreen extends StatefulWidget {
  final String fundName;
  const InvestmentTransactionScreen({super.key, required this.fundName});

  @override
  State<InvestmentTransactionScreen> createState() => _InvestmentTransactionScreenState();
}

class _InvestmentTransactionScreenState extends State<InvestmentTransactionScreen> {
  bool _isSIP = true;
  double _amount = 5000;
  double _years = 10;
  final double _expectedReturn = 0.15; // 15% annual return

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: kForest, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Make an Investment',
          style: TextStyle(color: kForest, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildModeToggle(),
                  const SizedBox(height: 32),
                  _buildAmountInput(),
                  const SizedBox(height: 8),
                  _buildQuickChips(),
                  if (_isSIP) ...[
                    const SizedBox(height: 48),
                    _buildProjectedWealthHeader(),
                    const SizedBox(height: 24),
                    _buildGrowthChart(),
                    const SizedBox(height: 32),
                    _buildDurationSlider(),
                  ],
                ],
              ),
            ),
          ),
          _buildBottomCTA(),
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: kCream,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: _buildToggleButton('Monthly (SIP)', _isSIP, () => setState(() => _isSIP = true))),
          Expanded(child: _buildToggleButton('One-time', !_isSIP, () => setState(() => _isSIP = false))),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isActive ? kForest : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : kSub,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('INVESTMENT AMOUNT', style: TextStyle(color: kSub, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('₹', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: kForest)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _amount.toStringAsFixed(0),
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: kForest),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickChips() {
    return Row(
      children: [1000, 5000, 10000, 25000].map((val) {
        return GestureDetector(
          onTap: () => setState(() => _amount = val.toDouble()),
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            child: Text('+${val ~/ 1000}k', style: const TextStyle(color: kForest, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProjectedWealthHeader() {
    double totalInvested = _amount * 12 * _years;
    double finalValue = _calculateWealth(_amount, _years, _expectedReturn);
    double estimatedReturns = finalValue - totalInvested;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ESTIMATED RETURNS', style: TextStyle(color: kSub, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('₹${estimatedReturns.toStringAsFixed(0)}', style: const TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('TOTAL WEALTH', style: TextStyle(color: kSub, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('₹${finalValue.toStringAsFixed(0)}', style: const TextStyle(color: kForest, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  double _calculateWealth(double monthly, double years, double rate) {
    double r = rate / 12;
    double n = years * 12;
    return monthly * ((math.pow(1 + r, n) - 1) / r) * (1 + r);
  }

  Widget _buildGrowthChart() {
    List<FlSpot> spots = [];
    for (int i = 0; i <= _years; i++) {
        spots.add(FlSpot(i.toDouble(), _calculateWealth(_amount, i.toDouble(), _expectedReturn)));
    }

    return SizedBox(
      height: 200,
      width: double.infinity,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: kForest,
              barWidth: 4,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [kForest.withValues(alpha: 0.1), kForest.withValues(alpha: 0.0)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('INVESTMENT DURATION', style: TextStyle(color: kSub, fontSize: 11, fontWeight: FontWeight.bold)),
            Text('${_years.toInt()} Years', style: const TextStyle(color: kForest, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: kForest,
            inactiveTrackColor: kCream,
            thumbColor: kForest,
            overlayColor: kForest.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: _years,
            min: 1,
            max: 25,
            onChanged: (val) => setState(() => _years = val),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomCTA() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: kForest,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: const Text('Proceed to Payment', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
