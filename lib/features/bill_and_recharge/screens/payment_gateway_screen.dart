import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:securewealth_twin/features/home/widgets/home_navigation_widgets.dart';
import '../models/bill_models.dart';

class PaymentGatewayScreen extends StatefulWidget {
  final Bill bill;
  final VoidCallback onBack;
  final VoidCallback onSuccess;

  const PaymentGatewayScreen({
    super.key,
    required this.bill,
    required this.onBack,
    required this.onSuccess,
  });

  @override
  State<PaymentGatewayScreen> createState() => _PaymentGatewayScreenState();
}

class _PaymentGatewayScreenState extends State<PaymentGatewayScreen> with SingleTickerProviderStateMixin {
  bool _isProcessing = false;
  bool _isSuccess = false;
  late AnimationController _checkController;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _checkAnimation = CurvedAnimation(parent: _checkController, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  void _processPayment() async {
    setState(() => _isProcessing = true);

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
      _isSuccess = true;
    });
    _checkController.forward();
  }

  @override
  Widget build(BuildContext context) {
    if (_isSuccess) return _buildSuccessScreen();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: widget.onBack,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kCard,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: const Icon(Icons.arrow_back_rounded, color: kForest, size: 20),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Checkout',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: kForest,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Confirm Payment',
            style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: kForest),
          ),
          const SizedBox(height: 8),
          Text(
            'Secure payment for ${widget.bill.providerName}',
            style: GoogleFonts.inter(color: kSub, fontSize: 14),
          ),
          const SizedBox(height: 40),

          // Bill Summary Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Amount', style: GoogleFonts.inter(color: kSub)),
                    Text(
                      '₹${NumberFormat('#,##0.00').format(widget.bill.amount)}',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18, color: kForest),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Platform Fee', style: GoogleFonts.inter(color: kSub)),
                    Text('₹0.00', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Divider(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total to Pay',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: kForest),
                    ),
                    Text(
                      '₹${NumberFormat('#,##0.00').format(widget.bill.amount)}',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 24, color: kAccent),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
          Text(
            'Payment Method',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: kForest),
          ),
          const SizedBox(height: 16),
          
          // Mock UPI Option
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kAccent),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.account_balance_wallet_rounded, color: kAccent),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SecureWealth UPI', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: kForest)),
                      Text('rahul@swp', style: GoogleFonts.inter(color: kSub, fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.check_circle_rounded, color: kAccent),
              ],
            ),
          ),

          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _processPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: kForest,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 0,
              ),
              child: _isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Pay Securely',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.security_rounded, size: 14, color: kSub),
                const SizedBox(width: 8),
                Text(
                  'PCI-DSS Certified Secure',
                  style: GoogleFonts.inter(color: kSub, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSuccessScreen() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          ScaleTransition(
            scale: _checkAnimation,
            child: Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: kAccent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 60),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Payment Successful!',
            style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.bold, color: kForest),
          ),
          const SizedBox(height: 12),
          Text(
            'Your bill for ${widget.bill.providerName} has been paid.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: kSub, fontSize: 16),
          ),
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: kCream,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                _detailRow('Transaction ID', 'SWP_TRX_${DateTime.now().millisecondsSinceEpoch}'),
                const SizedBox(height: 16),
                _detailRow('Beneficiary', widget.bill.providerName),
                const SizedBox(height: 16),
                _detailRow('Amount Paid', '₹${NumberFormat('#,##0.00').format(widget.bill.amount)}'),
                const SizedBox(height: 16),
                _detailRow('Date', DateFormat('d MMM yyyy, HH:mm').format(DateTime.now())),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: widget.onSuccess,
              style: ElevatedButton.styleFrom(
                backgroundColor: kForest,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: Text('Back to Home', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 17)),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {},
            child: Text(
              'Download Receipt',
              style: GoogleFonts.inter(color: kForest, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(color: kSub, fontSize: 13)),
        Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: kForest, fontSize: 13)),
      ],
    );
  }
}
