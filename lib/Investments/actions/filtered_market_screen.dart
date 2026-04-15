import 'package:flutter/material.dart';
import '../../features/home/widgets/home_navigation_widgets.dart';

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

  final List<Map<String, dynamic>> _mockFunds = [
    {
      'name': 'Quant Small Cap Fund',
      'returns': '38.4%',
      'nav': '214.20',
      'managedBy': 'Quant AMC',
      'rating': '5★',
    },
    {
      'name': 'Axis Small Cap Fund',
      'returns': '26.8%',
      'nav': '84.50',
      'managedBy': 'Axis Mutual Fund',
      'rating': '4★',
    },
    {
      'name': 'Nippon India Small Cap',
      'returns': '31.2%',
      'nav': '145.10',
      'managedBy': 'Nippon India',
      'rating': '5★',
    },
    {
      'name': 'HDFC Small Cap Fund',
      'returns': '22.5%',
      'nav': '112.90',
      'managedBy': 'HDFC Mutual Fund',
      'rating': '4★',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: kForest, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Best ${widget.categoryName} Funds',
          style: const TextStyle(color: kForest, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRiskHeader(),
          _buildFilterChips(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: _mockFunds.length,
              itemBuilder: (context, index) => _buildFundRow(_mockFunds[index]),
            ),
          ),
        ],
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
