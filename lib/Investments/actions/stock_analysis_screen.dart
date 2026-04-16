import 'package:flutter/material.dart';

class StockAnalysisScreen extends StatelessWidget {
  final String symbol;
  final String name;
  final String price;
  final String change;
  final bool isUp;
  final List<double> history;

  const StockAnalysisScreen({
    super.key,
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.isUp,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // gray-50
      body: SafeArea(
        child: Column(
          children: [
            // Header
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
                      child: const Icon(Icons.chevron_left, size: 28),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Stock Analysis',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Detail Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: const Color(0xFFF3F4F6)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
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
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      symbol,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFF6B7280),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      name,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isUp 
                                      ? const Color(0xFFF0FDF4) 
                                      : const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  '$change%',
                                  style: TextStyle(
                                    color: isUp 
                                        ? const Color(0xFF16A34A) 
                                        : const Color(0xFFDC2626),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            '₹$price',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF111827),
                              letterSpacing: -1,
                            ),
                          ),
                          const Text(
                            'Live Market Price - April 2026',
                            style: TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Placeholder Graph Area
                          Container(
                            height: 180,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Stack(
                              children: [
                                const Positioned(
                                  top: 12,
                                  left: 12,
                                  child: Text(
                                    'Performance (24h)',
                                    style: TextStyle(
                                      color: Color(0xFF9CA3AF),
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  alignment: Alignment.bottomCenter,
                                  child: history.isEmpty 
                                    ? const Center(child: Text('No data available', style: TextStyle(color: Colors.grey, fontSize: 10)))
                                    : Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: history.map((h) {
                                      double maxVal = 3000.0;
                                      // Clamp value to ensure it doesn't exceed max or cause negative heights
                                      double validH = h.clamp(0.0, maxVal);
                                      double heightFactor = validH / maxVal;
                                      return Expanded(
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 2),
                                          height: (156 * heightFactor).clamp(4.0, 156.0),
                                          decoration: BoxDecoration(
                                            color: isUp 
                                                ? const Color(0xFF4ADE80).withValues(alpha: 0.3)
                                                : const Color(0xFFF87171).withValues(alpha: 0.3),
                                            borderRadius: const BorderRadius.vertical(
                                              top: Radius.circular(8),
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
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    // Buy Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB), // blue-600
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 8,
                          shadowColor: const Color(0xFF2563EB).withValues(alpha: 0.3),
                        ),
                        child: const Text(
                          'Buy Now',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
