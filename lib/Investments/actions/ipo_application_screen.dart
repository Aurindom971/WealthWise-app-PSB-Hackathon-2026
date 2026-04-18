import 'package:flutter/material.dart';
import '../../features/send/screens/send_transfer_screen.dart';

class IPOApplicationScreen extends StatefulWidget {
  final String companyName;
  final String dates;
  final String priceRange;
  final int lotSize;
  final String minAmount;

  const IPOApplicationScreen({
    super.key,
    required this.companyName,
    required this.dates,
    required this.priceRange,
    required this.lotSize,
    required this.minAmount,
  });

  @override
  State<IPOApplicationScreen> createState() => _IPOApplicationScreenState();
}

class _IPOApplicationScreenState extends State<IPOApplicationScreen> {
  final Color kForest = const Color(0xFF1B422B);
  final Color kLightGreen = const Color(0xFFF1F5F2);
  final Color kBorder = const Color(0xFFE0E0E0);
  final Color kTextGrey = const Color(0xFF757575);

  int _numberOfLots = 1;
  bool _isCutOffPrice = true;
  final TextEditingController _upiController = TextEditingController();

  @override
  void dispose() {
    _upiController.dispose();
    super.dispose();
  }

  double _getMaxPrice() {
    try {
      final parts = widget.priceRange.split('-');
      final lastPart = parts.last.replaceAll('₹', '').replaceAll(',', '').trim();
      return double.parse(lastPart);
    } catch (e) {
      return 0.0;
    }
  }

  double _getTotalAmount() {
    return _numberOfLots * widget.lotSize * _getMaxPrice();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: kBorder),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(
          'Apply for ${widget.companyName} IPO',
          style: TextStyle(
            color: kForest,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCompanyHeader(),
            const SizedBox(height: 24),
            _buildBidDetails(),
            const SizedBox(height: 24),
            _buildPaymentMethod(),
            const SizedBox(height: 40),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFFF5F5F5),
                child: Text(
                  widget.companyName[0].toUpperCase(),
                  style: TextStyle(
                    color: kForest,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.companyName,
                      style: TextStyle(
                        color: kForest,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.dates,
                      style: TextStyle(
                        color: kTextGrey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildInfoItem('Price Range', widget.priceRange),
              _buildInfoItem('Lot Size', '${widget.lotSize} Shares'),
              _buildInfoItem('Min Amount', widget.minAmount),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAF9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(color: kTextGrey, fontSize: 10),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: kForest,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: kForest,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }


  Widget _buildBidDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Bid Details'),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Number of Lots',
                style: TextStyle(color: kForest, fontSize: 15),
              ),
              Row(
                children: [
                  _buildCounterButton(Icons.remove, () {
                    if (_numberOfLots > 1) setState(() => _numberOfLots--);
                  }),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '$_numberOfLots',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildCounterButton(Icons.add, () {
                    setState(() => _numberOfLots++);
                  }),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDetailRow('Quantity', '${_numberOfLots * widget.lotSize} shares'),
          const SizedBox(height: 12),
          _buildDetailRow('Price per share', '₹${_getMaxPrice().toInt()}'),
          const SizedBox(height: 16),
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _isCutOffPrice = !_isCutOffPrice),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _isCutOffPrice ? kForest : Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: kForest),
                  ),
                  child: _isCutOffPrice
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Bid at Cut-off Price',
                style: TextStyle(color: kForest, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounterButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: kForest, size: 20),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: kTextGrey, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            color: kForest,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethod() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Payment Method'),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _upiController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter UPI ID (e.g., user@bank)',
                hintStyle: TextStyle(color: kTextGrey, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Funds will be blocked in your account and only debited if allotted shares.',
            style: TextStyle(color: kTextGrey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    final totalAmount = _getTotalAmount();
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kForest, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount to Block',
                style: TextStyle(
                  color: kForest,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                '₹${totalAmount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                style: TextStyle(
                  color: kForest,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpiScreen(
                    prefilledUpiId: _upiController.text.isNotEmpty ? _upiController.text : "psb.invest@upi",
                    prefilledAmount: totalAmount.toStringAsFixed(2),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kForest,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Place Bid & Pay',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
