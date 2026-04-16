import 'package:flutter/material.dart';

class FIIDIIInsightsScreen extends StatelessWidget {
  const FIIDIIInsightsScreen({super.key});

  final Color kDarkGreen = const Color(0xFF1B422B);
  final Color kDeepGreen = const Color(0xFF1B422B);
  final Color kLightGreen = const Color(0xFFEAF1ED);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'FII & DII Insights',
          style: TextStyle(
            color: kDarkGreen,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: kDarkGreen, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.ios_share, color: kDarkGreen, size: 22),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSentimentMeter(),
            const SizedBox(height: 24),
            _buildNetSummaryCard(),
            const SizedBox(height: 24),
            _buildSegmentedBreakdown(),
            const SizedBox(height: 24),
            _buildHistoricalChart(),
            const SizedBox(height: 24),
            _buildMarketPulseInsights(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSentimentMeter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kDarkGreen,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: kDarkGreen.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overall Sentiment',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              Text(
                'NEUTRAL',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 12,
                    height: 12,
                    transform: Matrix4.translationValues(0, -2, 0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              Container(
                width: 100, // Partial fill
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red, Colors.yellow, Colors.green.shade400],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Bearish', style: TextStyle(color: Colors.white60, fontSize: 10)),
              Text('Bullish', style: TextStyle(color: Colors.white60, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNetSummaryCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Net Activity (Today)',
          style: TextStyle(
            color: kDarkGreen,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryItem(
                'FII Net',
                '-\u20B99,931.13 Cr',
                Colors.red.shade700,
                Icons.trending_down,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryItem(
                'DII Net',
                '+\u20B98,245.45 Cr',
                Colors.green.shade700,
                Icons.trending_up,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String title, String val, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
              Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              Icon(icon, color: color, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              val,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Segmental Breakdown',
          style: TextStyle(
            color: kDarkGreen,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        _buildSegmentRow('Cash Segment', '-\u20B92,450 Cr', 0.4, Colors.red.shade400),
        const SizedBox(height: 16),
        _buildSegmentRow('Index Futures', '+\u20B91,200 Cr', 0.6, Colors.green.shade400),
        const SizedBox(height: 16),
        _buildSegmentRow('Stock Futures', '-\u20B9840 Cr', 0.3, Colors.red.shade400),
      ],
    );
  }

  Widget _buildSegmentRow(String label, String value, double progress, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
            Text(
              value,
              style: TextStyle(
                color: color.withValues(alpha: 0.9),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade100,
            color: color.withValues(alpha: 0.6),
            minHeight: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoricalChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Historical Flows',
                style: TextStyle(
                  color: kDarkGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                'Last 10 Days',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 120,
            child: CustomPaint(
              size: Size.infinite,
              painter: HistoricalTrendPainter(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('FII', Colors.red.shade300),
              const SizedBox(width: 16),
              _buildLegendItem('DII', Colors.green.shade300),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
      ],
    );
  }

  Widget _buildMarketPulseInsights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Market Insights',
          style: TextStyle(
            color: kDarkGreen,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        _buildPulseCard(
          'Short Built Up by FII',
          'FIIs have added heavy shorts in Index Futures, indicating dynamic hedging against global volatility.',
          Icons.analytics_outlined,
        ),
        const SizedBox(height: 12),
        _buildPulseCard(
          'DII Absorption',
          'Domestic institutions continue to absorb the selling pressure in the cash segment, providing a floor to the market.',
          Icons.security_outlined,
        ),
      ],
    );
  }

  Widget _buildPulseCard(String title, String desc, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9F8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: kLightGreen,
            radius: 18,
            child: Icon(icon, color: kDarkGreen, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: kDarkGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    height: 1.4,
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

class HistoricalTrendPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fiiPaint = Paint()..color = Colors.red.shade300;
    final diiPaint = Paint()..color = Colors.green.shade300;

    const barWidth = 8.0;
    const spacing = 14.0;
    final fiiData = [0.4, 0.6, 0.3, 0.7, 0.5, 0.8, 0.6, 0.9, 0.5, 0.7];
    final diiData = [0.6, 0.4, 0.7, 0.5, 0.8, 0.6, 0.8, 0.5, 0.7, 0.6];

    for (int i = 0; i < 10; i++) {
        final x = i * (barWidth * 2 + spacing);
        
        // FII Bar
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(x, size.height - (fiiData[i] * size.height), barWidth, fiiData[i] * size.height),
            topLeft: const Radius.circular(2),
            topRight: const Radius.circular(2),
          ),
          fiiPaint,
        );

        // DII Bar
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(x + barWidth, size.height - (diiData[i] * size.height), barWidth, diiData[i] * size.height),
            topLeft: const Radius.circular(2),
            topRight: const Radius.circular(2),
          ),
          diiPaint,
        );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
