import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../features/home/widgets/home_navigation_widgets.dart';
import '../../features/send/screens/send_transfer_screen.dart';

class LumpsumInvestmentScreen extends StatefulWidget {
  final String fundName;
  const LumpsumInvestmentScreen({super.key, required this.fundName});

  @override
  State<LumpsumInvestmentScreen> createState() => _LumpsumInvestmentScreenState();
}

class _LumpsumInvestmentScreenState extends State<LumpsumInvestmentScreen> {
  double _amount = 50000;
  late TextEditingController _amountController;
  int _selectedPaymentIndex = 0;
  String? _selectedAccount;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: _amount.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'title': 'Bank Account',
      'subtitle': 'Linked savings account',
      'icon': Icons.account_balance_outlined,
    },
    {
      'title': 'UPI',
      'subtitle': 'Pay via UPI ID',
      'icon': Icons.phone_android_outlined,
    },
    {
      'title': 'Net Banking',
      'subtitle': 'All major banks',
      'icon': Icons.language_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    double stampDuty = _amount * 0.00005;
    double totalPayable = _amount + stampDuty;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8), // Slightly off-white/grey background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back, color: kForest, size: 20),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'Invest Lumpsum',
          style: TextStyle(color: kForest, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildAmountCard(),
            const SizedBox(height: 24),
            _buildPaymentMethodCard(),
            const SizedBox(height: 24),
            _buildOrderSummaryCard(stampDuty, totalPayable),
            const SizedBox(height: 32),
            _buildInvestButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Enter Investment Amount', style: TextStyle(color: kSub, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text('₹ ', style: TextStyle(color: kForest, fontSize: 32, fontWeight: FontWeight.bold)),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(color: kForest, fontSize: 32, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (val) {
                    setState(() {
                      _amount = double.tryParse(val) ?? 0;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(height: 2, color: kForest),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [5000, 10000, 25000, 50000].map((val) {
              bool isSelected = _amount == val;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _amount = val.toDouble();
                    _amountController.text = val.toStringAsFixed(0);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? kForest : kCream,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '₹${val ~/ 1000},000',
                    style: TextStyle(
                      color: isSelected ? Colors.white : kForest,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payment Method', style: TextStyle(color: kForest, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Column(
            children: List.generate(_paymentMethods.length, (index) {
              bool isSelected = _selectedPaymentIndex == index;
              var method = _paymentMethods[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedPaymentIndex = index),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFE8F5E9) : const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? Colors.green.shade600 : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(method['icon'], color: kForest, size: 20),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(method['title'], style: const TextStyle(color: kForest, fontWeight: FontWeight.bold, fontSize: 14)),
                              Text(method['subtitle'], style: const TextStyle(color: kSub, fontSize: 11)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          if (_selectedPaymentIndex == 0) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            const Text('Select Source Account', style: TextStyle(color: kForest, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 12),
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
                      border: Border.all(color: isAccSelected ? kForest : Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(isAccSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isAccSelected ? kForest : kSub, size: 18),
                        const SizedBox(width: 12),
                        Text(acc, style: TextStyle(color: kForest, fontWeight: isAccSelected ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard(double stampDuty, double totalPayable) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Order Summary', style: TextStyle(color: kForest, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildSummaryRow('Amount to Invest', '₹${_amount.toStringAsFixed(0)}'),
          const SizedBox(height: 12),
          _buildSummaryRow('Stamp Duty & Fees', '₹${stampDuty.toStringAsFixed(2)}'),
          const Divider(height: 32),
          _buildSummaryRow('Total Payable', '₹${totalPayable.toStringAsFixed(2)}', isBold: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: isBold ? kForest : kSub, fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(color: kForest, fontSize: isBold ? 16 : 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildInvestButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: () {
          if (_selectedPaymentIndex == 0 || _selectedPaymentIndex == 2) {
            // Bank Account or Net Banking
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BankTransferScreen(
                  toAccount: "987654321012",
                  toIfsc: "PSIB0001234",
                  toNominee: "PSB Mutual Fund Services",
                  toBank: "Punjab National Bank",
                  amount: _amount.toStringAsFixed(2),
                  purpose: "Investment",
                  fromAccount: _selectedPaymentIndex == 0 ? _selectedAccount : null,
                ),
              ),
            );
          } else if (_selectedPaymentIndex == 1) {
            // UPI
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UpiScreen(
                  prefilledUpiId: "psb.invest@upi",
                  prefilledAmount: _amount.toStringAsFixed(2),
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
        child: const Text('Invest Now', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
