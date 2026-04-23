import 'package:flutter/material.dart';
import '../../send/screens/send_transfer_screen.dart';

const Color kForest = Color(0xFF1F5D3A);
const Color kCream = Color(0xFFFBFBF9);
const Color kSub = Color(0xFF9A9A94);

class QuickCheckoutModal extends StatefulWidget {
  final String fundName;
  final String nav;

  const QuickCheckoutModal({
    super.key,
    required this.fundName,
    required this.nav,
  });

  static void show(BuildContext context, String fundName, String nav) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickCheckoutModal(fundName: fundName, nav: nav),
    );
  }

  @override
  State<QuickCheckoutModal> createState() => _QuickCheckoutModalState();
}

class _QuickCheckoutModalState extends State<QuickCheckoutModal> {
  int _selectedPaymentIndex = 0;
  String? _selectedAccount;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'title': 'Bank Account',
      'icon': Icons.account_balance_outlined,
    },
    {
      'title': 'UPI',
      'icon': Icons.phone_android_outlined,
    },
    {
      'title': 'Net Banking',
      'icon': Icons.language_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Quick Checkout', style: TextStyle(color: kForest, fontSize: 20, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const Row(
                  children: [
                    Icon(Icons.lock_outline, color: Colors.green, size: 14),
                    SizedBox(width: 4),
                    Text('SECURE', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildFundSummary(),
          const SizedBox(height: 24),
          const Text('Payment Method', style: TextStyle(color: kForest, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          _buildPaymentMethodSelector(),
          const SizedBox(height: 32),
          _buildPricingSummary(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close modal
                if (_selectedPaymentIndex == 0 || _selectedPaymentIndex == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BankTransferScreen(
                        toAccount: "987654321012",
                        toIfsc: "PSIB0001234",
                        toNominee: "PSB Investment Portal",
                        toBank: "Punjab National Bank",
                        amount: "5000.25",
                        purpose: "Investment",
                        fromAccount: _selectedPaymentIndex == 0 ? _selectedAccount : null,
                      ),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UpiScreen(
                        prefilledUpiId: "psb.invest@upi",
                        prefilledAmount: "5000.25",
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kForest,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Pay Secured Now', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Column(
      children: [
        Row(
          children: _paymentMethods.asMap().entries.map((entry) {
            int idx = entry.key;
            var method = entry.value;
            bool isSelected = _selectedPaymentIndex == idx;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedPaymentIndex = idx),
                child: Container(
                  margin: EdgeInsets.only(right: idx == 2 ? 0 : 12),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? kForest.withValues(alpha: 0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isSelected ? kForest : Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(method['icon'], color: isSelected ? kForest : kSub, size: 24),
                      const SizedBox(height: 8),
                      Text(method['title'], style: TextStyle(color: isSelected ? kForest : kSub, fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (_selectedPaymentIndex == 0) ...[
          const SizedBox(height: 16),
          ...userAccounts.where((a) => a.contains('Savings')).map((acc) {
            bool isAccSelected = _selectedAccount == acc;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => setState(() => _selectedAccount = acc),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isAccSelected ? kForest.withValues(alpha: 0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isAccSelected ? kForest : Colors.grey.shade100),
                  ),
                  child: Row(
                    children: [
                      Icon(isAccSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isAccSelected ? kForest : kSub, size: 16),
                      const SizedBox(width: 12),
                      Text(acc, style: TextStyle(color: kForest, fontSize: 12, fontWeight: isAccSelected ? FontWeight.bold : FontWeight.normal)),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildFundSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCream,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.auto_graph, color: kForest, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.fundName, style: const TextStyle(color: kForest, fontWeight: FontWeight.bold, fontSize: 15)),
                Text('Current NAV: ₹${widget.nav}', style: const TextStyle(color: kSub, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSummary() {
    return Column(
      children: [
        _buildPriceRow('Mutual Fund units', '₹5,000.00'),
        const SizedBox(height: 8),
        _buildPriceRow('Stamp Duty (0.005%)', '₹0.25'),
        const Divider(height: 24),
        _buildPriceRow('Total Payable', '₹5,000.25', isTotal: true),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: isTotal ? kForest : kSub, fontSize: isTotal ? 15 : 13, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(color: kForest, fontSize: isTotal ? 18 : 13, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
