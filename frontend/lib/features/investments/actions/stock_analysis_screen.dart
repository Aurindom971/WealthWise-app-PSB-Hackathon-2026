import 'package:flutter/material.dart';

class StockAnalysisScreen extends StatefulWidget {
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
  State<StockAnalysisScreen> createState() => _StockAnalysisScreenState();
}

class _StockAnalysisScreenState extends State<StockAnalysisScreen> {
  static const Color kForest = Color(0xFF1F5D3A);
  static const Color kCream = Color(0xFFF2F0EB);
  
  List<double> _hourlyPrices = [];
  List<String> _hourlyLabels = [];
  int? _selectedBarIndex;
  
  late double _basePrice;
  late double _highPrice;
  late double _lowPrice;
  late double _openPrice;
  late String _volume;

  @override
  void initState() {
    super.initState();
    _generate24hData();
  }

  void _generate24hData() {
    _basePrice = double.tryParse(widget.price.replaceAll(',', '')) ?? 1000.0;
    
    // Parse change percentage
    final double changePercent = double.tryParse(
      widget.change.replaceAll('+', '').replaceAll('-', '').replaceAll('%', ''),
    ) ?? 1.0;
    
    // Starting price 24h ago
    final double price24hAgo = widget.isUp 
        ? _basePrice / (1 + changePercent / 100) 
        : _basePrice / (1 - changePercent / 100);
    
    // Generate 24 hourly prices with a beautiful random walk simulation
    _hourlyPrices = List.generate(24, (index) {
      if (index == 23) return _basePrice;
      
      double fraction = index / 23.0;
      double trend = price24hAgo + (_basePrice - price24hAgo) * fraction;
      
      // Seeded fluctuation based on index and symbol to remain consistent
      double seed = widget.symbol.codeUnitAt(0) * (index + 1);
      double wave = (seed % 7 - 3) * 0.001 * _basePrice;
      double sinWave = 0.003 * _basePrice * (index % 5 == 0 ? 1.0 : -0.8) * fraction;
      
      double val = trend + wave + sinWave;
      return val > 0 ? val : 1.0;
    });

    // Extract statistics
    _openPrice = price24hAgo;
    _highPrice = _hourlyPrices.reduce((a, b) => a > b ? a : b);
    _lowPrice = _hourlyPrices.reduce((a, b) => a < b ? a : b);
    
    // Ensure boundaries envelop base price and open price
    if (_highPrice < _basePrice) _highPrice = _basePrice;
    if (_highPrice < _openPrice) _highPrice = _openPrice;
    if (_lowPrice > _basePrice) _lowPrice = _basePrice;
    if (_lowPrice > _openPrice) _lowPrice = _openPrice;

    // Volume calculation
    final double rawVolume = (_basePrice > 1000) ? 8.2 * (_basePrice / 100) : 48.5 * _basePrice;
    _volume = "${rawVolume.toStringAsFixed(1)}K";

    // Hours generation
    final now = DateTime.now();
    _hourlyLabels = List.generate(24, (index) {
      final time = now.subtract(Duration(hours: 23 - index));
      final hourStr = time.hour.toString().padLeft(2, '0');
      return "$hourStr:00";
    });

    // Default to the latest hour (current price)
    _selectedBarIndex = 23;
  }

  void _handleTouch(double localX, double totalWidth) {
    if (totalWidth <= 0) return;
    double segmentWidth = totalWidth / 24.0;
    int index = (localX / segmentWidth).floor().clamp(0, 23);
    if (index != _selectedBarIndex) {
      setState(() {
        _selectedBarIndex = index;
      });
    }
  }

  String _formatCurrency(double val) {
    String valStr = val.toStringAsFixed(2);
    List<String> parts = valStr.split('.');
    String integerPart = parts[0];
    String decimalPart = parts[1];
    
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    integerPart = integerPart.replaceAllMapped(reg, (Match m) => '${m[1]},');
    return "$integerPart.$decimalPart";
  }

