import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../home/widgets/home_navigation_widgets.dart';
import 'lumpsum_investment_screen.dart';
import 'sip_investment_screen.dart';

class FundDetailScreen extends StatefulWidget {
  final String fundName;
  const FundDetailScreen({super.key, required this.fundName});

  @override
  State<FundDetailScreen> createState() => _FundDetailScreenState();
}

class _FundDetailScreenState extends State<FundDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      appBar: AppBar(
        backgroundColor: kCream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: kForest, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.favorite_border, color: kForest), onPressed: () {}),
          IconButton(icon: const Icon(Icons.share_outlined, color: kForest), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildAssetAllocation(),
                  const SizedBox(height: 32),
                  _buildPerformanceTable(),
                  const SizedBox(height: 32),
                  _buildPeerComparison(),
                  const SizedBox(height: 80), // Space for pinned button
                ],
              ),
            ),
          ),
          _buildPinnedInvestButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(color: kCream, borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.auto_graph_rounded, color: kForest, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.fundName, style: const TextStyle(color: kForest, fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 4),
                  const Text('Equity: Small Cap • 5★ Rating', style: TextStyle(color: kSub, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildQuickStat('NAV', '₹214.20', Colors.black),
            _buildQuickStat('3Y Returns', '38.4%', Colors.green),
            _buildQuickStat('Fund Size', '₹12.4k Cr', Colors.black),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickStat(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: kSub, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: valueColor, fontSize: 15, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildAssetAllocation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Asset Allocation', style: TextStyle(color: kForest, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              sectionsSpace: 4,
              centerSpaceRadius: 50,
              sections: [
                PieChartSectionData(color: kForest, value: 92, title: '92%', radius: 25, titleStyle: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                PieChartSectionData(color: kMid.withValues(alpha: 0.5), value: 5, title: '5%', radius: 25, titleStyle: const TextStyle(color: kForest, fontSize: 10, fontWeight: FontWeight.bold)),
                PieChartSectionData(color: kCream, value: 3, title: '3%', radius: 25, titleStyle: const TextStyle(color: kForest, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('Equity', kForest),
            const SizedBox(width: 20),
            _buildLegendItem('Debt', kMid.withValues(alpha: 0.5)),
            const SizedBox(width: 20),
            _buildLegendItem('Cash', kCream),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: kSub, fontSize: 11)),
      ],
    );
  }

  Widget _buildPerformanceTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Performance Comparison', style: TextStyle(color: kForest, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kCream,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildPerformanceRow('Period', 'This Fund', 'Benchmark', isHeader: true),
              const Divider(height: 24),
              _buildPerformanceRow('1 Year', '24.2%', '18.5%'),
              const SizedBox(height: 12),
              _buildPerformanceRow('3 Year', '38.4%', '22.1%'),
              const SizedBox(height: 12),
              _buildPerformanceRow('5 Year', '142.1%', '94.5%'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceRow(String period, String fund, String benchmark, {bool isHeader = false}) {
    return Row(
      children: [
        Expanded(child: Text(period, style: TextStyle(color: isHeader ? kForest : kSub, fontWeight: isHeader ? FontWeight.bold : FontWeight.normal, fontSize: 13))),
        SizedBox(width: 80, child: Text(fund, style: TextStyle(color: isHeader ? kForest : Colors.green, fontWeight: FontWeight.bold, fontSize: 13))),
        SizedBox(width: 80, child: Text(benchmark, style: TextStyle(color: isHeader ? kForest : kSub, fontWeight: isHeader ? FontWeight.bold : FontWeight.normal, fontSize: 13))),
      ],
    );
  }

  Widget _buildPeerComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('People also considered', style: TextStyle(color: kForest, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildPeerCard('Nippon India Small Cap', '31.2%'),
              _buildPeerCard('Axis Small Cap Fund', '26.8%'),
              _buildPeerCard('HDFC Small Cap', '22.5%'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPeerCard(String name, String returns) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(color: kForest, fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('3Y RETURNS', style: TextStyle(color: kSub, fontSize: 8, fontWeight: FontWeight.bold)),
                  Text(returns, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              const Icon(Icons.add_circle_outline, color: kForest),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPinnedInvestButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 56,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SIPInvestmentScreen(fundName: widget.fundName),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: kForest, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Start SIP', style: TextStyle(color: kForest, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LumpsumInvestmentScreen(fundName: widget.fundName),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kForest,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Invest Now', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
