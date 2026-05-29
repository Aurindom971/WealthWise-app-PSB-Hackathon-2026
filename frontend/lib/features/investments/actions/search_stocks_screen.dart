import 'package:flutter/material.dart';
import 'stock_analysis_screen.dart';

class SearchStocksScreen extends StatefulWidget {
  const SearchStocksScreen({super.key});

  @override
  State<SearchStocksScreen> createState() => _SearchStocksScreenState();
}

class _SearchStocksScreenState extends State<SearchStocksScreen> with SingleTickerProviderStateMixin {
  final Color kDarkGreen = const Color(0xFF1F5D3A);
  final Color kLightGreenBg = const Color(0xFFEAF1ED);
  final Color kCreamBg = const Color(0xFFF2F0EB);

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  bool _showOverlay = false;
  List<Map<String, dynamic>> _filteredStocks = [];

  final List<Map<String, dynamic>> _allStocks = [
    {
      'symbol': 'RELIANCE',
      'name': 'Reliance Industries',
      'price': '1,345',
      'change': '+0.13',
      'isUp': true,
      'history': [1344.0, 1350.0, 1340.0, 1348.0, 1345.0],
    },
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
    {
      'symbol': 'TATAMOTORS',
      'name': 'Tata Motors Ltd',
      'price': '965',
      'change': '+1.45',
      'isUp': true,
      'history': [945.0, 950.0, 948.0, 960.0, 965.0],
    },
    {
      'symbol': 'SBIN',
      'name': 'State Bank of India',
      'price': '782',
      'change': '+0.55',
      'isUp': true,
      'history': [775.0, 778.0, 774.0, 780.0, 782.0],
    },
    {
      'symbol': 'ICICIBANK',
      'name': 'ICICI Bank Ltd',
      'price': '1,120',
      'change': '-0.30',
      'isUp': false,
      'history': [1130.0, 1125.0, 1128.0, 1118.0, 1120.0],
    },
    {
      'symbol': 'ZOMATO',
      'name': 'Zomato Ltd',
      'price': '188',
      'change': '+3.40',
      'isUp': true,
      'history': [180.0, 182.0, 185.0, 187.0, 188.0],
    },
    {
      'symbol': 'ITC',
      'name': 'ITC Ltd',
      'price': '428',
      'change': '+0.10',
      'isUp': true,
      'history': [425.0, 427.0, 426.0, 429.0, 428.0],
    },
  ];

  final List<String> _recentSearches = ['Tata Motors', 'Reliance', 'Infosys'];
  final List<String> _trendingStocks = ['TATAMOTORS', 'RELIANCE', 'SBIN', 'ICICIBANK', 'ZOMATO', 'ITC'];

  late AnimationController _slideController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _filteredStocks = _allStocks;

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    );

    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus) {
        setState(() {
          _showOverlay = true;
        });
        _slideController.forward();
      }
    });

    _searchController.addListener(() {
      _onSearchChanged();
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      setState(() {
        _filteredStocks = _allStocks;
      });
    } else {
      setState(() {
        _filteredStocks = _allStocks.where((stock) {
          final symbolMatch = stock['symbol'].toString().toLowerCase().contains(query);
          final nameMatch = stock['name'].toString().toLowerCase().contains(query);
          return symbolMatch || nameMatch;
        }).toList();
      });
    }
  }

  void _selectSearchTerm(String term) {
    _searchController.text = term;
    _searchFocusNode.unfocus();
    setState(() {
      _showOverlay = false;
    });
    _slideController.reverse();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCreamBg,
      body: SafeArea(
        child: Stack(
          children: [
            // Main Content Area
            Column(
              children: [
                // Custom Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                        'Search Stocks',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: kDarkGreen,
                        ),
                      ),
                    ],
                  ),
                ),

                // Sleek floating search bar card layout
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Search stocks, companies, or tickers...',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      prefixIcon: Icon(Icons.search_rounded, color: kDarkGreen),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 20),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Search Results or List
                Expanded(
                  child: _filteredStocks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              Text(
                                'No stocks found for "${_searchController.text}"',
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _filteredStocks.length,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            final stock = _filteredStocks[index];
                            final isUp = stock['isUp'] as bool;
                            final changeColor = isUp ? const Color(0xFF16A34A) : const Color(0xFFDC2626);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StockAnalysisScreen(
                                        symbol: stock['symbol'],
                                        name: stock['name'],
                                        price: stock['price'],
                                        change: stock['change'],
                                        isUp: isUp,
                                        history: List<double>.from(stock['history']),
                                      ),
                                    ),
                                  );
                                },
                                title: Text(
                                  stock['symbol'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: kDarkGreen,
                                    fontSize: 15,
                                  ),
                                ),
                                subtitle: Text(
                                  stock['name'],
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '₹${stock['price']}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: kDarkGreen,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${isUp ? "+" : ""}${stock['change']}%',
                                      style: TextStyle(
                                        color: changeColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
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

            // Sliding Clean Overlay (Recent Searches & Trending Stocks)
            if (_showOverlay)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    _searchFocusNode.unfocus();
                    setState(() {
                      _showOverlay = false;
                    });
                    _slideController.reverse();
                  },
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.3),
                  ),
                ),
              ),

            if (_showOverlay)
              AnimatedBuilder(
                animation: _slideAnimation,
                builder: (context, child) {
                  return Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: MediaQuery.of(context).size.height * 0.5 * _slideAnimation.value,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Draggable/Indication bar
                          Center(
                            child: Container(
                              margin: const EdgeInsets.only(top: 12, bottom: 20),
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),

                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Recent Searches Section
                                  Text(
                                    'Recent Searches',
                                    style: TextStyle(
                                      color: kDarkGreen,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8.0,
                                    runSpacing: 8.0,
                                    children: _recentSearches.map((term) {
                                      return GestureDetector(
                                        onTap: () => _selectSearchTerm(term),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: kLightGreenBg.withValues(alpha: 0.7),
                                            borderRadius: BorderRadius.circular(100),
                                            border: Border.all(color: kDarkGreen.withValues(alpha: 0.1)),
                                          ),
                                          child: Text(
                                            term,
                                            style: TextStyle(
                                              color: kDarkGreen,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),

                                  const SizedBox(height: 28),

                                  // Trending Stocks Section
                                  Text(
                                    'Trending Stocks',
                                    style: TextStyle(
                                      color: kDarkGreen,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8.0,
                                    runSpacing: 8.0,
                                    children: _trendingStocks.map((symbol) {
                                      final stock = _allStocks.firstWhere((s) => s['symbol'] == symbol, orElse: () => _allStocks[0]);
                                      return GestureDetector(
                                        onTap: () => _selectSearchTerm(stock['symbol']),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(100),
                                            border: Border.all(color: Colors.grey.shade200),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.01),
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.trending_up_rounded, size: 14, color: kDarkGreen),
                                              const SizedBox(width: 6),
                                              Text(
                                                stock['symbol'],
                                                style: TextStyle(
                                                  color: kDarkGreen,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
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
                },
              ),
          ],
        ),
      ),
    );
  }
}
