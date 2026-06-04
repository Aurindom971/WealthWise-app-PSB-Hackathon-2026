import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'actions/ipo_application_screen.dart';
import 'actions/price_gainers_screen.dart';
import 'actions/trading_idea_detail_screen.dart';
import 'actions/stock_detail_view_screen.dart';
import 'actions/dynamic_nfo_screen.dart';
import 'dart:ui';
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
import 'actions/search_stocks_screen.dart';
import 'services/investment_api_service.dart';
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
  final InvestmentApiService _apiService = InvestmentApiService();

  List<Map<String, dynamic>> _suggestedStocks = [];
  List<Map<String, dynamic>> _liveIpos = [];
  List<Map<String, dynamic>> _tradingIdeas = [];
  List<Map<String, dynamic>> _topFunds = [];
  List<Map<String, dynamic>> _liveNfos = [];

  int? _hoveredScreenerIndex;
  int? _activeScreenerIndex;
  int? _hoveredTableRowIndex;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  int _selectedTab = 0; // 0: Stocks, 1: F&O, 2: Mutual Funds, 3: Goals
  int _goalsSubView = 0; // 0: None, 1: Add Goal, 2: Track Goals, 3: Goal Details
  int _selectedGoalIndex = 0;
  double _goalsSummaryTarget = 250000;
  double _goalsSummarySaved = 157500;

  late final List<GoalItem> _goalsList = [
    GoalItem(
      name: 'Retirement Fund',
      targetText: '₹10L',
      currentText: '₹4.5L',
      progress: 0.45,
      status: 'On Track',
      icon: Icons.beach_access_rounded,
      iconBgColor: const Color(0xFFEAF1ED),
      targetValue: 1000000,
      currentValue: 450000,
    ),
    GoalItem(
      name: 'New Home',
      targetText: '₹5L',
      currentText: '₹1.25L',
      progress: 0.25,
      status: 'Delayed',
      icon: Icons.home_rounded,
      iconBgColor: const Color(0xFFEAF1ED),
      targetValue: 500000,
      currentValue: 125000,
    ),
    GoalItem(
      name: 'Vacation',
      targetText: '₹50K',
      currentText: '₹35K',
      progress: 0.70,
      status: 'Delayed',
      icon: Icons.flight_takeoff_rounded,
      iconBgColor: const Color(0xFFEAF1ED),
      targetValue: 50000,
      currentValue: 35000,
    ),
  ];

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
    
    // Seed initial data immediately before async fetch resolves
    _suggestedStocks = [
      {
        'symbol': 'INFY',
        'name': 'Infosys Ltd',
        'price': '1,316',
        'change': '+0.82',
        'isUp': true,
        'history': [1305.0, 1318.0, 1310.0, 1322.0, 1316.0],
      },
      {
        'symbol': 'TCS',
        'name': 'Tata Consultancy',
        'price': '2,573',
        'change': '+0.71',
        'isUp': true,
        'history': [2554.0, 2580.0, 2570.0, 2590.0, 2573.0],
      },
      {
        'symbol': 'RELIANCE',
        'name': 'Reliance Industries',
        'price': '1,345',
        'change': '+0.13',
        'isUp': true,
        'history': [1344.0, 1350.0, 1340.0, 1348.0, 1345.0],
      },
      {
        'symbol': 'HDFCBANK',
        'name': 'HDFC Bank Ltd',
        'price': '794',
        'change': '-1.96',
        'isUp': false,
        'history': [810.0, 805.0, 812.0, 798.0, 794.0],
      },
      {
        'symbol': 'WIPRO',
        'name': 'Wipro Ltd',
        'price': '210',
        'change': '+0.19',
        'isUp': true,
        'history': [209.0, 211.0, 210.0, 212.0, 210.0],
      },
    ];

    _liveIpos = [
      {
        'name': 'Emiac Technologies Ltd',
        'dates': '27 Mar - 8 Apr',
        'price': '₹93-₹98',
        'lot': 150,
        'min': '₹14,700',
      },
      {
        'name': 'Safety Controls & Instrumentation Ltd',
        'dates': '6 Apr - 8 Apr',
        'price': '₹75-₹80',
        'lot': 180,
        'min': '₹14,400',
      },
    ];

    _tradingIdeas = [
      {
        'contract': 'NIFTY 02 JUN 23900 CALL',
        'price': '71.50',
        'change': '-108.25 (60.22%)',
        'isUp': false,
        'buy': 128.50,
        'target': 275.00,
        'sl': 80.00,
        'provider': 'Investogainer Research',
        'funds': 6425.00,
      },
      {
        'contract': 'BANKNIFTY 30 JUN 51200 CALL',
        'price': '810.00',
        'change': '-170.55 (17.39%)',
        'isUp': false,
        'buy': 967.00,
        'target': 1351.00,
        'sl': 650.00,
        'provider': 'Lotus Funds',
        'funds': 12150.00,
      },
      {
        'contract': 'RELIANCE 30 JUN 2900 CALL',
        'price': '88.50',
        'change': '+12.40 (16.29%)',
        'isUp': true,
        'buy': 75.00,
        'target': 150.00,
        'sl': 50.00,
        'provider': 'Investogainer Research',
        'funds': 4425.00,
      },
      {
        'contract': 'TCS 30 JUN 4000 CALL',
        'price': '110.00',
        'change': '-15.55 (12.39%)',
        'isUp': false,
        'buy': 125.00,
        'target': 220.00,
        'sl': 80.00,
        'provider': 'Lotus Funds',
        'funds': 5500.00,
      },
      {
        'contract': 'INFY 30 JUN 1500 CALL',
        'price': '42.15',
        'change': '+4.80 (12.85%)',
        'isUp': true,
        'buy': 35.00,
        'target': 75.00,
        'sl': 20.00,
        'provider': 'Investogainer Research',
        'funds': 2107.50,
      },
      {
        'contract': 'BDL 30 JUN 1200 CALL',
        'price': '30.55',
        'change': '-71.27 (71.27%)',
        'isUp': false,
        'buy': 29.05,
        'target': 60.00,
        'sl': 15.00,
        'provider': 'Investogainer Research',
        'funds': 10192.42,
      },
      {
        'contract': 'ICICIBANK 30 JUN 1100 CALL',
        'price': '35.40',
        'change': '+3.80 (12.02%)',
        'isUp': true,
        'buy': 28.00,
        'target': 55.00,
        'sl': 18.00,
        'provider': 'Lotus Funds',
        'funds': 1770.00,
      },
      {
        'contract': 'SBIN 30 JUN 800 PUT',
        'price': '22.15',
        'change': '-2.10 (8.66%)',
        'isUp': false,
        'buy': 25.00,
        'target': 45.00,
        'sl': 15.00,
        'provider': 'Investogainer Research',
        'funds': 1107.50,
      },
    ];

    _topFunds = [
      {
        'name': 'Quant Small Cap Fund',
        'category': 'Equity • Small Cap',
        'return': '45.2%',
        'price': '214.20',
      },
      {
        'name': 'Parag Parikh Flexi Cap',
        'category': 'Equity • Flexi Cap',
        'return': '28.5%',
        'price': '85.40',
      },
      {
        'name': 'Nippon India Small Cap',
        'category': 'Equity • Small Cap',
        'return': '41.8%',
        'price': '135.10',
      },
      {
        'name': 'HDFC Mid-Cap Opportunities',
        'category': 'Equity • Mid Cap',
        'return': '34.2%',
        'price': '160.50',
      },
    ];

    _liveNfos = [
      {
        'name': 'HDFC Nifty Next 50',
        'date': 'Closes 19 Apr',
        'min': 500.0,
        'closesInDays': 14,
        'description': 'Tracks the Nifty Next 50 index composed of high-performing large-cap companies.',
      },
      {
        'name': 'SBI Innovation Opp.',
        'date': 'Closes 22 Apr',
        'min': 5000.0,
        'closesInDays': 17,
        'description': 'Invests in high-growth companies driving technological and business model innovations.',
      },
      {
        'name': 'ICICI Pru Business Cycle',
        'date': 'Closes 24 Apr',
        'min': 1000.0,
        'closesInDays': 19,
        'description': 'Tactical allocation across sectors based on macroeconomic business cycle transitions.',
      },
    ];

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _loadApiData();

    _goalsSummaryTarget = _goalsList.fold(0.0, (sum, item) => sum + item.targetValue);
    _goalsSummarySaved = _goalsList.fold(0.0, (sum, item) => sum + item.currentValue);
  }

  Future<void> _loadApiData() async {
    try {
      final stocks = await _apiService.fetchSuggestedStocks();
      final ipos = await _apiService.fetchLiveIpos();
      final ideas = await _apiService.fetchTradingIdeas();
      final funds = await _apiService.fetchTopFunds();
      final nfos = await _apiService.fetchLiveNfos();
      
      if (mounted) {
        setState(() {
          _suggestedStocks = stocks;
          _liveIpos = ipos;
          _tradingIdeas = ideas;
          _topFunds = funds;
          _liveNfos = nfos;
        });
      }
    } catch (e) {
      // Keep fallback values in case of error
    }
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
    if (_goalsSubView == 1) {
      return _buildAddGoalScreen();
    } else if (_goalsSubView == 2) {
      return _buildTrackGoalsScreen();
    } else if (_goalsSubView == 3) {
      return _buildGoalDetailsScreen(_selectedGoalIndex);
    }

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
            ] else if (_selectedTab == 3) ...[
              _buildGoalsSummary(),
              const SizedBox(height: 16),
              ..._buildGoalsList(),
              const SizedBox(height: 20),
              _buildGoalsActions(),
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
        const SizedBox(width: 6),
        Expanded(child: _buildTabWidget('F&O', 1)),
        const SizedBox(width: 6),
        Expanded(child: _buildTabWidget('Mutual Funds', 2)),
        const SizedBox(width: 6),
        Expanded(child: _buildTabWidget('Goals', 3)),
      ],
    );
  }

  Widget _buildTabWidget(String text, int index) {
    bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedTab = index;
        _goalsSubView = 0; // Reset sub-navigation when switching tabs
      }),
      child: Container(
        height: 45,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? kDarkGreen : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: kDarkGreen)
              : Border.all(color: Colors.grey.shade300),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : kDarkGreen,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
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
          MaterialPageRoute(builder: (context) => const MyHoldingsScreen()),
        );
      },
      child: CustomPaint(
        painter: DottedBorderPainter(
          color: Colors.grey.shade300,
          strokeWidth: 1.2,
          gap: 4,
          borderRadius: 16,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
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
                          painter: DonutPainter(
                            0.87,
                            kOrange,
                            kDarkGreen,
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

    return CustomPaint(
      painter: DottedBorderPainter(
        color: Colors.grey.shade300,
        strokeWidth: 1.2,
        gap: 4,
        borderRadius: 16,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
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
              ],
            ),
            GestureDetector(
              onTap: _showAllSuggestedStocksModal,
              child: Row(
                children: [
                  Text(
                    'View More',
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
            ),
          ],
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
            children: List.generate(_suggestedStocks.length > 5 ? 5 : _suggestedStocks.length, (index) {
              final stock = _suggestedStocks[index];
              return Column(
                children: [
                  _buildStockRow(
                    stock['symbol'] as String,
                    stock['name'] as String,
                    stock['price'] as String,
                    stock['change'] as String,
                    stock['isUp'] as bool,
                    (stock['history'] as List).cast<double>(),
                  ),
                  if (index < (_suggestedStocks.length > 5 ? 4 : _suggestedStocks.length - 1))
                    Divider(color: Colors.grey.shade100, height: 1),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  void _showAllSuggestedStocksModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Color(0xFFF2F0EB), // kCream original theme
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Suggested Stocks',
                    style: TextStyle(
                      color: kDarkGreen,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: kDarkGreen),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                itemCount: _suggestedStocks.length,
                separatorBuilder: (context, index) => Divider(color: Colors.grey.shade200, height: 16),
                itemBuilder: (context, index) {
                  final stock = _suggestedStocks[index];
                  final List<double> history = (stock['history'] as List).cast<double>();
                  final bool isUp = stock['isUp'] as bool;
                  
                  return Card(
                    color: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade100),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StockAnalysisScreen(
                              symbol: stock['symbol'] as String,
                              name: stock['name'] as String,
                              price: stock['price'] as String,
                              change: stock['change'] as String,
                              isUp: isUp,
                              history: history,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    stock['symbol'] as String,
                                    style: TextStyle(
                                      color: kDarkGreen,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    stock['name'] as String,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 12,
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
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹${stock['price']}',
                                  style: TextStyle(
                                    color: kDarkGreen,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${stock['change']}%',
                                  style: TextStyle(
                                    color: isUp ? Colors.green.shade700 : Colors.red.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
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
        decoration: const BoxDecoration(color: Colors.transparent),
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
                        color: isUp
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$change%',
                        style: TextStyle(
                          color: isUp
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
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

  void _showAllIPOsModal() {
    final ipos = _liveIpos;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Color(0xFFF2F0EB),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Live & Upcoming IPOs',
                    style: TextStyle(
                      color: kDarkGreen,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                itemCount: ipos.length,
                itemBuilder: (context, index) {
                  final ipo = ipos[index];
                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: kLightGreenBg,
                        child: Icon(Icons.business_outlined, color: kDarkGreen),
                      ),
                      title: Text(
                        ipo['name'] as String,
                        style: TextStyle(
                          color: kDarkGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Text(
                            ipo['dates'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Min. Amt: ${ipo['min']} \u2022 Lot: ${ipo['lot']} shares',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            ipo['price'] as String,
                            style: TextStyle(
                              color: kDarkGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Apply',
                            style: TextStyle(
                              color: Colors.blue.shade600,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => IPOApplicationScreen(
                              companyName: ipo['name'] as String,
                              dates: ipo['dates'] as String,
                              priceRange: ipo['price'] as String,
                              lotSize: ipo['lot'] as int,
                              minAmount: ipo['min'] as String,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAllTopFundsModal() {
    final funds = _topFunds;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Color(0xFFF2F0EB),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Top Performing Funds',
                    style: TextStyle(
                      color: kDarkGreen,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                itemCount: funds.length,
                itemBuilder: (context, index) {
                  final fund = funds[index];
                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FundDetailScreen(
                              fundName: fund['name'] as String,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fund['name'] as String,
                                    style: TextStyle(
                                      color: kDarkGreen,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    fund['category'] as String,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
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
                                      fund['return'] as String,
                                      style: const TextStyle(
                                        color: Color(0xFF63977B),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '3Y Return',
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                    QuickCheckoutModal.show(
                                      context,
                                      fund['name'] as String,
                                      fund['price'] as String,
                                    );
                                  },
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
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAllLiveNFOsModal() {
    final nfos = _liveNfos;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Color(0xFFF2F0EB),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Live & Upcoming NFOs',
                    style: TextStyle(
                      color: kDarkGreen,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                itemCount: nfos.length,
                itemBuilder: (context, index) {
                  final nfo = nfos[index];
                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade50,
                        child: Icon(
                          Icons.trending_up,
                          color: Colors.blue.shade600,
                        ),
                      ),
                      title: Text(
                        nfo['name'] as String,
                        style: TextStyle(
                          color: kDarkGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Text(
                            nfo['date'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Min. Invest: \u20B9${(nfo['min'] as double).toInt()}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Apply Now',
                            style: TextStyle(
                              color: kDarkGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DynamicNFOScreen(
                              name: nfo['name'] as String,
                              date: nfo['date'] as String,
                              minInvestment: nfo['min'] as double,
                              closesInDays: nfo['closesInDays'] as int,
                              description: nfo['description'] as String,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Live IPOs',
              style: TextStyle(
                color: kDarkGreen,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            GestureDetector(
              onTap: _showAllIPOsModal,
              child: Row(
                children: [
                  Text(
                    'View More',
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
            ),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          clipBehavior: Clip.none,
          child: Row(
            children: List.generate(_liveIpos.length > 2 ? 2 : _liveIpos.length, (index) {
              final ipo = _liveIpos[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: _buildIPOCard(
                  ipo['name'] as String,
                  ipo['dates'] as String,
                  ipo['price'] as String,
                  lotSize: ipo['lot'] as int,
                  minAmount: ipo['min'] as String,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildIPOCard(
    String name,
    String date,
    String priceRange, {
    required int lotSize,
    required String minAmount,
  }) {
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

    return CustomPaint(
      painter: DottedBorderPainter(
        color: Colors.grey.shade300,
        strokeWidth: 1.2,
        gap: 4,
        borderRadius: 16,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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



  void _showAllTradingIdeasModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.80,
        decoration: const BoxDecoration(
          color: Color(0xFFF2F0EB), // Light theme background
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All F&O Trading Ideas',
                    style: TextStyle(
                      color: kDarkGreen,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: kDarkGreen),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                itemCount: _tradingIdeas.length,
                itemBuilder: (context, index) {
                  final idea = _tradingIdeas[index];
                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: Colors.grey.shade200,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: kLightGreenBg,
                        child: Icon(
                          Icons.swap_vert_rounded,
                          color: kDarkGreen,
                        ),
                      ),
                      title: Text(
                        idea['contract'] as String,
                        style: TextStyle(
                          color: kDarkGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Text(
                            'Buy: ${idea['buy']} \u2022 Target: ${idea['target']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Powered by ${idea['provider']}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            idea['price'] as String,
                            style: TextStyle(
                              color: kDarkGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            idea['change'] as String,
                            style: TextStyle(
                              color: idea['isUp'] ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TradingIdeaDetailScreen(
                              title: idea['contract'] as String,
                              price: idea['price'] as String,
                              percentageChange: idea['change'] as String,
                              entryPrice: idea['buy'] as double,
                              sl: idea['sl'] as double,
                              target: idea['target'] as double,
                              fundsRequired: idea['funds'] as double,
                              provider: idea['provider'] as String,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Trading Ideas',
              style: TextStyle(
                color: kDarkGreen,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            GestureDetector(
              onTap: _showAllTradingIdeasModal,
              child: Row(
                children: [
                  Text(
                    'View More',
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
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Horizontal card slider matching First Image
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          clipBehavior: Clip.none,
          child: Row(
            children: List.generate(2, (index) {
              final idea = _tradingIdeas[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TradingIdeaDetailScreen(
                        title: idea['contract'] as String,
                        price: idea['price'] as String,
                        percentageChange: idea['change'] as String,
                        entryPrice: idea['buy'] as double,
                        sl: idea['sl'] as double,
                        target: idea['target'] as double,
                        fundsRequired: idea['funds'] as double,
                        provider: idea['provider'] as String,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 230,
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.grey.shade200,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: kLightGreenBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.swap_vert_rounded,
                              color: kDarkGreen,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        idea['contract'] as String,
                        style: TextStyle(
                          color: kDarkGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${idea['price']} ${idea['change']}',
                        style: TextStyle(
                          color: idea['isUp'] ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Buy',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${idea['buy']}',
                                  style: TextStyle(
                                    color: kDarkGreen,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Target',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${idea['target']}',
                                  style: TextStyle(
                                    color: kDarkGreen,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Divider(
                        color: Colors.grey.shade100,
                        height: 1,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Powered by ${idea['provider']}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 9,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.info_outline,
                            color: Colors.grey.shade600,
                            size: 10,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
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
                    _selectedOptionChainIndex == 1
                        ? '11 Apr \u25BE'
                        : '07 Apr \u25BE',
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
                _buildFnOTab(
                  'Nifty 50',
                  _selectedOptionChainIndex == 0,
                  () => setState(() => _selectedOptionChainIndex = 0),
                ),
                const SizedBox(width: 16),
                _buildFnOTab(
                  'BSE Sensex',
                  _selectedOptionChainIndex == 1,
                  () => setState(() => _selectedOptionChainIndex = 1),
                ),
                const SizedBox(width: 16),
                _buildFnOTab(
                  'Nifty Bank',
                  _selectedOptionChainIndex == 2,
                  () => setState(() => _selectedOptionChainIndex = 2),
                ),
                const SizedBox(width: 16),
                _buildFnOTab(
                  'Nifty Financial',
                  _selectedOptionChainIndex == 3,
                  () => setState(() => _selectedOptionChainIndex = 3),
                ),
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
                _buildOptionChainRow(
                  '241.70',
                  '-17.42%',
                  '22750',
                  '-10.39%',
                  '284.60',
                ),
                const SizedBox(height: 12),
                _buildOptionChainRow(
                  '217.25',
                  '-18.8%',
                  '22800',
                  '-9.63%',
                  '309.55',
                ),
              ]
            : [
                _buildOptionChainRow(
                  '298.90',
                  '-13.6%',
                  '22650',
                  '-11.22%',
                  '242.05',
                ),
                const SizedBox(height: 12),
                _buildOptionChainRow(
                  '269.15',
                  '-15.45%',
                  '22700',
                  '-10.57%',
                  '263.55',
                ),
              ],
      );
    } else if (_selectedOptionChainIndex == 1) {
      // BSE Sensex
      return Column(
        children: isAfterSpot
            ? [
                _buildOptionChainRow(
                  '845.20',
                  '-8.12%',
                  '74800',
                  '-5.22%',
                  '790.15',
                ),
                const SizedBox(height: 12),
                _buildOptionChainRow(
                  '782.45',
                  '-9.45%',
                  '74900',
                  '-4.88%',
                  '865.30',
                ),
              ]
            : [
                _buildOptionChainRow(
                  '1012.30',
                  '-6.45%',
                  '74600',
                  '-7.15%',
                  '642.50',
                ),
                const SizedBox(height: 12),
                _buildOptionChainRow(
                  '928.75',
                  '-7.22%',
                  '74700',
                  '-6.80%',
                  '712.95',
                ),
              ],
      );
    } else if (_selectedOptionChainIndex == 2) {
      // Nifty Bank
      return Column(
        children: isAfterSpot
            ? [
                _buildOptionChainRow(
                  '542.80',
                  '+2.14%',
                  '48600',
                  '-8.45%',
                  '612.35',
                ),
                const SizedBox(height: 12),
                _buildOptionChainRow(
                  '498.15',
                  '+1.88%',
                  '48700',
                  '-7.90%',
                  '678.90',
                ),
              ]
            : [
                _buildOptionChainRow(
                  '654.20',
                  '+3.45%',
                  '48400',
                  '-10.12%',
                  '512.60',
                ),
                const SizedBox(height: 12),
                _buildOptionChainRow(
                  '598.75',
                  '+2.90%',
                  '48500',
                  '-9.50%',
                  '564.25',
                ),
              ],
      );
    } else {
      // Nifty Financial
      return Column(
        children: isAfterSpot
            ? [
                _buildOptionChainRow(
                  '212.45',
                  '-1.22%',
                  '21450',
                  '+2.45%',
                  '245.60',
                ),
                const SizedBox(height: 12),
                _buildOptionChainRow(
                  '195.80',
                  '-1.45%',
                  '21500',
                  '+2.88%',
                  '272.35',
                ),
              ]
            : [
                _buildOptionChainRow(
                  '258.90',
                  '-0.85%',
                  '21350',
                  '+1.12%',
                  '198.45',
                ),
                const SizedBox(height: 12),
                _buildOptionChainRow(
                  '234.15',
                  '-1.05%',
                  '21400',
                  '+1.25%',
                  '220.80',
                ),
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
    String indexName = _selectedOptionChainIndex == 0
        ? 'NIFTY'
        : _selectedOptionChainIndex == 1
        ? 'SENSEX'
        : _selectedOptionChainIndex == 2
        ? 'BANKNIFTY'
        : 'FINNIFTY';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StockDetailViewScreen(
                      title: '$indexName 30 JUN $sp CALL',
                      price: cl,
                      change: cp,
                      isUp: !cp.startsWith('-'),
                      expiryDate: _selectedOptionChainIndex == 1
                          ? '11 Apr 2026'
                          : '07 Apr 2026',
                      underlyingIndexName: indexName == 'NIFTY'
                          ? 'Nifty 50 Index'
                          : indexName == 'SENSEX'
                          ? 'BSE Sensex Index'
                          : indexName == 'BANKNIFTY'
                          ? 'Nifty Bank Index'
                          : 'Nifty Financial Services',
                    ),
                  ),
                );
              },
              child: Container(
                color: Colors.transparent,
                child: Row(
                  children: [
                    Text(cl, style: TextStyle(color: kDarkGreen, fontSize: 13)),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        cp,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StockDetailViewScreen(
                      title: '$indexName 30 JUN $sp PUT',
                      price: pl,
                      change: pp,
                      isUp: !pp.startsWith('-'),
                      expiryDate: _selectedOptionChainIndex == 1
                          ? '11 Apr 2026'
                          : '07 Apr 2026',
                      underlyingIndexName: indexName == 'NIFTY'
                          ? 'Nifty 50 Index'
                          : indexName == 'SENSEX'
                          ? 'BSE Sensex Index'
                          : indexName == 'BANKNIFTY'
                          ? 'Nifty Bank Index'
                          : 'Nifty Financial Services',
                    ),
                  ),
                );
              },
              child: Container(
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        pp,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(pl, style: TextStyle(color: kDarkGreen, fontSize: 13)),
                  ],
                ),
              ),
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StockDetailViewScreen(
              title: contract,
              price: ltp,
              change: cltp,
              isUp: cltp.startsWith('+'),
              expiryDate: '07 Apr 2026',
              underlyingIndexName: 'Nifty 50 Index',
            ),
          ),
        );
      },
      child: Container(
        color: Colors.transparent, // Makes the entire row clickable
        child: Row(
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
                  style: TextStyle(
                    color: cltp.startsWith('+')
                        ? Colors.green
                        : Colors.red.shade700,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
              GestureDetector(
                onTap: _showAllTopFundsModal,
                child: Row(
                  children: [
                    Text(
                      'View More',
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
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...List.generate(_topFunds.length > 4 ? 4 : _topFunds.length, (index) {
            final fund = _topFunds[index];
            return Column(
              children: [
                _buildFundRow(
                  fund['name'] as String,
                  fund['category'] as String,
                  fund['return'] as String,
                ),
                if (index < (_topFunds.length > 4 ? 3 : _topFunds.length - 1))
                  Divider(color: Colors.grey.shade100, thickness: 1, height: 32),
              ],
            );
          }),
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
    return CustomPaint(
      painter: DottedBorderPainter(
        color: Colors.grey.shade300,
        strokeWidth: 1.2,
        gap: 4,
        borderRadius: 16,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    CircleAvatar(backgroundColor: kOrange, radius: 5),
                    const SizedBox(width: 6),
                    Text(
                      'Debt (25%)',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                      ),
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
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMFChart() {
    final chartData = _getMFChartData();

    return CustomPaint(
      painter: DottedBorderPainter(
        color: Colors.grey.shade300,
        strokeWidth: 1.2,
        gap: 4,
        borderRadius: 16,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            GestureDetector(
              onTap: _showAllLiveNFOsModal,
              child: Row(
                children: [
                  Text(
                    'View More',
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
            ),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          clipBehavior: Clip.none,
          child: Row(
            children: List.generate(_liveNfos.length > 3 ? 3 : _liveNfos.length, (index) {
              final nfo = _liveNfos[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: _buildNFOCard(
                  nfo['name'] as String,
                  nfo['date'] as String,
                  '₹${nfo['min'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                ),
              );
            }),
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

  // --- GOALS TAB BUILDERS & HELPERS ---

  Widget _buildGoalsSummary() {
    double progressPercent = _goalsSummaryTarget > 0 
        ? (_goalsSummarySaved / _goalsSummaryTarget).clamp(0.0, 1.0) 
        : 0.0;
    int percentage = (progressPercent * 100).toInt();

    return CustomPaint(
      painter: DottedBorderPainter(
        color: Colors.grey.shade300,
        strokeWidth: 1.2,
        gap: 4,
        borderRadius: 16,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            Text(
              'Goals Summary',
              style: TextStyle(
                color: kDarkGreen,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 110,
                      height: 110,
                      child: TweenAnimationBuilder<double>(
                        key: ValueKey('goals_donut_chart_${_goalsSummarySaved}'),
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return CustomPaint(
                            painter: DonutPainter(
                              progressPercent,
                              kDarkGreen,
                              const Color(0xFFECC1B0), // Peach/orange remaining progress color
                              value,
                            ),
                          );
                        },
                      ),
                    ),
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        color: kDarkGreen,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 28),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Goal Target:',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₹${_formatCurrency(_goalsSummaryTarget)}',
                        style: TextStyle(
                          color: kDarkGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Total Saved:',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₹${_formatCurrency(_goalsSummarySaved)}',
                        style: TextStyle(
                          color: kDarkGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Projected Completion:',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '2028',
                        style: TextStyle(
                          color: kDarkGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  'Progress Across ${_goalsList.length} Goals',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildGoalsList() {
    return List.generate(_goalsList.length, (index) {
      final goal = _goalsList[index];
      return GestureDetector(
        onTap: () {
          setState(() {
            _selectedGoalIndex = index;
            _goalsSubView = 3; // Goal details
          });
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
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
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon Avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEAF1ED),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      goal.icon,
                      color: kDarkGreen,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Text details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.name,
                          style: TextStyle(
                            color: kDarkGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'Target: ',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              goal.targetText,
                              style: TextStyle(
                                color: kDarkGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Current: ',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              goal.currentText,
                              style: TextStyle(
                                color: kDarkGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Status Badge
                  _buildStatusBadge(goal.status),
                ],
              ),
              const SizedBox(height: 12),
              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: goal.progress,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(kDarkGreen),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildStatusBadge(String status) {
    bool isOnTrack = status == 'On Track';
    Color color = isOnTrack ? const Color(0xFF1F5D3A) : const Color(0xFFDD754E);
    Color bg = isOnTrack ? const Color(0xFFEAF1ED) : const Color(0xFFFBEFEA);
    IconData icon = isOnTrack ? Icons.check_circle_rounded : Icons.info_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _goalsSubView = 1; // Add Goal Screen
              });
            },
            icon: Icon(Icons.add_rounded, color: kDarkGreen, size: 18),
            label: Text(
              'Add Goal',
              style: TextStyle(
                color: kDarkGreen,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: BorderSide(color: Colors.grey.shade300),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _goalsSubView = 2; // Track Goals Screen
              });
            },
            icon: Icon(Icons.bar_chart_rounded, color: kDarkGreen, size: 18),
            label: Text(
              'Track Goals',
              style: TextStyle(
                color: kDarkGreen,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: BorderSide(color: Colors.grey.shade300),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddGoalScreen() {
    final nameController = TextEditingController();
    final targetController = TextEditingController(text: '500000');
    final yearController = TextEditingController(text: '5');

    String selectedIconLabel = 'Other';
    IconData selectedIcon = Icons.track_changes_outlined;

    final List<Map<String, dynamic>> iconsGrid = [
      {'label': 'Home', 'icon': Icons.home_outlined},
      {'label': 'Education', 'icon': Icons.school_outlined},
      {'label': 'Travel', 'icon': Icons.flight_takeoff_outlined},
      {'label': 'Car', 'icon': Icons.directions_car_outlined},
      {'label': 'Retire', 'icon': Icons.favorite_outline_rounded},
      {'label': 'Business', 'icon': Icons.business_center_outlined},
      {'label': 'Gift', 'icon': Icons.card_giftcard_outlined},
      {'label': 'Other', 'icon': Icons.track_changes_outlined},
    ];

    return Container(
      color: Colors.white, // Match white background of mockup
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          // Header with Title and Circle Close Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Create New Goal',
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _goalsSubView = 0),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded, color: Color(0xFF1E293B), size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: StatefulBuilder(
                builder: (context, setFormState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Goal Name
                      const Text(
                        'Goal Name',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: nameController,
                        style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          hintText: 'e.g. Down payment',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: kDarkGreen, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Pick an Icon
                      const Text(
                        'Pick an icon',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Icon Selection Grid (2 rows, 4 columns)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.1,
                        ),
                        itemCount: iconsGrid.length,
                        itemBuilder: (context, index) {
                          final item = iconsGrid[index];
                          final label = item['label'] as String;
                          final icon = item['icon'] as IconData;
                          final isSelected = selectedIconLabel == label;

                          return GestureDetector(
                            onTap: () {
                              setFormState(() {
                                selectedIconLabel = label;
                                selectedIcon = icon;
                                if (nameController.text.isEmpty ||
                                    iconsGrid.any((e) => e['label'] == nameController.text || nameController.text == 'New ' + e['label'])) {
                                  nameController.text = label == 'Other' ? 'Custom Goal' : label;
                                }
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFEAF1ED) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? kDarkGreen : Colors.grey.shade200,
                                  width: isSelected ? 2.0 : 1.0,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    icon,
                                    color: isSelected ? kDarkGreen : const Color(0xFF1F5D3A),
                                    size: 24,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    label,
                                    style: TextStyle(
                                      color: isSelected ? kDarkGreen : Colors.grey.shade600,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      // Side-by-side inputs (Target & Years)
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Target (₹)',
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: targetController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w600),
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: kDarkGreen, width: 1.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Years',
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: yearController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w600),
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: kDarkGreen, width: 1.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () {
                          final name = nameController.text.trim().isEmpty ? selectedIconLabel : nameController.text.trim();
                          final targetVal = double.tryParse(targetController.text.trim()) ?? 0;
                          
                          if (targetVal <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter a valid target amount.')),
                            );
                            return;
                          }

                          setState(() {
                            _goalsList.add(
                              GoalItem(
                                name: name,
                                targetText: formatAmount(targetVal),
                                currentText: '₹0L',
                                progress: 0.0,
                                status: 'On Track',
                                icon: selectedIcon,
                                iconBgColor: const Color(0xFFEAF1ED),
                                targetValue: targetVal,
                                currentValue: 0.0,
                              ),
                            );

                            _goalsSummaryTarget = _goalsList.fold(0.0, (sum, item) => sum + item.targetValue);
                            _goalsSummarySaved = _goalsList.fold(0.0, (sum, item) => sum + item.currentValue);
                            _goalsSubView = 0; 
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Goal "$name" created successfully!'),
                              backgroundColor: kDarkGreen,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9ABCA7), // Sage green matching image
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Create Goal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? kDarkGreen : const Color(0xFFEAF1ED),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : kDarkGreen,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: kDarkGreen,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(color: kDarkGreen, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            prefixIcon: Icon(icon, color: kDarkGreen, size: 18),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: kDarkGreen, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrackGoalsScreen() {
    return Container(
      color: const Color(0xFFF2F0EB), // kCream background
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: kDarkGreen),
                onPressed: () {
                  setState(() {
                    _goalsSubView = 0;
                  });
                },
              ),
              const SizedBox(width: 8),
              Text(
                'Track Financial Goals',
                style: TextStyle(
                  color: kDarkGreen,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: _goalsList.length,
              itemBuilder: (context, index) {
                final goal = _goalsList[index];
                double remaining = goal.targetValue - goal.currentValue;
                if (remaining < 0) remaining = 0;
                
                final savingsController = TextEditingController();

                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: const Color(0xFFEAF1ED),
                              radius: 20,
                              child: Icon(goal.icon, color: kDarkGreen, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    goal.name,
                                    style: TextStyle(
                                      color: kDarkGreen,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Remaining: ₹${_formatCurrency(remaining)}',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildStatusBadge(goal.status),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress: ${(goal.progress * 100).toInt()}%',
                              style: TextStyle(
                                color: kDarkGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '${goal.currentText} / ${goal.targetText}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: goal.progress,
                            backgroundColor: Colors.grey.shade100,
                            valueColor: AlwaysStoppedAnimation<Color>(kDarkGreen),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Divider(color: Colors.grey.shade100, height: 1),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 38,
                                child: TextField(
                                  controller: savingsController,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(color: kDarkGreen, fontSize: 13, fontWeight: FontWeight.w600),
                                  decoration: InputDecoration(
                                    hintText: 'Add savings (e.g. 5000)',
                                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: Colors.grey.shade200),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: kDarkGreen),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                double addAmount = double.tryParse(savingsController.text.trim()) ?? 0.0;
                                if (addAmount <= 0) return;
                                _showAddMoneyBottomSheet(context, addAmount, goal);
                                savingsController.clear();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kDarkGreen,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Add More',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalDetailsScreen(int index) {
    if (index < 0 || index >= _goalsList.length) {
      return const SizedBox.shrink();
    }
    
    final goal = _goalsList[index];
    double remaining = goal.targetValue - goal.currentValue;
    if (remaining < 0) remaining = 0;

    final addFundsController = TextEditingController();
    final updateTargetController = TextEditingController(text: goal.targetValue.toInt().toString());

    String description = 'Plan and save for your custom financial milestones and dreams.';
    if (goal.name.toLowerCase().contains('retirement')) {
      description = 'Secure your golden years with a robust corpus to cover post-retirement living expenses, medical care, and travel.';
    } else if (goal.name.toLowerCase().contains('home') || goal.name.toLowerCase().contains('house')) {
      description = 'Build or buy your dream house. Save up for down payments, registration costs, and interior designs.';
    } else if (goal.name.toLowerCase().contains('vacation') || goal.name.toLowerCase().contains('travel')) {
      description = 'Travel the world, explore new cultures, and make lasting memories with your loved ones.';
    } else if (goal.name.toLowerCase().contains('car') || goal.name.toLowerCase().contains('vehicle')) {
      description = 'Save for a down payment or full purchase of a new automobile. Ensure you cover insurance and registration costs too.';
    } else if (goal.name.toLowerCase().contains('education') || goal.name.toLowerCase().contains('school')) {
      description = 'Invest in higher education or professional development. Cover tuition, lodging, and academic materials.';
    } else if (goal.name.toLowerCase().contains('business')) {
      description = 'Fund your startup or expand your existing business venture. Secure capital for equipment, marketing, and operations.';
    }

    return Container(
      color: const Color(0xFFF2F0EB), // kCream background
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: kDarkGreen),
                onPressed: () {
                  setState(() {
                    _goalsSubView = 0;
                  });
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  goal.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: kDarkGreen,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    color: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: const Color(0xFFEAF1ED),
                                radius: 22,
                                child: Icon(goal.icon, color: kDarkGreen, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Goal Description',
                                style: TextStyle(
                                  color: kDarkGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            description,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Progress: ${(goal.progress * 100).toInt()}%',
                                style: TextStyle(
                                  color: kDarkGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              _buildStatusBadge(goal.status),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: goal.progress,
                              backgroundColor: Colors.grey.shade100,
                              valueColor: AlwaysStoppedAnimation<Color>(kDarkGreen),
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildMetricTile('Saved Amount', goal.currentText),
                              _buildMetricTile('Target Amount', goal.targetText),
                              _buildMetricTile('Remaining', '₹${_formatCurrency(remaining)}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add Funds to Goal',
                            style: TextStyle(
                              color: kDarkGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 44,
                                  child: TextField(
                                    controller: addFundsController,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(color: kDarkGreen, fontSize: 14, fontWeight: FontWeight.w600),
                                    decoration: InputDecoration(
                                      hintText: 'Enter amount (e.g. 10000)',
                                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: Colors.grey.shade200),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: kDarkGreen),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () {
                                  double amount = double.tryParse(addFundsController.text.trim()) ?? 0.0;
                                  if (amount <= 0) return;
                                  _showAddMoneyBottomSheet(context, amount, goal);
                                  addFundsController.clear();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kDarkGreen,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Add More',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Modify Goal Target (Increase Size)',
                            style: TextStyle(
                              color: kDarkGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 44,
                                  child: TextField(
                                    controller: updateTargetController,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(color: kDarkGreen, fontSize: 14, fontWeight: FontWeight.w600),
                                    decoration: InputDecoration(
                                      hintText: 'New Target (e.g. 1200000)',
                                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: Colors.grey.shade200),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: kDarkGreen),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () {
                                  double newTarget = double.tryParse(updateTargetController.text.trim()) ?? 0.0;
                                  if (newTarget <= goal.targetValue) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('New target must be greater than current target.'),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() {
                                    goal.targetValue = newTarget;
                                    goal.targetText = formatAmount(newTarget);
                                    goal.progress = (goal.currentValue / goal.targetValue).clamp(0.0, 1.0);

                                    _goalsSummaryTarget = _goalsList.fold(0.0, (sum, item) => sum + item.targetValue);
                                    _goalsSummarySaved = _goalsList.fold(0.0, (sum, item) => sum + item.currentValue);
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Goal target size updated to ${goal.targetText}!'),
                                      backgroundColor: kDarkGreen,
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFDD754E), 
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Update Target',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Emergency Withdrawal',
                            style: TextStyle(
                              color: kDarkGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Need immediate access to these funds? You can withdraw your accumulated savings back to your bank account instantly.',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: goal.currentValue <= 0 ? null : () {
                                _showWithdrawalBottomSheet(context, goal);
                              },
                              icon: Icon(
                                Icons.account_balance_wallet_rounded,
                                color: goal.currentValue <= 0 ? Colors.grey : const Color(0xFFC2410C),
                                size: 18,
                              ),
                              label: Text(
                                'Withdraw to Bank Account',
                                style: TextStyle(
                                  color: goal.currentValue <= 0 ? Colors.grey : const Color(0xFFC2410C),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: goal.currentValue <= 0 ? Colors.grey.shade300 : const Color(0xFFC2410C),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: const Color(0xFFF2F0EB),
                          title: Text(
                            'Remove Goal',
                            style: TextStyle(color: kDarkGreen, fontWeight: FontWeight.bold),
                          ),
                          content: Text(
                            'Are you sure you want to remove your "${goal.name}" goal? This action cannot be undone.',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                setState(() {
                                  _goalsList.removeAt(index);
                                  _goalsSummaryTarget = _goalsList.fold(0.0, (sum, item) => sum + item.targetValue);
                                  _goalsSummarySaved = _goalsList.fold(0.0, (sum, item) => sum + item.currentValue);
                                  _goalsSubView = 0;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Goal "${goal.name}" has been removed.'),
                                    backgroundColor: Colors.red.shade800,
                                  ),
                                );
                              },
                              child: const Text('Remove', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.delete_forever_rounded, color: Colors.white, size: 20),
                    label: const Text(
                      'Remove Goal',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC2410C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
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

  void _showAddMoneyBottomSheet(BuildContext context, double amount, GoalItem goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Color(0xFFF2F0EB), // kCream background
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: StatefulBuilder(
            builder: (context, innerSetState) {
              // Local state inside the builder
              innerSetState((){});
              return Navigator(
                onGenerateRoute: (_) => MaterialPageRoute(
                  builder: (context) => _PaymentFlowWidget(
                    amount: amount,
                    goal: goal,
                    kDarkGreen: kDarkGreen,
                    onComplete: (addAmount) {
                      setState(() {
                        goal.currentValue += addAmount;
                        if (goal.currentValue > goal.targetValue) {
                          goal.currentValue = goal.targetValue;
                        }
                        goal.currentText = formatAmount(goal.currentValue);
                        goal.progress = (goal.currentValue / goal.targetValue).clamp(0.0, 1.0);
                        
                        _goalsSummaryTarget = _goalsList.fold(0.0, (sum, item) => sum + item.targetValue);
                        _goalsSummarySaved = _goalsList.fold(0.0, (sum, item) => sum + item.currentValue);
                      });
                    },
                    formatCurrency: _formatCurrency,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showWithdrawalBottomSheet(BuildContext context, GoalItem goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Color(0xFFF2F0EB), // kCream background
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Navigator(
            onGenerateRoute: (_) => MaterialPageRoute(
              builder: (context) => _WithdrawalFlowWidget(
                amount: goal.currentValue,
                goal: goal,
                kDarkGreen: kDarkGreen,
                onComplete: () {
                  setState(() {
                    goal.currentValue = 0.0;
                    goal.currentText = formatAmount(0.0);
                    goal.progress = 0.0;

                    _goalsSummaryTarget = _goalsList.fold(0.0, (sum, item) => sum + item.targetValue);
                    _goalsSummarySaved = _goalsList.fold(0.0, (sum, item) => sum + item.currentValue);
                  });
                },
                formatCurrency: _formatCurrency,
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatCurrency(double val) {
    String str = val.toInt().toString();
    if (str.length > 3) {
      String lastThree = str.substring(str.length - 3);
      String remaining = str.substring(0, str.length - 3);
      String formatted = '';
      while (remaining.length > 2) {
        formatted = ',${remaining.substring(remaining.length - 2)}$formatted';
        remaining = remaining.substring(0, remaining.length - 2);
      }
      return '$remaining$formatted,$lastThree';
    }
    return str;
  }

  String formatAmount(double amount) {
    if (amount >= 100000) {
      double lakhs = amount / 100000;
      if (lakhs == lakhs.toInt()) {
        return '₹${lakhs.toInt()}L';
      } else {
        return '₹${lakhs.toStringAsFixed(1)}L';
      }
    } else if (amount >= 1000) {
      double k = amount / 1000;
      if (k == k.toInt()) {
        return '₹${k.toInt()}K';
      } else {
        return '₹${k.toStringAsFixed(1)}K';
      }
    } else {
      return '₹${amount.toInt()}';
    }
  }
}

// Payment Flow Widget helper to hold local step state inside modal bottom sheet cleanly
class _PaymentFlowWidget extends StatefulWidget {
  final double amount;
  final GoalItem goal;
  final Color kDarkGreen;
  final void Function(double) onComplete;
  final String Function(double) formatCurrency;

  const _PaymentFlowWidget({
    required this.amount,
    required this.goal,
    required this.kDarkGreen,
    required this.onComplete,
    required this.formatCurrency,
  });

  @override
  State<_PaymentFlowWidget> createState() => _PaymentFlowWidgetState();
}

class _PaymentFlowWidgetState extends State<_PaymentFlowWidget> {
  int paymentStep = 0; // 0 = Choose Payment, 1 = Enter PIN, 2 = Loading, 3 = Success
  String pin = '';

  @override
  Widget build(BuildContext context) {
    if (paymentStep == 0) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Payment Methods',
                  style: TextStyle(
                    color: widget.kDarkGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Amount to Add',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${widget.formatCurrency(widget.amount)}',
                        style: TextStyle(
                          color: widget.kDarkGreen,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF1ED),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.goal.name,
                      style: TextStyle(color: widget.kDarkGreen, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Select Account / Method',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  _buildOption(
                    title: 'Punjab & Sind Bank Savings',
                    subtitle: 'A/c No: ******7890 (Bal: ₹2,48,500)',
                    icon: Icons.account_balance_rounded,
                    onTap: () => setState(() => paymentStep = 1),
                  ),
                  const SizedBox(height: 12),
                  _buildOption(
                    title: 'Google Pay UPI',
                    subtitle: 'Pay via linked UPI application',
                    icon: Icons.payments_rounded,
                    onTap: () => setState(() => paymentStep = 1),
                  ),
                  const SizedBox(height: 12),
                  _buildOption(
                    title: 'Net Banking',
                    subtitle: 'Punjab & Sind Bank Net Banking portal',
                    icon: Icons.laptop_mac_rounded,
                    onTap: () => setState(() => paymentStep = 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (paymentStep == 1) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => setState(() {
                    paymentStep = 0;
                    pin = '';
                  }),
                ),
                const Spacer(),
                Text(
                  'Security Verification',
                  style: TextStyle(
                    color: widget.kDarkGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'ENTER 4-DIGIT SECURE UPI PIN',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (idx) {
                bool active = idx < pin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: active ? widget.kDarkGreen : Colors.grey.shade300,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: active ? widget.kDarkGreen : Colors.grey.shade400,
                      width: 1.5,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.6,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  String key = '';
                  Widget child;
                  if (index < 9) {
                    key = (index + 1).toString();
                    child = Text(
                      key,
                      style: TextStyle(
                        color: widget.kDarkGreen,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  } else if (index == 9) {
                    child = Icon(Icons.backspace_outlined, color: widget.kDarkGreen);
                  } else if (index == 10) {
                    key = '0';
                    child = Text(
                      key,
                      style: TextStyle(
                        color: widget.kDarkGreen,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  } else {
                    child = Icon(Icons.check_circle_outline_rounded, color: Colors.green.shade700, size: 28);
                  }

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (index < 9 || index == 10) {
                          if (pin.length < 4) {
                            pin += key;
                          }
                          if (pin.length == 4) {
                            _processPayment();
                          }
                        } else if (index == 9) {
                          if (pin.isNotEmpty) {
                            pin = pin.substring(0, pin.length - 1);
                          }
                        } else {
                          if (pin.length == 4) {
                            _processPayment();
                          }
                        }
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: child,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    } else if (paymentStep == 2) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: widget.kDarkGreen,
              strokeWidth: 4,
            ),
            const SizedBox(height: 24),
            Text(
              'Processing Secure UPI Payment...',
              style: TextStyle(
                color: widget.kDarkGreen,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: Colors.green.shade700,
                size: 72,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Payment Successful!',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '₹${widget.formatCurrency(widget.amount)} added to ${widget.goal.name}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildReceiptRow('Source Account', 'Punjab & Sind Bank (****7890)'),
                  const Divider(),
                  _buildReceiptRow('Transaction ID', 'TXN-9827361849'),
                  const Divider(),
                  _buildReceiptRow('Status', 'COMPLETED'),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.kDarkGreen,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Done',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      );
    }
  }

  Widget _buildOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFEAF1ED),
              child: Icon(icon, color: widget.kDarkGreen),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: widget.kDarkGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          Text(value, style: TextStyle(color: widget.kDarkGreen, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _processPayment() {
    setState(() {
      paymentStep = 2; // Loading spinner
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        widget.onComplete(widget.amount);
        setState(() {
          paymentStep = 3; // Success
        });
      }
    });
  }
}

// Payment Flow Widget helper to hold local step state inside modal bottom sheet cleanly for withdrawals
class _WithdrawalFlowWidget extends StatefulWidget {
  final double amount;
  final GoalItem goal;
  final Color kDarkGreen;
  final VoidCallback onComplete;
  final String Function(double) formatCurrency;

  const _WithdrawalFlowWidget({
    required this.amount,
    required this.goal,
    required this.kDarkGreen,
    required this.onComplete,
    required this.formatCurrency,
  });

  @override
  State<_WithdrawalFlowWidget> createState() => _WithdrawalFlowWidgetState();
}

class _WithdrawalFlowWidgetState extends State<_WithdrawalFlowWidget> {
  int step = 0; // 0 = Confirm, 1 = Verification PIN, 2 = Loading, 3 = Success
  String pin = '';

  @override
  Widget build(BuildContext context) {
    if (step == 0) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Confirm Withdrawal',
                  style: TextStyle(
                    color: widget.kDarkGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Amount to Withdraw',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${widget.formatCurrency(widget.amount)}',
                            style: TextStyle(
                              color: widget.kDarkGreen,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF1ED),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.goal.name,
                          style: TextStyle(color: widget.kDarkGreen, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.account_balance_wallet_rounded, color: widget.kDarkGreen, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Destination Bank Account',
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Punjab & Sind Bank Savings (****7890)',
                              style: TextStyle(
                                color: widget.kDarkGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFBEFEA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF0DCD3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFDD754E), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Emergency withdrawals will instantly stop this goal\'s growth and move all saved balance to your bank account.',
                      style: TextStyle(
                        color: Colors.red.shade900,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => setState(() => step = 1),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.kDarkGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Verify & Withdraw',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      );
    } else if (step == 1) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => setState(() {
                    step = 0;
                    pin = '';
                  }),
                ),
                const Spacer(),
                Text(
                  'Security Verification',
                  style: TextStyle(
                    color: widget.kDarkGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'ENTER 4-DIGIT SECURE UPI PIN',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (idx) {
                bool active = idx < pin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: active ? widget.kDarkGreen : Colors.grey.shade300,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: active ? widget.kDarkGreen : Colors.grey.shade400,
                      width: 1.5,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.6,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  String key = '';
                  Widget child;
                  if (index < 9) {
                    key = (index + 1).toString();
                    child = Text(
                      key,
                      style: TextStyle(
                        color: widget.kDarkGreen,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  } else if (index == 9) {
                    child = Icon(Icons.backspace_outlined, color: widget.kDarkGreen);
                  } else if (index == 10) {
                    key = '0';
                    child = Text(
                      key,
                      style: TextStyle(
                        color: widget.kDarkGreen,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  } else {
                    child = Icon(Icons.check_circle_outline_rounded, color: Colors.green.shade700, size: 28);
                  }

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (index < 9 || index == 10) {
                          if (pin.length < 4) {
                            pin += key;
                          }
                          if (pin.length == 4) {
                            _processWithdrawal();
                          }
                        } else if (index == 9) {
                          if (pin.isNotEmpty) {
                            pin = pin.substring(0, pin.length - 1);
                          }
                        } else {
                          if (pin.length == 4) {
                            _processWithdrawal();
                          }
                        }
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: child,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    } else if (step == 2) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: widget.kDarkGreen,
              strokeWidth: 4,
            ),
            const SizedBox(height: 24),
            Text(
              'Initiating secure instant withdrawal...',
              style: TextStyle(
                color: widget.kDarkGreen,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: Colors.green.shade700,
                size: 72,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Withdrawal Successful!',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '₹${widget.formatCurrency(widget.amount)} credited to your bank account',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildReceiptRow('Source', 'Goal: ${widget.goal.name}'),
                  const Divider(),
                  _buildReceiptRow('Destination Account', 'Punjab & Sind Bank (****7890)'),
                  const Divider(),
                  _buildReceiptRow('Transaction ID', 'TXN-9847161823'),
                  const Divider(),
                  _buildReceiptRow('Status', 'SUCCESS'),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.kDarkGreen,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Done',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      );
    }
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          Text(value, style: TextStyle(color: widget.kDarkGreen, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _processWithdrawal() {
    setState(() {
      step = 2; // Loading spinner
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        widget.onComplete();
        setState(() {
          step = 3; // Success
        });
      }
    });
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

class DottedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double borderRadius;

  DottedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    final Path path = Path()..addRRect(rrect);
    final dashPath = Path();
    double dashWidth = gap;
    double dashSpace = gap;

    for (final pathMetric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant DottedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.gap != gap ||
        oldDelegate.borderRadius != borderRadius;
  }
}

class DottedBorderContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color color;
  final Color borderColor;
  final double strokeWidth;
  final double gap;

  const DottedBorderContainer({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 16,
    this.color = Colors.white,
    this.borderColor = const Color(0xFFCCCCCC),
    this.strokeWidth = 1.2,
    this.gap = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DottedBorderPainter(
        color: borderColor,
        strokeWidth: strokeWidth,
        gap: gap,
        borderRadius: borderRadius,
      ),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: child,
      ),
    );
  }
}

class GoalItem {
  final String name;
  String targetText;
  String currentText;
  double progress;
  final String status;
  final IconData icon;
  final Color iconBgColor;
  double targetValue;
  double currentValue;

  GoalItem({
    required this.name,
    required this.targetText,
    required this.currentText,
    required this.progress,
    required this.status,
    required this.icon,
    required this.iconBgColor,
    required this.targetValue,
    required this.currentValue,
  });
}
