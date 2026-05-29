import 'package:flutter/material.dart';
import 'stock_analysis_screen.dart';

class MyHoldingsScreen extends StatelessWidget {
  const MyHoldingsScreen({super.key});

  final Color kDarkGreen = const Color(0xFF1F5D3A);
  final Color kOrange = const Color(0xFFDD754E);
  final Color kLightGreenBg = const Color(0xFFEAF1ED);
  final Color kCreamBg = const Color(0xFFF2F0EB);

  @override
  Widget build(BuildContext context) {
    // List of holdings data
    final List<Map<String, dynamic>> holdings = [
      {
        'symbol': 'RELIANCE',
        'name': 'Reliance Industries',
        'shares': '10 Shares',
        'price': '1,345',
        'profit': '+₹2,450',
        'percentage': '+4.2%',
        'isUp': true,
        'logoText': 'R',
        'logoColor': const Color(0xFF1E3A8A), // Deep Blue
        'history': [1344.0, 1350.0, 1340.0, 1348.0, 1345.0],
      },
      {
        'symbol': 'INFY',
        'name': 'Infosys Ltd',
        'shares': '15 Shares',
        'price': '1,316',
        'profit': '+₹1,800',
        'percentage': '+6.1%',
        'isUp': true,
        'logoText': 'I',
        'logoColor': const Color(0xFF0284C7), // Sky Blue
        'history': [1305.0, 1318.0, 1310.0, 1322.0, 1316.0],
      },
      {
        'symbol': 'TCS',
        'name': 'Tata Consultancy',
        'shares': '8 Shares',
        'price': '2,573',
        'profit': '+₹2,200',
        'percentage': '+12.0%',
        'isUp': true,
        'logoText': 'T',
        'logoColor': const Color(0xFF4F46E5), // Indigo
        'history': [2554.0, 2580.0, 2570.0, 2590.0, 2573.0],
      },
      {
        'symbol': 'HDFCBANK',
        'name': 'HDFC Bank Ltd',
        'shares': '12 Shares',
        'price': '794',
        'profit': '-₹450',
        'percentage': '-4.5%',
        'isUp': false,
        'logoText': 'H',
        'logoColor': const Color(0xFF0F172A), // Slate Dark
        'history': [810.0, 805.0, 812.0, 798.0, 794.0],
      },
      {
        'symbol': 'WIPRO',
        'name': 'Wipro Ltd',
        'shares': '20 Shares',
        'price': '210',
        'profit': '+₹500',
        'percentage': '+13.5%',
        'isUp': true,
        'logoText': 'W',
        'logoColor': const Color(0xFF7C3AED), // Violet
        'history': [209.0, 211.0, 210.0, 212.0, 210.0],
      },
    ];

    return Scaffold(
      backgroundColor: kCreamBg,
      body: SafeArea(
        child: Column(
          children: [
            // Elegant Top Header Bar
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
                    'My Holdings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: kDarkGreen,
                    ),
                  ),
                ],
              ),
            ),

            // Portfolio Investment Summary Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [kDarkGreen, kDarkGreen.withValues(alpha: 0.85)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: kDarkGreen.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Investment',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '₹50,000',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 40,
                    width: 1,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Value',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Row(
                          children: [
                            Text(
                              '₹57,500',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                            SizedBox(width: 6),
                            Text(
                              '+15%',
                              style: TextStyle(
                                color: Color(0xFF4ADE80), // Vibrant Green
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

            const SizedBox(height: 24),

            // Holdings List Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Assets Portfolio (${holdings.length})',
                    style: TextStyle(
                      color: kDarkGreen.withValues(alpha: 0.8),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Icon(
                    Icons.sort_rounded,
                    color: kDarkGreen.withValues(alpha: 0.6),
                    size: 20,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // clean vertical list of individual stocks
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                itemCount: holdings.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final asset = holdings[index];
                  final isUp = asset['isUp'] as bool;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.015),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StockAnalysisScreen(
                                  symbol: asset['symbol'],
                                  name: asset['name'],
                                  price: asset['price'],
                                  change: asset['percentage'].replaceAll('+', '').replaceAll('%', ''),
                                  isUp: isUp,
                                  history: List<double>.from(asset['history']),
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                // Company Logo Placeholder (Circle with initial)
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: (asset['logoColor'] as Color).withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    asset['logoText'],
                                    style: TextStyle(
                                      color: asset['logoColor'] as Color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),

                                // Ticker and Shares Owned
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        asset['symbol'],
                                        style: TextStyle(
                                          color: kDarkGreen,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        asset['shares'],
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Current Price and Lifetime Profit/Loss
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '₹${asset['price']}',
                                      style: TextStyle(
                                        color: kDarkGreen,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${asset['profit']} (${asset['percentage']})',
                                      style: TextStyle(
                                        color: isUp ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
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
}
