import 'package:flutter/material.dart';

class OILosersScreen extends StatefulWidget {
  const OILosersScreen({super.key});

  @override
  State<OILosersScreen> createState() => _OILosersScreenState();
}

class _OILosersScreenState extends State<OILosersScreen> {
  final Color kForest = const Color(0xFF1F5D3A);
  final Color kCream = const Color(0xFFFBFBF9);
  final int _hoveredRowIndex = 0; // Simulate first row being hovered

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: kForest, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'OI Losers',
          style: TextStyle(color: kForest, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list_rounded, color: kForest),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBubbleCloud(),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Position Analysis',
                style: TextStyle(color: kForest, fontWeight: FontWeight.bold, fontSize: 17),
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailedTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildBubbleCloud() {
    return Container(
      height: 220,
      width: double.infinity,
      color: kCream,
      padding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          _buildBubble('NIFTY', -12.4, 80, 20, 40),
          _buildBubble('BANK NIFTY', -18.2, 110, 140, 20),
          _buildBubble('RELIANCE', -8.5, 70, 250, 70),
          _buildBubble('HDFC', -15.1, 90, 40, 100),
          _buildBubble('INFY', -22.4, 100, 180, 100),
          _buildBubble('TCS', -5.2, 60, 280, 20),
        ],
      ),
    );
  }

  Widget _buildBubble(String label, double change, double size, double left, double top) {
    bool isHeavy = change.abs() > 15;
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isHeavy ? Colors.orange.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.1),
          border: Border.all(
            color: isHeavy ? Colors.orange.withValues(alpha: 0.4) : Colors.red.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isHeavy ? Colors.orange.shade800 : Colors.red.shade800,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              '$change%',
              style: TextStyle(
                color: isHeavy ? Colors.orange.shade800 : Colors.red.shade800,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedTable() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildHeader(),
          const Divider(),
          _buildRow(0, 'NIFTY 22800 PE', '142.50', '-12.4%', 'Short Covering'),
          _buildRow(1, 'BNIFTY 48000 PE', '845.20', '-18.2%', 'Long Unwinding'),
          _buildRow(2, 'RELIANCE 2400 PE', '3.85', '-8.5%', 'Short Covering'),
          _buildRow(3, 'INFY 1600 PE', '22.40', '-22.4%', 'Long Unwinding'),
          _buildRow(4, 'TCS 3800 PE', '45.10', '-5.2%', 'Short Covering'),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('Contract', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('LTP', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('OI Chg%', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text('Interpretation', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildRow(int index, String contract, String ltp, String change, String mood) {
    bool isHovered = _hoveredRowIndex == index;
    return Container(
      decoration: BoxDecoration(
        color: isHovered ? Colors.red.withValues(alpha: 0.02) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    contract,
                    style: TextStyle(color: kForest, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    ltp,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    change,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    mood,
                    style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          if (isHovered)
            Padding(
              padding: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('View Option Chain', style: TextStyle(color: kForest, fontSize: 12)),
                ),
              ),
            ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
