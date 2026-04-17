import 'package:flutter/material.dart';
import '../../features/home/widgets/home_navigation_widgets.dart';
import 'filtered_market_screen.dart';

class ExploreFundsScreen extends StatefulWidget {
  const ExploreFundsScreen({super.key});

  @override
  State<ExploreFundsScreen> createState() => _ExploreFundsScreenState();
}

class _ExploreFundsScreenState extends State<ExploreFundsScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _trendingCollections = [
    {
      'title': 'High Return Picks',
      'subtitle': 'Top performers for the last 3 years',
      'icon': Icons.trending_up,
      'color': Colors.green.shade700,
      'funds': '24 Funds',
    },
    {
      'title': 'Tax Saver (ELSS)',
      'subtitle': 'Save up to ₹46,800 in taxes',
      'icon': Icons.shield_outlined,
      'color': Colors.blue.shade700,
      'funds': '12 Funds',
    },
    {
      'title': 'Index Funds',
      'subtitle': 'Low-cost market tracking funds',
      'icon': Icons.list_alt,
      'color': Colors.purple.shade700,
      'funds': '18 Funds',
    },
    {
      'title': 'Better than FD',
      'subtitle': 'Liquid & Debt funds for safety',
      'icon': Icons.account_balance,
      'color': Colors.orange.shade700,
      'funds': '15 Funds',
    },
  ];

  final List<Map<String, dynamic>> _recentlyViewed = [
    {'name': 'Quant Small Cap', 'return': '38.4%', 'category': 'Small Cap'},
    {'name': 'Axis Mid Cap', 'return': '24.2%', 'category': 'Mid Cap'},
    {'name': 'SBI Bluechip', 'return': '15.8%', 'category': 'Large Cap'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(),
                    _buildRecentlyViewed(),
                    _buildSectionTitle('Trending Collections'),
                    _buildTrendingCollections(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back, color: kForest, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Mutual Fund Discovery',
            style: TextStyle(color: kForest, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search by fund house or category',
            hintStyle: TextStyle(color: kSub, fontSize: 14),
            icon: Icon(Icons.search, color: kSub, size: 22),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildRecentlyViewed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Recently Viewed'),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _recentlyViewed.length,
            itemBuilder: (context, index) {
              final fund = _recentlyViewed[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      fund['name'],
                      style: const TextStyle(color: kForest, fontWeight: FontWeight.bold, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(fund['return'], style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(width: 4),
                        const Text('3Y', style: TextStyle(color: kSub, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(
        title,
        style: const TextStyle(color: kForest, fontSize: 17, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTrendingCollections() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _trendingCollections.length,
      itemBuilder: (context, index) {
        final collection = _trendingCollections[index];
        return GestureDetector(
          onTap: () {
            String risk = 'Moderate Risk';
            if (collection['title'] == 'High Return Picks') risk = 'Very High Risk';
            if (collection['title'] == 'Tax Saver (ELSS)') risk = 'High Risk';
            if (collection['title'] == 'Better than FD') risk = 'Low Risk';

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FilteredMarketScreen(
                  categoryName: collection['title'],
                  riskLevel: risk,
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: collection['color'].withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(collection['icon'], color: collection['color'], size: 24),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(collection['title'], style: const TextStyle(color: kForest, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(collection['subtitle'], style: const TextStyle(color: kSub, fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(collection['funds'], style: const TextStyle(color: kForest, fontWeight: FontWeight.bold, fontSize: 12)),
                    const Icon(Icons.chevron_right, color: kSub, size: 20),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
