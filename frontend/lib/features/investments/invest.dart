import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'actions/ipo_application_screen.dart';
import 'actions/price_gainers_screen.dart';
import 'dart:math' as math;
import 'actions/explore_funds_screen.dart';
import 'actions/track_sips_screen.dart';
import 'actions/fund_detail_screen.dart';
import 'actions/quick_checkout_modal.dart';
import 'actions/lumpsum_investment_screen.dart';
import 'actions/sip_investment_screen.dart';
import 'actions/hdfc_nfo_screen.dart';
import 'actions/sbi_innovation_nfo_screen.dart';
import 'actions/icici_business_cycle_nfo_screen.dart';
import 'actions/stock_analysis_screen.dart';
import 'actions/fii_dii_insights_screen.dart';
import 'actions/search_stocks_screen.dart';
import 'actions/market_indices_screen.dart';
import 'actions/my_holdings_screen.dart';
import '../send/screens/send_transfer_screen.dart';

class InvestmentsScreen extends StatefulWidget {
  final VoidCallback onBack;

  const InvestmentsScreen({super.key, required this.onBack});

  @override
  State<InvestmentsScreen> createState() => _InvestmentsScreenState();
}

class _InvestmentsScreenState extends State<InvestmentsScreen>
    with SingleTickerProviderStateMixin {
  int? _hoveredScreenerIndex;
  int? _activeScreenerIndex;
  int? _hoveredTableRowIndex;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  int _selectedTab = 0; // 0: Stocks, 1: F&O, 2: Mutual Funds
  int _selectedTimeframe =
      4; // 0: 1m, 1: 3m, 2: 6m, 3: 1y, 4: 3y, 5: 5y, 6: max
  int _selectedFnOTimeframe = 0; // Starts at 1m for F&O
  int _selectedMFTimeframe = 4; // Starts at 3y for MF
  int _selectedOptionChainIndex = 0; // 0: Nifty 50, 1: Sensex, 2: Bank, 3: Fin

  List<MarketIndexData> get _indicesData => [
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

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  final Color kDarkGreen = const Color(0xFF1F5D3A); // Matches screenshot
  final Color kOrange = const Color(
    0xFFDD754E,
  ); // Matches screenshot donut chart
  final Color kLightGreenBg = const Color(0xFFEAF1ED); // Action card icon bg

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF2F0EB), // kCream background
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTabs(),
            const SizedBox(height: 24),
            if (_selectedTab == 0) ...[
              _buildStockSummary(),
              const SizedBox(height: 16),
              _buildQuickActions(isStocks: true),
              const SizedBox(height: 16),
              MarketIndicesCarousel(
                indices: _indicesData,
                onTapIndex: (indexData) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MarketIndicesScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildNavChart(),
              const SizedBox(height: 16),
              _buildSuggestedStocks(),
              const SizedBox(height: 24),
              _buildLiveIPOs(),
              const SizedBox(height: 32),
            ] else if (_selectedTab == 1) ...[
              _buildFnODistribution(),
              const SizedBox(height: 16),
              _buildScreenersSection(),
              const SizedBox(height: 16),
              _buildOptionChainSection(),
              const SizedBox(height: 16),
              _buildFIIDIISection(),
              const SizedBox(height: 16),
              _buildMarketMoversSection(),
              const SizedBox(height: 32),
            ] else if (_selectedTab == 2) ...[
              _buildMFSummary(),
              const SizedBox(height: 16),
              _buildQuickActions(),
              const SizedBox(height: 16),
              _buildMFChart(),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              _buildTopFunds(),
              const SizedBox(height: 24),
              _buildLiveNFOs(),
              const SizedBox(height: 32),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        Expanded(child: _buildTabWidget('Stocks', 0)),
        const SizedBox(width: 8),
        Expanded(child: _buildTabWidget('F&O', 1)),
        const SizedBox(width: 8),
        Expanded(child: _buildTabWidget('Mutual Funds', 2)),
      ],
    );
  }

  Widget _buildTabWidget(String text, int index) {
    bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? kDarkGreen : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: kDarkGreen)
              : Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : kDarkGreen,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildStockSummary() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MyHoldingsScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.015),
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
                Text(
                  'Stock Summary',
                  style: TextStyle(
                    color: kDarkGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'View All',
                      style: TextStyle(
                        color: kDarkGreen.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: kDarkGreen.withValues(alpha: 0.7),
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
          Row(
            children: [
              SizedBox(
                width: 110,
                height: 110,
                child: TweenAnimationBuilder<double>(
                  key: const ValueKey('stock_donut_chart'),
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return CustomPaint(
                      painter: DonutPainter(0.87, kOrange, kDarkGreen, value),
                    );
                  },
                ),
              ),
              const SizedBox(width: 28),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Investment',
                      style: TextStyle(
                        color: kDarkGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '₹50,000',
                      style: TextStyle(
                        color: kDarkGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Total Profit',
                      style: TextStyle(
                        color: kDarkGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹7,500',
                          style: TextStyle(
                            color: kDarkGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            '+15%',
                            style: TextStyle(
                              color: kDarkGreen,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              CircleAvatar(backgroundColor: kOrange, radius: 5),
              const SizedBox(width: 8),
              Text(
                'Investment (87%)',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              const Spacer(),
              CircleAvatar(backgroundColor: kDarkGreen, radius: 5),
              const SizedBox(width: 8),
              Text(
                'Profit (13%)',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              const Spacer(),
            ],
          ),
        ],
      ),
    ),
  );
}

  Widget _buildQuickActions({bool isStocks = false}) {
    if (isStocks) {
      return Row(
        children: [
          Expanded(
            child: _buildActionItem(
              Icons.search_rounded,
              'Search\nStocks',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchStocksScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildActionItem(
              Icons.show_chart_rounded,
              'Market\nIndices',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MarketIndicesScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildActionItem(
              Icons.pie_chart_rounded,
              'Stock\nPortfolio',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyHoldingsScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _buildActionItem(
            Icons.account_balance_wallet_outlined,
            'Invest\nLumpsum',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const LumpsumInvestmentScreen(fundName: 'Multiple Funds'),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildActionItem(
            Icons.insert_chart_outlined,
            'Start SIP',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const SIPInvestmentScreen(fundName: 'Multiple Funds'),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildActionItem(
            Icons.search_rounded,
            'Explore\nFunds',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExploreFundsScreen(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildActionItem(
            Icons.pie_chart_outline,
            'Track SIPs',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TrackSIPsScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionItem(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: kLightGreenBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: kDarkGreen, size: 22),
            ),
            const Spacer(),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: kDarkGreen,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _ChartData _getChartData() {
    switch (_selectedTimeframe) {
      case 0: // 1m
        return _ChartData(
          changeLabel: '+₹350 (+4.89%)',
          changeColor: const Color(0xFF63977B),
          minY: 6500,
          maxY: 8000,
          intervalY: 500,
          xLabels: ['1 Mar', '7 Mar', '14 Mar', '21 Mar', '28 Mar', 'Today'],
          spots: const [
            FlSpot(0.0, 7150.0),
            FlSpot(2.0, 7100.0),
            FlSpot(4.0, 7300.0),
            FlSpot(6.0, 7250.0),
            FlSpot(8.0, 7400.0),
            FlSpot(10.0, 7500.0),
          ],
        );
      case 1: // 3m
        return _ChartData(
          changeLabel: '+₹1,100 (+17.1%)',
          changeColor: const Color(0xFF63977B),
          minY: 5000,
          maxY: 8000,
          intervalY: 1000,
          xLabels: ['Jan', '', 'Feb', '', 'Mar', 'Today'],
          spots: const [
            FlSpot(0.0, 6400.0),
            FlSpot(2.0, 6500.0),
            FlSpot(4.0, 6900.0),
            FlSpot(6.0, 6850.0),
            FlSpot(8.0, 7200.0),
            FlSpot(10.0, 7500.0),
          ],
        );
      case 2: // 6m
        return _ChartData(
          changeLabel: '+₹2,000 (+36.3%)',
          changeColor: const Color(0xFF63977B),
          minY: 4000,
          maxY: 8000,
          intervalY: 1000,
          xLabels: ['Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar'],
          spots: const [
            FlSpot(0.0, 5500.0),
            FlSpot(2.0, 5700.0),
            FlSpot(4.0, 6100.0),
            FlSpot(6.0, 6500.0),
            FlSpot(8.0, 7000.0),
            FlSpot(10.0, 7500.0),
          ],
        );
      case 3: // 1y
        return _ChartData(
          changeLabel: '+₹3,300 (+78.5%)',
          changeColor: const Color(0xFF63977B),
          minY: 3000,
          maxY: 8000,
          intervalY: 1000,
          xLabels: ['Apr', 'Jul', 'Oct', 'Jan', 'Mar', 'Today'],
          spots: const [
            FlSpot(0.0, 4200.0),
            FlSpot(2.0, 4800.0),
            FlSpot(4.0, 5200.0),
            FlSpot(6.0, 6000.0),
            FlSpot(8.0, 6800.0),
            FlSpot(10.0, 7500.0),
          ],
        );
      case 4: // 3y
        return _ChartData(
          changeLabel: '+₹5,700 (+316.67%)',
          changeColor: const Color(0xFF63977B),
          minY: 0,
          maxY: 8000,
          intervalY: 2000,
          xLabels: ['Jan 23', 'Jul 23', 'Jan 24', 'Jul 24', 'Jan 25', 'Apr 26'],
          spots: const [
            FlSpot(0.0, 1800.0),
            FlSpot(1.0, 1950.0),
            FlSpot(2.0, 2200.0),
            FlSpot(3.0, 3300.0),
            FlSpot(4.0, 4500.0),
            FlSpot(5.0, 4900.0),
            FlSpot(6.0, 5200.0),
            FlSpot(7.0, 5450.0),
            FlSpot(8.0, 5800.0),
            FlSpot(9.0, 6500.0),
            FlSpot(10.0, 7500.0),
          ],
        );
      case 5: // 5y
        return _ChartData(
          changeLabel: '+₹6,300 (+525.0%)',
          changeColor: const Color(0xFF63977B),
          minY: 0,
          maxY: 8000,
          intervalY: 2000,
          xLabels: ['2019', '2020', '2021', '2022', '2023', '2024'],
          spots: const [
            FlSpot(0.0, 1200.0),
            FlSpot(2.0, 2000.0),
            FlSpot(4.0, 3200.0),
            FlSpot(6.0, 4500.0),
            FlSpot(8.0, 6000.0),
            FlSpot(10.0, 7500.0),
          ],
        );
      case 6: // max
      default:
        return _ChartData(
          changeLabel: '+₹7,000 (+1400.0%)',
          changeColor: const Color(0xFF63977B),
          minY: 0,
          maxY: 8000,
          intervalY: 2000,
          xLabels: ['2015', '2017', '2019', '2021', '2023', '2024'],
          spots: const [
            FlSpot(0.0, 500.0),
            FlSpot(2.0, 800.0),
            FlSpot(4.0, 1500.0),
            FlSpot(6.0, 3200.0),
            FlSpot(8.0, 5000.0),
            FlSpot(10.0, 7500.0),
          ],
        );
    }
  }

  Widget _buildNavChart() {
    final chartData = _getChartData();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NAV',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '₹7,500',
            style: TextStyle(
              color: kDarkGreen,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            chartData.changeLabel,
            style: TextStyle(
              color: chartData.changeColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  drawHorizontalLine: true,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.shade200,
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                  getDrawingVerticalLine: (value) => FlLine(
                    color: Colors.grey.shade200,
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: chartData.intervalY,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          meta: meta,
                          space: 8.0,
                          child: Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 2,
                      getTitlesWidget: (value, meta) {
                        String text = '';
                        int idx = (value.toInt() ~/ 2);
                        if (idx >= 0 && idx < chartData.xLabels.length) {
                          text = chartData.xLabels[idx];
                        }
                        return SideTitleWidget(
                          meta: meta,
                          space: 8.0,
                          child: Text(
                            text,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 10,
                minY: chartData.minY,
                maxY: chartData.maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: chartData.spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: kDarkGreen,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildTimeFrame('1m', 0),
                const SizedBox(width: 8),
                _buildTimeFrame('3m', 1),
                const SizedBox(width: 8),
                _buildTimeFrame('6m', 2),
                const SizedBox(width: 8),
                _buildTimeFrame('1y', 3),
                const SizedBox(width: 8),
                _buildTimeFrame('3y', 4),
                const SizedBox(width: 8),
                _buildTimeFrame('5y', 5),
                const SizedBox(width: 8),
                _buildTimeFrame('max', 6),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeFrame(String label, int index) {
    bool isSelected = index == _selectedTimeframe;
    return GestureDetector(
      onTap: () => setState(() => _selectedTimeframe = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? kDarkGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : kDarkGreen,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestedStocks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Market',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w900,
            fontSize: 28,
            letterSpacing: -1,
          ),
        ),
        const Text(
          'Suggested Stock Prices',
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildStockRow(
                'INFY',
                'Infosys Ltd',
                '1,316',
                '+0.82',
                true,
                [1305, 1318, 1310, 1322, 1316],
              ),
              Divider(color: Colors.grey.shade100, height: 1),
              _buildStockRow(
                'TCS',
                'Tata Consultancy',
                '2,573',
                '+0.71',
                true,
                [2554, 2580, 2570, 2590, 2573],
              ),
              Divider(color: Colors.grey.shade100, height: 1),
              _buildStockRow(
                'RELIANCE',
                'Reliance Industries',
                '1,345',
                '+0.13',
                true,
                [1344, 1350, 1340, 1348, 1345],
              ),
              Divider(color: Colors.grey.shade100, height: 1),
              _buildStockRow(
                'HDFCBANK',
                'HDFC Bank Ltd',
                '794',
                '-1.96',
                false,
                [810, 805, 812, 798, 794],
              ),
              Divider(color: Colors.grey.shade100, height: 1),
              _buildStockRow(
                'WIPRO',
                'Wipro Ltd',
                '210',
                '+0.19',
                true,
                [209, 211, 210, 212, 210],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStockRow(
    String symbol,
    String name,
    String price,
    String change,
    bool isUp,
    List<double> history,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StockAnalysisScreen(
              symbol: symbol,
              name: name,
              price: price,
              change: change,
              isUp: isUp,
              history: history,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    symbol,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      color: kDarkGreen,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 60,
              height: 30,
              child: CustomPaint(
                painter: MiniGraphPainter(
                  history,
                  isUp ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                ),
              ),
            ),
            const SizedBox(width: 20),
            SizedBox(
              width: 90,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹$price',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      color: kDarkGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        isUp ? Icons.trending_up : Icons.trending_down,
                        color: isUp ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$change%',
                        style: TextStyle(
                          color: isUp ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveIPOs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Live IPOs',
          style: TextStyle(
            color: kDarkGreen,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          clipBehavior: Clip.none,
          child: Row(
            children: [
              _buildIPOCard(
                'Emiac Technologies Ltd',
                '27 Mar - 8 Apr',
                '₹93-₹98',
                lotSize: 150,
                minAmount: '₹14,700',
              ),
              const SizedBox(width: 16),
              _buildIPOCard(
                'Safety Controls & Instrumentation Ltd',
                '6 Apr - 8 Apr',
                '₹75-₹80',
                lotSize: 180,
                minAmount: '₹14,400',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIPOCard(String name, String date, String priceRange,
      {required int lotSize, required String minAmount}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IPOApplicationScreen(
              companyName: name,
              dates: date,
              priceRange: priceRange,
              lotSize: lotSize,
              minAmount: minAmount,
            ),
          ),
        );
      },
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey.shade100,
              radius: 18,
              child: Icon(Icons.business_outlined, color: kDarkGreen, size: 18),
            ),
            const SizedBox(height: 20),
            Text(
              name,
              style: TextStyle(
                color: kDarkGreen,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              date,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Price Range',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              priceRange,
              style: TextStyle(
                color: kDarkGreen,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  'Apply Now!',
                  style: TextStyle(
                    color: Colors.blue.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.blue.shade600,
                  size: 14,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFnODistribution() {
    final chartData = _getFnOLineChartData();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'F&O Distribution',
            style: TextStyle(
              color: kDarkGreen,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: TweenAnimationBuilder<double>(
                  key: const ValueKey('fnO_donut_chart'),
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return CustomPaint(
                      painter: DonutPainter(
                        0.58,
                        kDarkGreen,
                        Colors.red.shade700,
                        value,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(backgroundColor: kDarkGreen, radius: 4),
                      const SizedBox(width: 8),
                      const Text(
                        'Call OI',
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                      const SizedBox(width: 48),
                      const Text(
                        '58%',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.red.shade700,
                        radius: 4,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Put OI',
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                      const SizedBox(width: 48),
                      const Text(
                        '42%',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nifty 50 Futures',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '22,514.00',
                    style: TextStyle(
                      color: kDarkGreen,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    chartData.changeLabel,
                    style: TextStyle(
                      color: chartData.changeColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  drawHorizontalLine: true,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.shade200,
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                  getDrawingVerticalLine: (value) => FlLine(
                    color: Colors.grey.shade200,
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      interval: chartData.intervalY,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          meta: meta,
                          space: 8.0,
                          child: Text(
                            '${(value / 1000).toInt()}k',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 2,
                      getTitlesWidget: (value, meta) {
                        String text = '';
                        int idx = (value.toInt() ~/ 2);
                        if (idx >= 0 && idx < chartData.xLabels.length) {
                          text = chartData.xLabels[idx];
                        }
                        return SideTitleWidget(
                          meta: meta,
                          space: 8.0,
                          child: Text(
                            text,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 10,
                minY: chartData.minY,
                maxY: chartData.maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: chartData.spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: kDarkGreen,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: kDarkGreen.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: ['1m', '3m', '6m', '1y', '3y', '5y', 'max'].map((t) {
                int index = [
                  '1m',
                  '3m',
                  '6m',
                  '1y',
                  '3y',
                  '5y',
                  'max',
                ].indexOf(t);
                bool isSelected = _selectedFnOTimeframe == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFnOTimeframe = index),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? kDarkGreen : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      t,
                      style: TextStyle(
                        color: isSelected ? Colors.white : kDarkGreen,
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  _ChartData _getFnOLineChartData() {
    switch (_selectedFnOTimeframe) {
      case 0:
        return _ChartData(
          changeLabel: '-135.50 (-0.60%)',
          changeColor: Colors.red.shade700,
          minY: 22000,
          maxY: 23000,
          intervalY: 500,
          xLabels: ['9:15', '10:30', '11:45', '13:00', '14:15', '15:30'],
          spots: const [
            FlSpot(0, 22650),
            FlSpot(2, 22500),
            FlSpot(4, 22520),
            FlSpot(6, 22400),
            FlSpot(8, 22450),
            FlSpot(10, 22514),
          ],
        );
      case 1:
        return _ChartData(
          changeLabel: '+1,200 (+5.6%)',
          changeColor: const Color(0xFF63977B),
          minY: 21000,
          maxY: 23000,
          intervalY: 1000,
          xLabels: ['Jan', '', 'Feb', '', 'Mar', 'Today'],
          spots: const [
            FlSpot(0, 21300),
            FlSpot(2, 21850),
            FlSpot(4, 22100),
            FlSpot(6, 22000),
            FlSpot(8, 22500),
            FlSpot(10, 22514),
          ],
        );
      case 2:
        return _ChartData(
          changeLabel: '+2,500 (+12.5%)',
          changeColor: const Color(0xFF63977B),
          minY: 19000,
          maxY: 23000,
          intervalY: 1000,
          xLabels: ['Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar'],
          spots: const [
            FlSpot(0, 19500),
            FlSpot(2, 20200),
            FlSpot(4, 21500),
            FlSpot(6, 21850),
            FlSpot(8, 22100),
            FlSpot(10, 22514),
          ],
        );
      case 3:
        return _ChartData(
          changeLabel: '+5,300 (+30.8%)',
          changeColor: const Color(0xFF63977B),
          minY: 16000,
          maxY: 24000,
          intervalY: 2000,
          xLabels: ['Apr', 'Jul', 'Oct', 'Jan', 'Mar', 'Today'],
          spots: const [
            FlSpot(0, 17200),
            FlSpot(2, 19500),
            FlSpot(4, 19200),
            FlSpot(6, 21850),
            FlSpot(8, 22400),
            FlSpot(10, 22514),
          ],
        );
      case 4:
        return _ChartData(
          changeLabel: '+8,500 (+60.7%)',
          changeColor: const Color(0xFF63977B),
          minY: 14000,
          maxY: 24000,
          intervalY: 2000,
          xLabels: ['Jan 23', 'Jul 23', 'Jan 24', 'Jul 24', 'Jan 25', 'Apr 26'],
          spots: const [
            FlSpot(0, 14000),
            FlSpot(2, 15500),
            FlSpot(4, 17200),
            FlSpot(6, 19500),
            FlSpot(8, 21500),
            FlSpot(10, 22514),
          ],
        );
      case 5:
        return _ChartData(
          changeLabel: '+12,000 (+114.2%)',
          changeColor: const Color(0xFF63977B),
          minY: 8000,
          maxY: 24000,
          intervalY: 4000,
          xLabels: ['2019', '2020', '2021', '2022', '2023', '2024'],
          spots: const [
            FlSpot(0, 10500),
            FlSpot(2, 8500),
            FlSpot(4, 15000),
            FlSpot(6, 18100),
            FlSpot(8, 21500),
            FlSpot(10, 22514),
          ],
        );
      case 6:
      default:
        return _ChartData(
          changeLabel: '+20,000 (+800.0%)',
          changeColor: const Color(0xFF63977B),
          minY: 0,
          maxY: 24000,
          intervalY: 4000,
          xLabels: ['2010', '2013', '2016', '2019', '2022', '2024'],
          spots: const [
            FlSpot(0, 2500),
            FlSpot(2, 6000),
            FlSpot(4, 8500),
            FlSpot(6, 12000),
            FlSpot(8, 18100),
            FlSpot(10, 22514),
          ],
        );
    }
  }

  Widget _buildScreenersSection() {
    bool isSplit = _activeScreenerIndex != null;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Panel (Fixed Width if Split)
            Expanded(
              flex: isSplit ? 1 : 1,
              child: Container(
                padding: EdgeInsets.all(isSplit ? 8 : 16),
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
                        Expanded(
                          child: Text(
                            'Screeners',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: kDarkGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: isSplit ? 2 : 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: isSplit ? 0.8 : 0.85,
                      children: [
                        _buildEnhancedScreenerCard(
                          0,
                          'Highest OI CPR',
                          Icons.bar_chart_rounded,
                          'C/P',
                          'Highest Open Interest Call-to-Put Ratio: Bullish indicator',
                        ),
                        _buildEnhancedScreenerCard(
                          1,
                          'Highest OI PCR',
                          Icons.bar_chart_rounded,
                          'P/C',
                          'Highest Open Interest Put-to-Call Ratio: Bearish indicator',
                        ),
                        _buildEnhancedScreenerCard(
                          2,
                          'Highest Vol.\nCPR',
                          Icons.bar_chart_rounded,
                          'C/P',
                          'Instruments with peak Call Volume over Put Volume',
                        ),
                        _buildEnhancedScreenerCard(
                          3,
                          'Highest Vol.\nPCR',
                          Icons.bar_chart_rounded,
                          'P/C',
                          'Instruments with peak Put Volume over Call Volume',
                        ),
                        _buildEnhancedScreenerCard(
                          4,
                          'Unusual Call\nVolume',
                          Icons.arrow_upward_rounded,
                          null,
                          'Unusual surge in Call Option contracts: Long buildup',
                        ),
                        _buildEnhancedScreenerCard(
                          5,
                          'Unusual Put\nVolume',
                          Icons.arrow_downward_rounded,
                          null,
                          'Unusual surge in Put Option contracts: Short buildup',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Right Panel (Simulated Redirect/Result Page)
            if (isSplit) ...[
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 650),
                  child: _buildScreenerResultPanel(),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildEnhancedScreenerCard(
    int index,
    String title,
    IconData icon,
    String? badge,
    String? tooltip, {
    bool hasNotification = false,
  }) {
    bool isHovered = _hoveredScreenerIndex == index;
    bool isActive = _activeScreenerIndex == index;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hoveredScreenerIndex = index),
      onExit: (_) => setState(() => _hoveredScreenerIndex = null),
      child: GestureDetector(
        onTap: () => setState(
          () => _activeScreenerIndex = (_activeScreenerIndex == index
              ? null
              : index),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Tooltip
            if (isHovered && tooltip != null)
              Positioned(
                top: -30,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tooltip,
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
              ),

            // Card body
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9F8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive
                      ? Colors.blue.shade400
                      : (isHovered ? Colors.grey.shade300 : Colors.transparent),
                  width: isActive ? 2 : 1,
                ),
                boxShadow: [
                  if (isHovered || isActive)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(icon, color: kDarkGreen, size: 24),
                            ),
                            if (badge != null)
                              Positioned(
                                top: -4,
                                right: -4,
                                child: Text(
                                  badge,
                                  style: const TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            // Notification bubble
                            if (hasNotification)
                              Positioned(
                                top: -8,
                                right: -8,
                                child: ScaleTransition(
                                  scale: _pulseAnimation,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Text(
                                      '4',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: kDarkGreen,
                            fontSize: 10,
                            fontWeight: isActive
                                ? FontWeight.bold
                                : FontWeight.w500,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getScreenerTitle(int index) {
    switch (index) {
      case 0:
        return 'Highest OI CPR';
      case 1:
        return 'Highest OI PCR';
      case 2:
        return 'Highest Vol. CPR';
      case 3:
        return 'Highest Vol. PCR';
      case 4:
        return 'Unusual Call Volume';
      case 5:
        return 'Unusual Put Volume';
      default:
        return 'Results';
    }
  }

  Widget _buildScreenerResultPanel() {
    int index = _activeScreenerIndex ?? 0;
    String title = _getScreenerTitle(index);
    bool isBullish = index % 2 == 0 || index == 4;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBF9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Results: $title',
                  style: TextStyle(
                    color: Color(0xFF1F5D3A),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => setState(() => _activeScreenerIndex = null),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Dynamic Status Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isBullish
                  ? const Color(0xFFF0F9F5)
                  : const Color(0xFFFFF5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  isBullish ? Icons.check_circle : Icons.warning_rounded,
                  color: isBullish
                      ? const Color(0xFF2E7D32)
                      : Colors.red.shade700,
                  size: 28,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isBullish
                            ? 'Filter Status: Bullish Bias'
                            : 'Filter Status: Bearish Bias',
                        softWrap: true,
                        style: TextStyle(
                          color: kDarkGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        isBullish
                            ? 'Showing instruments with strong accumulation'
                            : 'Showing instruments with potential distribution',
                        softWrap: true,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Filters Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildFilterBadge('Nifty 50 only'),
                const SizedBox(width: 8),
                _buildFilterBadge('Index Futures'),
                const SizedBox(width: 8),
                _buildFilterBadge('Exp: Current Month'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Data Table
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              physics: const BouncingScrollPhysics(),
              child: _buildScreenerDataTable(),
            ),
          ),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BankTransferScreen(
                      toAccount: "987654321012",
                      toIfsc: "PSIB0001234",
                      toNominee: "PSB Investment Portal",
                      toBank: "Punjab National Bank",
                      amount: "25000.00",
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kDarkGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Trade RELIANCE Options',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, color: Colors.black87),
      ),
    );
  }

  Widget _buildScreenerDataTable() {
    int index = _activeScreenerIndex ?? 0;
    bool isBullish = index % 2 == 0 || index == 4;

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  'Instrument',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'PCR',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'OI (Units)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'Trend',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Rating',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        if (isBullish) ...[
          _buildScreenerDataRow(
            'RELIANCE',
            '1.72',
            '3.1M',
            [10, 15, 12, 18, 25, 23, 28],
            'Strong Buy',
            Colors.green,
            Icons.trending_up,
            0,
          ),
          _buildScreenerDataRow(
            'INFY',
            '1.65',
            '2.8M',
            [20, 18, 19, 21, 20, 22, 21],
            'Buy',
            Colors.green,
            Icons.trending_up,
            1,
          ),
          _buildScreenerDataRow(
            'HDFC BANK',
            '1.58',
            '4.2M',
            [15, 12, 10, 8, 12, 11, 13],
            'Wait',
            Colors.orange,
            Icons.trending_flat,
            2,
          ),
          _buildScreenerDataRow(
            'ICICI BANK',
            '1.45',
            '3.5M',
            [5, 8, 12, 10, 15, 14, 16],
            'Neutral',
            Colors.grey,
            Icons.trending_flat,
            3,
          ),
          _buildScreenerDataRow(
            'TCS',
            '1.30',
            '2.1M',
            [30, 25, 20, 15, 12, 10, 8],
            'Hold',
            Colors.orange,
            Icons.trending_flat,
            4,
          ),
        ] else ...[
          _buildScreenerDataRow(
            'ADANIENT',
            '0.65',
            '1.2M',
            [30, 28, 25, 22, 18, 15, 10],
            'Strong Sell',
            Colors.red,
            Icons.trending_down,
            5,
          ),
          _buildScreenerDataRow(
            'WIPRO',
            '0.72',
            '1.8M',
            [20, 22, 21, 19, 18, 17, 16],
            'Sell',
            Colors.red,
            Icons.trending_down,
            6,
          ),
          _buildScreenerDataRow(
            'TATAMOTORS',
            '0.85',
            '2.5M',
            [10, 12, 11, 13, 14, 15, 14],
            'Hold',
            Colors.orange,
            Icons.trending_flat,
            7,
          ),
          _buildScreenerDataRow(
            'BHARTIARTL',
            '0.90',
            '1.9M',
            [5, 6, 8, 7, 9, 8, 10],
            'Neutral',
            Colors.grey,
            Icons.trending_flat,
            8,
          ),
          _buildScreenerDataRow(
            'SBIN',
            '0.95',
            '3.8M',
            [15, 14, 15, 16, 17, 16, 18],
            'Wait',
            Colors.orange,
            Icons.trending_flat,
            9,
          ),
        ],
      ],
    );
  }

  Widget _buildScreenerDataRow(
    String name,
    String pcr,
    String oi,
    List<double> trend,
    String rating,
    Color ratingColor,
    IconData trendIcon,
    int rowIndex,
  ) {
    bool isHovered = _hoveredTableRowIndex == rowIndex;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hoveredTableRowIndex = rowIndex),
      onExit: (_) => setState(() => _hoveredTableRowIndex = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: isHovered
              ? Colors.blue.withValues(alpha: 0.03)
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.05)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                name,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: kDarkGreen,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                pcr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                oi,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),
            Expanded(
              flex: 3,
              child: Center(child: _buildMiniSparkline(trend, ratingColor)),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: ratingColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(trendIcon, size: 10, color: ratingColor),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        rating,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: ratingColor,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildMiniSparkline(List<double> data, Color color) {
    if (data.length < 2) {
      return const SizedBox.shrink(); // fl_chart needs at least 2 points
    }

    return SizedBox(
      height: 20,
      width: 50,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: data
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value))
                  .toList(),
              isCurved: true,
              color: color,
              barWidth: 1.5,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: color.withValues(alpha: 0.05),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionChainSection() {
    return Container(
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
              Row(
                children: [
                  Text(
                    'Option Chain ',
                    style: TextStyle(
                      color: kDarkGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    _selectedOptionChainIndex == 1 ? '11 Apr \u25BE' : '07 Apr \u25BE',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFnOTab('Nifty 50', _selectedOptionChainIndex == 0, () => setState(() => _selectedOptionChainIndex = 0)),
                const SizedBox(width: 16),
                _buildFnOTab('BSE Sensex', _selectedOptionChainIndex == 1, () => setState(() => _selectedOptionChainIndex = 1)),
                const SizedBox(width: 16),
                _buildFnOTab('Nifty Bank', _selectedOptionChainIndex == 2, () => setState(() => _selectedOptionChainIndex = 2)),
                const SizedBox(width: 16),
                _buildFnOTab('Nifty Financial', _selectedOptionChainIndex == 3, () => setState(() => _selectedOptionChainIndex = 3)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Call LTP (Chg %)',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
              ),
              Text(
                'Strike Price',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
              ),
              Text(
                'Put LTP (Chg %)',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildOptionChainRows(),
          const SizedBox(height: 16),
          _buildOptionChainSpotBar(),
          const SizedBox(height: 16),
          _buildOptionChainRows(isAfterSpot: true),
        ],
      ),
    );
  }

  Widget _buildOptionChainRows({bool isAfterSpot = false}) {
    // Return different data based on _selectedOptionChainIndex
    if (_selectedOptionChainIndex == 0) {
      // Nifty 50
      return Column(
        children: isAfterSpot
            ? [
                _buildOptionChainRow('241.70', '-17.42%', '22750', '-10.39%', '284.60'),
                const SizedBox(height: 12),
                _buildOptionChainRow('217.25', '-18.8%', '22800', '-9.63%', '309.55'),
              ]
            : [
                _buildOptionChainRow('298.90', '-13.6%', '22650', '-11.22%', '242.05'),
                const SizedBox(height: 12),
                _buildOptionChainRow('269.15', '-15.45%', '22700', '-10.57%', '263.55'),
              ],
      );
    } else if (_selectedOptionChainIndex == 1) {
      // BSE Sensex
      return Column(
        children: isAfterSpot
            ? [
                _buildOptionChainRow('845.20', '-8.12%', '74800', '-5.22%', '790.15'),
                const SizedBox(height: 12),
                _buildOptionChainRow('782.45', '-9.45%', '74900', '-4.88%', '865.30'),
              ]
            : [
                _buildOptionChainRow('1012.30', '-6.45%', '74600', '-7.15%', '642.50'),
                const SizedBox(height: 12),
                _buildOptionChainRow('928.75', '-7.22%', '74700', '-6.80%', '712.95'),
              ],
      );
    } else if (_selectedOptionChainIndex == 2) {
      // Nifty Bank
      return Column(
        children: isAfterSpot
            ? [
                _buildOptionChainRow('542.80', '+2.14%', '48600', '-8.45%', '612.35'),
                const SizedBox(height: 12),
                _buildOptionChainRow('498.15', '+1.88%', '48700', '-7.90%', '678.90'),
              ]
            : [
                _buildOptionChainRow('654.20', '+3.45%', '48400', '-10.12%', '512.60'),
                const SizedBox(height: 12),
                _buildOptionChainRow('598.75', '+2.90%', '48500', '-9.50%', '564.25'),
              ],
      );
    } else {
      // Nifty Financial
      return Column(
        children: isAfterSpot
            ? [
                _buildOptionChainRow('212.45', '-1.22%', '21450', '+2.45%', '245.60'),
                const SizedBox(height: 12),
                _buildOptionChainRow('195.80', '-1.45%', '21500', '+2.88%', '272.35'),
              ]
            : [
                _buildOptionChainRow('258.90', '-0.85%', '21350', '+1.12%', '198.45'),
                const SizedBox(height: 12),
                _buildOptionChainRow('234.15', '-1.05%', '21400', '+1.25%', '220.80'),
              ],
      );
    }
  }

  Widget _buildOptionChainSpotBar() {
    String label = '';
    switch (_selectedOptionChainIndex) {
      case 0:
        label = '\u20B9 22,713.10 (+0.15%) Short Built Up';
        break;
      case 1:
        label = '\u20B9 74,742.50 (+0.12%) Long Built Up';
        break;
      case 2:
        label = '\u20B9 48,512.30 (+0.25%) Strong Trend';
        break;
      case 3:
        label = '\u20B9 21,385.20 (+0.08%) Volatile';
        break;
      default:
        label = '';
    }

    return Row(
      children: [
        Expanded(child: Container(height: 1, color: kDarkGreen)),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: kDarkGreen,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: kDarkGreen)),
      ],
    );
  }

  Widget _buildFnOTab(String t, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? kDarkGreen : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          t,
          style: TextStyle(
            color: isSelected ? kDarkGreen : Colors.grey.shade500,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildOptionChainRow(
    String cl,
    String cp,
    String sp,
    String pp,
    String pl,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Text(cl, style: TextStyle(color: kDarkGreen, fontSize: 13)),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    cp,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.red.shade700, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  sp,
                  style: TextStyle(
                    color: kDarkGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    pp,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.red.shade700, fontSize: 11),
                  ),
                ),
                const SizedBox(width: 4),
                Text(pl, style: TextStyle(color: kDarkGreen, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFIIDIISection() {
    return Container(
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
                'FII/DII Activity',
                style: TextStyle(
                  color: kDarkGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FIIDIIInsightsScreen()),
                  );
                },
                child: Text(
                  'View Insights',
                  style: TextStyle(
                    color: Colors.blue.shade600,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue.shade500,
                      radius: 4,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Market Pulse: 02 Apr 2026',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.share_outlined,
                      color: Colors.grey.shade600,
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'FII: ',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                          TextSpan(
                            text: '- \u20B99,931.13 Cr',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'DII: ',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                          TextSpan(
                            text: '+ \u20B97,208.41 Cr',
                            style: TextStyle(
                              color: kDarkGreen,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.grey.shade300, height: 1),
                const SizedBox(height: 12),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Nifty 50: ',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      TextSpan(
                        text: '22,713.10 ',
                        style: TextStyle(
                          color: kDarkGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(
                        text: '(+0.15%)',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'FII Index Future: ',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      TextSpan(
                        text: '- \u20B9465.16 Cr',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketMoversSection() {
    return Container(
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
                'Market Movers',
                style: TextStyle(
                  color: kDarkGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildMarketMoverTab('Popular Search', 0, null),
                const SizedBox(width: 16),
                _buildMarketMoverTab(
                  'Price Gainers',
                  1,
                  const PriceGainersScreen(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Options Contract',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
              ),
              Text(
                'LTP',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMarketMoverRow(
            'NIFTY 07 APR 23000 CALL',
            '130.00',
            '-51.55 (28.39%)',
          ),
          Divider(color: Colors.grey.shade200),
          _buildMarketMoverRow(
            'NIFTY 07 APR 22300 PUT',
            '129.15',
            '-21.90 (14.50%)',
          ),
          Divider(color: Colors.grey.shade200),
          _buildMarketMoverRow(
            'NIFTY 07 APR 22000 PUT',
            '72.00',
            '-15.05 (17.29%)',
          ),
        ],
      ),
    );
  }

  Widget _buildMarketMoverTab(String label, int index, Widget? targetScreen) {
    bool isSelected =
        index == 0; // Defaulting first tab as selected for UI simulation
    return GestureDetector(
      onTap: () {
        if (targetScreen != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => targetScreen),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.blue.shade500 : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? kDarkGreen : Colors.grey.shade500,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildMarketMoverRow(String contract, String ltp, String cltp) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contract,
              style: TextStyle(
                color: kDarkGreen,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'NSE',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              ltp,
              style: TextStyle(
                color: kDarkGreen,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              cltp,
              style: TextStyle(color: Colors.red.shade700, fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopFunds() {
    return Container(
      padding: const EdgeInsets.all(20),
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
                'Top Performing Funds',
                style: TextStyle(
                  color: kDarkGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
          ],
          ),
          const SizedBox(height: 20),
          _buildFundRow(
            'Quant Small Cap Fund',
            'Equity \u2022 Small Cap',
            '45.2%',
          ),
          Divider(color: Colors.grey.shade100, thickness: 1, height: 32),
          _buildFundRow(
            'Parag Parikh Flexi Cap',
            'Equity \u2022 Flexi Cap',
            '28.5%',
          ),
          Divider(color: Colors.grey.shade100, thickness: 1, height: 32),
          _buildFundRow(
            'Nippon India Small Cap',
            'Equity \u2022 Small Cap',
            '41.8%',
          ),
          Divider(color: Colors.grey.shade100, thickness: 1, height: 32),
          _buildFundRow(
            'HDFC Mid-Cap Opportunities',
            'Equity \u2022 Mid Cap',
            '34.2%',
          ),
        ],
      ),
    );
  }

  Widget _buildFundRow(String name, String category, String return3Y) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FundDetailScreen(fundName: name),
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: kDarkGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    return3Y,
                    style: const TextStyle(
                      color: Color(0xFF63977B),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '3Y Return',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => QuickCheckoutModal.show(context, name, '214.20'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: kDarkGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Invest',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMFSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mutual Fund Portfolio',
            style: TextStyle(
              color: kDarkGreen,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              SizedBox(
                width: 110,
                height: 110,
                child: TweenAnimationBuilder<double>(
                  key: const ValueKey('mf_pie_chart'),
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return CustomPaint(
                      painter: PiePainter(
                        0.60,
                        0.25,
                        0.15,
                        kDarkGreen,
                        kOrange,
                        const Color(0xFF3282B8),
                        value,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 28),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Value',
                      style: TextStyle(
                        color: kDarkGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '₹1,25,000',
                      style: TextStyle(
                        color: kDarkGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Total Returns',
                      style: TextStyle(
                        color: kDarkGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹25,000',
                          style: TextStyle(
                            color: kDarkGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            '+25%',
                            style: TextStyle(
                              color: kDarkGreen,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(backgroundColor: kDarkGreen, radius: 5),
                  const SizedBox(width: 6),
                  Text(
                    'Equity (60%)',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                  ),
                ],
              ),
              Row(
                children: [
                  CircleAvatar(backgroundColor: kOrange, radius: 5),
                  const SizedBox(width: 6),
                  Text(
                    'Debt (25%)',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                  ),
                ],
              ),
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF3282B8),
                    radius: 5,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Hybrid (15%)',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMFChart() {
    final chartData = _getMFChartData();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Portfolio Trend',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '₹1,25,000',
            style: TextStyle(
              color: kDarkGreen,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            chartData.changeLabel,
            style: TextStyle(
              color: chartData.changeColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  drawHorizontalLine: true,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.shade200,
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                  getDrawingVerticalLine: (value) => FlLine(
                    color: Colors.grey.shade200,
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      interval: chartData.intervalY,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          meta: meta,
                          space: 8.0,
                          child: Text(
                            '${(value / 1000).toInt()}k',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 2,
                      getTitlesWidget: (value, meta) {
                        String text = '';
                        int idx = (value.toInt() ~/ 2);
                        if (idx >= 0 && idx < chartData.xLabels.length) {
                          text = chartData.xLabels[idx];
                        }
                        return SideTitleWidget(
                          meta: meta,
                          space: 8.0,
                          child: Text(
                            text,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 10,
                minY: chartData.minY,
                maxY: chartData.maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: chartData.spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: kDarkGreen,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: kDarkGreen.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: ['1m', '3m', '6m', '1y', '3y', '5y', 'max'].map((t) {
                int index = [
                  '1m',
                  '3m',
                  '6m',
                  '1y',
                  '3y',
                  '5y',
                  'max',
                ].indexOf(t);
                bool isSelected = _selectedMFTimeframe == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedMFTimeframe = index),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? kDarkGreen : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      t,
                      style: TextStyle(
                        color: isSelected ? Colors.white : kDarkGreen,
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveNFOs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Live NFOs',
              style: TextStyle(
                color: kDarkGreen,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          clipBehavior: Clip.none,
          child: Row(
            children: [
              _buildNFOCard('HDFC Nifty Next 50', 'Closes 19 Apr', '₹500'),
              const SizedBox(width: 16),
              _buildNFOCard('SBI Innovation Opp.', 'Closes 22 Apr', '₹5,000'),
              const SizedBox(width: 16),
              _buildNFOCard(
                'ICICI Pru Business Cycle',
                'Closes 24 Apr',
                '₹1,000',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNFOCard(String name, String date, String minInvestment) {
    return GestureDetector(
      onTap: () {
        Widget screen;
        if (name.contains('HDFC')) {
          screen = const HDFCIndexNFOScreen();
        } else if (name.contains('SBI')) {
          screen = const SBIInnovationNFOScreen();
        } else {
          screen = const ICICIBusinessCycleNFOScreen();
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue.shade50,
              radius: 18,
              child: Icon(
                Icons.trending_up,
                color: Colors.blue.shade600,
                size: 20,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              name,
              style: TextStyle(
                color: kDarkGreen,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              date,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Min. Investment',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              minInvestment,
              style: TextStyle(
                color: kDarkGreen,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Apply Now!',
              style: TextStyle(
                color: kDarkGreen,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _ChartData _getMFChartData() {
    switch (_selectedMFTimeframe) {
      case 0:
        return _ChartData(
          changeLabel: '+₹4,200 (+3.4%)',
          changeColor: const Color(0xFF63977B),
          minY: 115000,
          maxY: 130000,
          intervalY: 5000,
          xLabels: ['1 Mar', '7 Mar', '14 Mar', '21 Mar', '28 Mar', 'Today'],
          spots: const [
            FlSpot(0, 120800),
            FlSpot(2, 119500),
            FlSpot(4, 122000),
            FlSpot(6, 121500),
            FlSpot(8, 123000),
            FlSpot(10, 125000),
          ],
        );
      case 1:
        return _ChartData(
          changeLabel: '+₹12,500 (+11.1%)',
          changeColor: const Color(0xFF63977B),
          minY: 100000,
          maxY: 130000,
          intervalY: 10000,
          xLabels: ['Jan', '', 'Feb', '', 'Mar', 'Today'],
          spots: const [
            FlSpot(0, 112500),
            FlSpot(2, 115000),
            FlSpot(4, 114000),
            FlSpot(6, 118000),
            FlSpot(8, 121000),
            FlSpot(10, 125000),
          ],
        );
      case 2:
        return _ChartData(
          changeLabel: '+₹18,000 (+16.8%)',
          changeColor: const Color(0xFF63977B),
          minY: 90000,
          maxY: 130000,
          intervalY: 10000,
          xLabels: ['Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar'],
          spots: const [
            FlSpot(0, 107000),
            FlSpot(2, 109000),
            FlSpot(4, 113000),
            FlSpot(6, 111000),
            FlSpot(8, 118000),
            FlSpot(10, 125000),
          ],
        );
      case 3:
        return _ChartData(
          changeLabel: '+₹25,000 (+25.0%)',
          changeColor: const Color(0xFF63977B),
          minY: 80000,
          maxY: 140000,
          intervalY: 20000,
          xLabels: ['Apr', 'Jul', 'Oct', 'Jan', 'Mar', 'Today'],
          spots: const [
            FlSpot(0, 100000),
            FlSpot(2, 105000),
            FlSpot(4, 102000),
            FlSpot(6, 112000),
            FlSpot(8, 119000),
            FlSpot(10, 125000),
          ],
        );
      case 4:
        return _ChartData(
          changeLabel: '+₹65,000 (+108.33%)',
          changeColor: const Color(0xFF63977B),
          minY: 50000,
          maxY: 150000,
          intervalY: 25000,
          xLabels: ['Jan 23', 'Jul 23', 'Jan 24', 'Jul 24', 'Jan 25', 'Apr 26'],
          spots: const [
            FlSpot(0, 60000),
            FlSpot(1, 65000),
            FlSpot(2, 63000),
            FlSpot(3, 75000),
            FlSpot(4, 85000),
            FlSpot(5, 82000),
            FlSpot(6, 95000),
            FlSpot(7, 105000),
            FlSpot(8, 100000),
            FlSpot(9, 115000),
            FlSpot(10, 125000),
          ],
        );
      case 5:
        return _ChartData(
          changeLabel: '+₹85,000 (+212.5%)',
          changeColor: const Color(0xFF63977B),
          minY: 20000,
          maxY: 140000,
          intervalY: 30000,
          xLabels: ['2019', '2020', '2021', '2022', '2023', '2024'],
          spots: const [
            FlSpot(0, 40000),
            FlSpot(2, 45000),
            FlSpot(4, 70000),
            FlSpot(6, 85000),
            FlSpot(8, 100000),
            FlSpot(10, 125000),
          ],
        );
      case 6:
      default:
        return _ChartData(
          changeLabel: '+₹1,05,000 (+525.0%)',
          changeColor: const Color(0xFF63977B),
          minY: 0,
          maxY: 150000,
          intervalY: 30000,
          xLabels: ['2015', '2017', '2019', '2021', '2023', '2024'],
          spots: const [
            FlSpot(0, 20000),
            FlSpot(2, 35000),
            FlSpot(4, 45000),
            FlSpot(6, 85000),
            FlSpot(8, 110000),
            FlSpot(10, 125000),
          ],
        );
    }
  }
}

class PiePainter extends CustomPainter {
  final double percentage1;
  final double percentage2;
  final double percentage3;
  final Color color1;
  final Color color2;
  final Color color3;
  final double scale;

  PiePainter(
    this.percentage1,
    this.percentage2,
    this.percentage3,
    this.color1,
    this.color2,
    this.color3,
    this.scale,
  );

  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width,
      height: size.height,
    );

    Paint paint1 = Paint()
      ..color = color1
      ..style = PaintingStyle.fill;
    Paint paint2 = Paint()
      ..color = color2
      ..style = PaintingStyle.fill;
    Paint paint3 = Paint()
      ..color = color3
      ..style = PaintingStyle.fill;

    double sweep1 = 2 * math.pi * percentage1 * scale;
    double sweep2 = 2 * math.pi * percentage2 * scale;
    double sweep3 = 2 * math.pi * percentage3 * scale;

    double startAngle = -math.pi / 2;

    canvas.drawArc(rect, startAngle, sweep1, true, paint1);
    canvas.drawArc(rect, startAngle + sweep1, sweep2, true, paint2);
    canvas.drawArc(rect, startAngle + sweep1 + sweep2, sweep3, true, paint3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DonutPainter extends CustomPainter {
  final double percentage; // eg 0.87
  final Color color1;
  final Color color2;
  final double scale;

  DonutPainter(this.percentage, this.color1, this.color2, this.scale);

  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = 24.0;
    Rect rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width - strokeWidth,
      height: size.height - strokeWidth,
    );

    Paint paint1 = Paint()
      ..color = color1
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    Paint paint2 = Paint()
      ..color = color2
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    double sweep1 = 2 * math.pi * percentage * scale;
    double sweep2 = 2 * math.pi * (1 - percentage) * scale;

    // Start at -90 degrees (top center)
    double startAngle = -math.pi / 2;

    canvas.drawArc(rect, startAngle, sweep1, false, paint1);
    canvas.drawArc(rect, startAngle + sweep1, sweep2, false, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ChartData {
  final String changeLabel;
  final Color changeColor;
  final double minY;
  final double maxY;
  final double intervalY;
  final List<String> xLabels;
  final List<FlSpot> spots;

  _ChartData({
    required this.changeLabel,
    required this.changeColor,
    required this.minY,
    required this.maxY,
    required this.intervalY,
    required this.xLabels,
    required this.spots,
  });
}

class MiniGraphPainter extends CustomPainter {
  final List<double> data;
  final Color color;

  MiniGraphPainter(this.data, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    double min = data.reduce((a, b) => a < b ? a : b);
    double max = data.reduce((a, b) => a > b ? a : b);
    double range = max - min;
    if (range == 0) range = 1;

    for (int i = 0; i < data.length; i++) {
      double x = data.length > 1 
          ? (i / (data.length - 1)) * size.width 
          : size.width / 2;
      double y = size.height - ((data[i] - min) / range * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