  @override
  Widget build(BuildContext context) {
    final double currentPrice = _selectedBarIndex != null ? _hourlyPrices[_selectedBarIndex!] : _basePrice;
    
    // Change relative to the 24h open price
    final double changeAmt = currentPrice - _openPrice;
    final double changePct = (changeAmt / _openPrice) * 100;
    final bool isUp = changeAmt >= 0;
    
    final String activeLabel = _selectedBarIndex == 23 
        ? 'Live Market Price - April 2026' 
        : 'Price at ${_hourlyLabels[_selectedBarIndex ?? 23]}';

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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.chevron_left, size: 28, color: kForest),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Stock Analysis',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: kForest,
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    // Detail Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
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
                                      widget.symbol,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFF6B7280),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.name,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: kForest,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isUp 
                                      ? const Color(0xFFE8F5E9) 
                                      : const Color(0xFFFFEBEE),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  '${isUp ? "+" : ""}${changePct.toStringAsFixed(2)}%',
                                  style: TextStyle(
                                    color: isUp 
                                        ? const Color(0xFF2E7D32) 
                                        : const Color(0xFFC62828),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            '₹${_formatCurrency(currentPrice)}',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: kForest,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            activeLabel,
                            style: const TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 28),
                          
                          // Beautiful Interactive Bar Chart Area
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final double totalWidth = constraints.maxWidth;
                              
                              double minP = _lowPrice;
                              double maxP = _highPrice;
                              double range = maxP - minP;
                              if (range == 0) range = 1.0;

                              return GestureDetector(
                                onTapDown: (details) => _handleTouch(details.localPosition.dx, totalWidth),
                                onHorizontalDragStart: (details) => _handleTouch(details.localPosition.dx, totalWidth),
                                onHorizontalDragUpdate: (details) => _handleTouch(details.localPosition.dx, totalWidth),
                                child: Container(
                                  height: 180,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9FAFB),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(0xFFE5E7EB),
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      // Top Header Info Inside Chart
                                      Positioned(
                                        top: 12,
                                        left: 12,
                                        right: 12,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Performance (24h)',
                                              style: TextStyle(
                                                color: Color(0xFF9CA3AF),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            if (_selectedBarIndex != null)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: const Color(0xFFE5E7EB)),
                                                ),
                                                child: Text(
                                                  '${_hourlyLabels[_selectedBarIndex!]} : ₹${_hourlyPrices[_selectedBarIndex!].toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                    color: kForest,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      
                                      // Horizontal Guide Grid Lines
                                      Positioned.fill(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: List.generate(3, (index) {
                                            return Container(
                                              margin: const EdgeInsets.symmetric(horizontal: 12),
                                              height: 1,
                                              color: Colors.grey.withValues(alpha: 0.08),
                                            );
                                          }),
                                        ),
                                      ),

                                      // Selected Bar vertical dashed guideline
                                      if (_selectedBarIndex != null)
                                        Positioned(
                                          top: 35,
                                          bottom: 12,
                                          left: ((_selectedBarIndex! + 0.5) / 24.0) * totalWidth - 0.5,
                                          child: Container(
                                            width: 1,
                                            color: kForest.withValues(alpha: 0.3),
                                          ),
                                        ),

                                      // The actual Bars
                                      Positioned(
                                        left: 8,
                                        right: 8,
                                        bottom: 12,
                                        top: 38,
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: List.generate(24, (index) {
                                            final double price = _hourlyPrices[index];
                                            
                                            // Scale height between 15% and 100% of maximum height
                                            final double scale = 0.15 + 0.85 * ((price - minP) / range);
                                            
                                            final bool isSelected = _selectedBarIndex == index;
                                            
                                            // Color Scheme: vibrant solid color for selected, faded for others
                                            final Color barColor = widget.isUp 
                                                ? (isSelected ? const Color(0xFF10B981) : const Color(0xFF10B981).withValues(alpha: 0.25))
                                                : (isSelected ? const Color(0xFFEF4444) : const Color(0xFFEF4444).withValues(alpha: 0.25));

                                            return Expanded(
                                              child: AnimatedContainer(
                                                duration: const Duration(milliseconds: 100),
                                                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                                height: double.infinity,
                                                alignment: Alignment.bottomCenter,
                                                child: FractionallySizedBox(
                                                  heightFactor: scale.clamp(0.1, 1.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: barColor,
                                                      borderRadius: const BorderRadius.vertical(
                                                        top: Radius.circular(4),
                                                      ),
                                                      boxShadow: isSelected ? [
                                                        BoxShadow(
                                                          color: barColor.withValues(alpha: 0.4),
                                                          blurRadius: 6,
                                                          offset: const Offset(0, -2),
                                                        ),
                                                      ] : null,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          
                          // Axis time markers
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_hourlyLabels[0], style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 10, fontWeight: FontWeight.w500)),
                              Text(_hourlyLabels[6], style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 10, fontWeight: FontWeight.w500)),
                              Text(_hourlyLabels[12], style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 10, fontWeight: FontWeight.w500)),
                              Text(_hourlyLabels[18], style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 10, fontWeight: FontWeight.w500)),
                              const Text('Now', style: TextStyle(color: kForest, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Premium 24h Stats Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '24h Key Metrics',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: kForest,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            childAspectRatio: 2.2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            children: [
                              _buildMetricItem(
                                '24h High', 
                                '₹${_formatCurrency(_highPrice)}', 
                                Icons.arrow_upward_rounded, 
                                const Color(0xFF10B981),
                              ),
                              _buildMetricItem(
                                '24h Low', 
                                '₹${_formatCurrency(_lowPrice)}', 
                                Icons.arrow_downward_rounded, 
                                const Color(0xFFEF4444),
                              ),
                              _buildMetricItem(
                                'Open Price', 
                                '₹${_formatCurrency(_openPrice)}', 
                                Icons.play_circle_outline_rounded, 
                                Colors.blue.shade600,
                              ),
                              _buildMetricItem(
                                '24h Volume', 
                                _volume, 
                                Icons.bar_chart_rounded, 
                                kForest,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Buy Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kForest,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 4,
                          shadowColor: kForest.withValues(alpha: 0.3),
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

  Widget _buildMetricItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.1),
            radius: 16,
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: kForest,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
