import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../send/screens/send_transfer_screen.dart';

class StockDetailViewScreen extends StatefulWidget {
  final String title;
  final String price;
  final String change;
  final bool isUp;
  final String expiryDate;
  final String underlyingIndexName;
  final String underlyingIndexValue;
  final String underlyingIndexChange;

  const StockDetailViewScreen({
    super.key,
    required this.title,
    required this.price,
    required this.change,
    this.isUp = false,
    this.expiryDate = '30 Jun 2026',
    this.underlyingIndexName = 'Nifty Financial Services',
    this.underlyingIndexValue = '25,354.00',
    this.underlyingIndexChange = '-398.20 (-1.55%)',
  });

  @override
  State<StockDetailViewScreen> createState() => _StockDetailViewScreenState();
}

class _StockDetailViewScreenState extends State<StockDetailViewScreen> {
  final Color kForest = const Color(0xFF1F5D3A);
  final Color kDarkBg = const Color(0xFF111417); // Premium dark theme matching reference image
  int _selectedTimeframeIndex = 2; // 1M selected by default in image
  final List<String> _timeframes = ['1D', '1W', '1M'];
  bool _isPutSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header: Back button, Expiry & Share
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.1),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: const Icon(Icons.arrow_back, size: 18, color: Colors.white),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, color: Colors.grey.shade400, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        widget.expiryDate,
                        style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    child: const Icon(Icons.share_outlined, size: 18, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            // Stock Summary Detail
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Blue up-trending icon
                    CircleAvatar(
                      backgroundColor: Colors.blue.withValues(alpha: 0.2),
                      radius: 26,
                      child: const Icon(Icons.trending_up, color: Colors.blue, size: 28),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.price,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 38,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '1D: ${widget.change}',
                          style: TextStyle(
                            color: widget.isUp ? Colors.greenAccent : Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•  1M: ${widget.change}',
                          style: TextStyle(
                            color: widget.isUp ? Colors.greenAccent : Colors.redAccent,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.expiryDate,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Horizontal continuous red/green sparkline trend chart
                    SizedBox(
                      height: 80,
                      width: double.infinity,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: const [
                                FlSpot(0, 4),
                                FlSpot(2, 2.5),
                                FlSpot(4, 3.8),
                                FlSpot(6, 2.0),
                                FlSpot(8, 1.8),
                                FlSpot(10, 1.2),
                              ],
                              isCurved: true,
                              color: widget.isUp ? Colors.greenAccent : Colors.redAccent,
                              barWidth: 2,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: (widget.isUp ? Colors.greenAccent : Colors.redAccent).withValues(alpha: 0.05),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Put/Call Dropdown & Timeframe Selection
                    Row(
                      children: [
                        // Dropdown-like pill
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isPutSelected = !_isPutSelected;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  _isPutSelected ? 'Put' : 'Call',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 16),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Timeframes
                        Row(
                          children: List.generate(_timeframes.length, (index) {
                            bool isSelected = _selectedTimeframeIndex == index;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedTimeframeIndex = index),
                              child: Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF10B981) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  _timeframes[index],
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.grey.shade400,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Tabs row: Overview, Insights, News
                    Row(
                      children: [
                        _buildSectionTab('Overview', true),
                        _buildSectionTab('Insights', false),
                        _buildSectionTab('News', false),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
                    const SizedBox(height: 24),

                    // Underlying Index Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2229),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blue.withValues(alpha: 0.2),
                            radius: 18,
                            child: const Icon(Icons.electric_bolt, color: Colors.blue, size: 16),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.underlyingIndexName,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      widget.underlyingIndexValue,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      widget.underlyingIndexChange,
                                      style: TextStyle(color: Colors.red.shade400, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            
            // Bottom sell/buy buttons
            _buildBottomTradingActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTab(String label, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 24),
      padding: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isActive ? const Color(0xFF10B981) : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.grey.shade500,
          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildBottomTradingActions(BuildContext context) {
    double numericPrice = double.tryParse(widget.price.replaceAll(',', '')) ?? 25000.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C20),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Sell button
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BankTransferScreen(
                        toAccount: "987654321012",
                        toIfsc: "PSIB0001234",
                        toNominee: "PSB Investment Portal",
                        toBank: "Punjab National Bank",
                        amount: numericPrice.toStringAsFixed(2),
                        purpose: "F&O Contract Sell",
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Sell', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Buy button
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BankTransferScreen(
                        toAccount: "987654321012",
                        toIfsc: "PSIB0001234",
                        toNominee: "PSB Investment Portal",
                        toBank: "Punjab National Bank",
                        amount: numericPrice.toStringAsFixed(2),
                        purpose: "F&O Contract Buy",
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Buy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
