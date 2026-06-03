import 'package:flutter/material.dart';
import '../../home/widgets/home_navigation_widgets.dart';

class FilteredMarketScreen extends StatefulWidget {
  final String categoryName;
  final String riskLevel;

  const FilteredMarketScreen({
    super.key,
    required this.categoryName,
    required this.riskLevel,
  });

  @override
  State<FilteredMarketScreen> createState() => _FilteredMarketScreenState();
}

class _FilteredMarketScreenState extends State<FilteredMarketScreen> {
  final List<String> _filters = ['Top Rated', 'Rating: 4★+', 'Best Returns', 'Low Expense Ratio'];
  String _selectedFilter = 'Top Rated';

  final Map<String, List<Map<String, dynamic>>> _categoryDatasets = {
    'High Return Picks': [
      {'name': 'Quant Small Cap Fund', 'returns': '38.4%', 'nav': '214.20', 'managedBy': 'Quant AMC', 'rating': '5★', 'isLowExpense': false},
      {'name': 'Nippon India Small Cap', 'returns': '31.2%', 'nav': '145.10', 'managedBy': 'Nippon India', 'rating': '5★', 'isLowExpense': true},
      {'name': 'Axis Mid Cap Fund', 'returns': '26.8%', 'nav': '84.50', 'managedBy': 'Axis Mutual Fund', 'rating': '4★', 'isLowExpense': false},
      {'name': 'HDFC Small Cap Fund', 'returns': '22.5%', 'nav': '112.90', 'managedBy': 'HDFC Mutual Fund', 'rating': '4★', 'isLowExpense': true},
      {'name': 'SBI Contra Fund', 'returns': '29.3%', 'nav': '342.15', 'managedBy': 'SBI Mutual Fund', 'rating': '5★', 'isLowExpense': false},
    ],
    'Tax Saver (ELSS)': [
      {'name': 'Quant ELSS Tax Saver', 'returns': '34.2%', 'nav': '312.45', 'managedBy': 'Quant AMC', 'rating': '5★', 'isLowExpense': false},
      {'name': 'Bank of India ELSS', 'returns': '28.9%', 'nav': '156.30', 'managedBy': 'BOI Mutual Fund', 'rating': '5★', 'isLowExpense': true},
      {'name': 'DSP ELSS Tax Saver', 'returns': '21.4%', 'nav': '98.50', 'managedBy': 'DSP Mutual Fund', 'rating': '4★', 'isLowExpense': true},
      {'name': 'Mirae Asset ELSS', 'returns': '18.7%', 'nav': '45.20', 'managedBy': 'Mirae Asset', 'rating': '4★', 'isLowExpense': false},
    ],
    'Index Funds': [
      {'name': 'UTI Nifty 50 Index', 'returns': '14.5%', 'nav': '145.20', 'managedBy': 'UTI Mutual Fund', 'rating': '5★', 'isLowExpense': true},
      {'name': 'HDFC Index S&P BSE', 'returns': '14.2%', 'nav': '138.10', 'managedBy': 'HDFC Mutual Fund', 'rating': '5★', 'isLowExpense': true},
      {'name': 'Navi Nifty 50 Index', 'returns': '14.8%', 'nav': '12.45', 'managedBy': 'Navi Mutual Fund', 'rating': '4★', 'isLowExpense': true},
      {'name': 'ICICI Pru Nifty 50', 'returns': '14.1%', 'nav': '189.30', 'managedBy': 'ICICI Prudential', 'rating': '5★', 'isLowExpense': false},
    ],
    'Better than FD': [
      {'name': 'ICICI Pru Liquid Fund', 'returns': '7.2%', 'nav': '312.40', 'managedBy': 'ICICI Prudential', 'rating': '5★', 'isLowExpense': true},
      {'name': 'HDFC Liquid Fund', 'returns': '7.1%', 'nav': '4560.20', 'managedBy': 'HDFC Mutual Fund', 'rating': '5★', 'isLowExpense': true},
      {'name': 'SBI Liquid Fund', 'returns': '6.9%', 'nav': '3500.10', 'managedBy': 'SBI Mutual Fund', 'rating': '4★', 'isLowExpense': false},
      {'name': 'Axis Liquid Fund', 'returns': '7.0%', 'nav': '2412.30', 'managedBy': 'Axis Mutual Fund', 'rating': '4★', 'isLowExpense': true},
    ],
  };

  List<Map<String, dynamic>> _getFilteredFunds() {
    List<Map<String, dynamic>> funds = _categoryDatasets[widget.categoryName] ?? _categoryDatasets['High Return Picks']!;
    
    // Apply filters
    if (_selectedFilter == 'Top Rated') {
      return funds.where((f) => f['rating'] == '5★').toList();
    } else if (_selectedFilter == 'Rating: 4★+') {
      return funds.where((f) => f['rating'] == '5★' || f['rating'] == '4★').toList();
    } else if (_selectedFilter == 'Low Expense Ratio') {
      return funds.where((f) => f['isLowExpense'] == true).toList();
    } else if (_selectedFilter == 'Best Returns') {
      var sorted = List<Map<String, dynamic>>.from(funds);
      sorted.sort((a, b) {
        double retA = double.parse(a['returns'].replaceAll('%', ''));
        double retB = double.parse(b['returns'].replaceAll('%', ''));
        return retB.compareTo(retA);
      });
      return sorted;
    }
    
    return funds;
  }

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
                searchText: 'Search in ${widget.categoryName}',
                onHomeTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
                onLogoutTap: () => Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false),
                onNotificationTap: () {},
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back, color: kForest, size: 18),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Best ${widget.categoryName} Funds',
                      style: const TextStyle(color: kForest, fontWeight: FontWeight.bold, fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRiskHeader(),
                  _buildFilterChips(),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: ListView.builder(
                        key: ValueKey('${widget.categoryName}_$_selectedFilter'),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        itemCount: _getFilteredFunds().length,
                        itemBuilder: (context, index) => _buildFundRow(_getFilteredFunds()[index]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: 4,
        onTap: (index) {
          if (index == 4) return;
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/home',
            (route) => false,
            arguments: {'index': index},
          );
        },
        onLogoutTap: () => Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false),
        onNotificationTap: () {},
      ),
    );
  }

  Widget _buildRiskHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              widget.riskLevel.toUpperCase(),
              style: const TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Objective: Capital appreciation through long-term investments in ${widget.categoryName.toLowerCase()} stocks.',
            style: const TextStyle(color: kSub, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 60,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedFilter == _filters[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
            child: FilterChip(
              label: Text(_filters[index]),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedFilter = _filters[index]),
              backgroundColor: kCream,
              selectedColor: kForest,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : kForest,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              side: BorderSide(color: isSelected ? kForest : Colors.grey.withValues(alpha: 0.1)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFundRow(Map<String, dynamic> fund) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: kCream, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.account_balance_wallet_outlined, color: kForest),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(fund['name'], style: const TextStyle(color: kForest, fontWeight: FontWeight.bold, fontSize: 15)),
                    Icon(Icons.favorite_border, color: Colors.red.withValues(alpha: 0.3), size: 20),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(fund['managedBy'], style: const TextStyle(color: kSub, fontSize: 11)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text(fund['rating'], style: const TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('3Y RETURNS', style: TextStyle(color: kSub, fontSize: 8, fontWeight: FontWeight.bold)),
                        Text(fund['returns'], style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(width: 32),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('CURRENT NAV', style: TextStyle(color: kSub, fontSize: 8, fontWeight: FontWeight.bold)),
                        Text('₹${fund['nav']}', style: const TextStyle(color: kForest, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
