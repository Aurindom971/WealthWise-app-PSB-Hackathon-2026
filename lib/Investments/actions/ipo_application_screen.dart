import 'package:flutter/material.dart';
import '../../features/send/screens/send_transfer_screen.dart';

class IPOApplicationScreen extends StatefulWidget {
  final String companyName;
  final String dates;
  final String priceRange;

  const IPOApplicationScreen({
    super.key,
    required this.companyName,
    required this.dates,
    required this.priceRange,
  });

  @override
  State<IPOApplicationScreen> createState() => _IPOApplicationScreenState();
}

class _IPOApplicationScreenState extends State<IPOApplicationScreen> {
  final Color kForest = const Color(0xFF1B422B);
  final Color kCream = const Color(0xFFFBFBF9);
  final Color kSub = const Color(0xFF9A9A94);

  final TextEditingController _quantityController = TextEditingController(
    text: '180',
  );
  final TextEditingController _priceController = TextEditingController(
    text: '80',
  );

  String _selectedCategory = 'Individual Retail';
  bool _useCutOffPrice = true;

  int _selectedPaymentIndex = 0;
  String? _selectedAccount;

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
  void initState() {
    super.initState();
    _quantityController.addListener(_onInputChanged);
    _priceController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _quantityController.removeListener(_onInputChanged);
    _priceController.removeListener(_onInputChanged);
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Apply for ${widget.companyName}',
          style: TextStyle(
            color: kForest,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: kForest),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Row(
        children: [
          // Left Panel: Information Summary
          Expanded(
            flex: 2,
            child: Container(
              color: kCream,
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [_buildSummaryCard()],
              ),
            ),
          ),

          // Right Panel: Bidding Form
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bidding Form',
                    style: TextStyle(
                      color: kForest,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildDropdown('Select Category', [
                    'Individual Retail',
                    'HNI',
                    'Employee',
                  ]),
                  const SizedBox(height: 24),
                  _buildBidInput(),
                  const SizedBox(height: 32),
                  _buildPaymentMethodCard(),
                  const SizedBox(height: 32),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: kCream,
                radius: 24,
                child: Icon(Icons.business, color: kForest),
              ),
              const SizedBox(width: 16),
              Text(
                widget.companyName,
                style: TextStyle(
                  color: kForest,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoRow('Dates Open', widget.dates),
          _buildInfoRow('Price Range', widget.priceRange),
          _buildInfoRow('Lot Size Details', '180 Shares (₹14,400)'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: kSub, fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: kForest,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: kSub, fontSize: 13)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              items: options
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCategory = v!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBidInput() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quantity (Shares)',
                      style: TextStyle(color: kSub, fontSize: 12),
                    ),
                    TextField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price (₹)',
                      style: TextStyle(color: kSub, fontSize: 12),
                    ),
                    TextField(
                      controller: _priceController,
                      enabled: !_useCutOffPrice,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'At Cut-off Price',
                style: TextStyle(color: kForest, fontWeight: FontWeight.w500),
              ),
              Switch(
                value: _useCutOffPrice,
                activeThumbColor: kForest,
                activeTrackColor: kForest.withValues(alpha: 0.5),
                onChanged: (v) => setState(() {
                  _useCutOffPrice = v;
                  if (v) {
                    _priceController.text = widget.priceRange
                        .split('-')
                        .last
                        .replaceAll('₹', '')
                        .trim();
                  }
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    double qty = double.tryParse(_quantityController.text) ?? 0;
    double price = double.tryParse(_priceController.text) ?? 0;
    double total = qty * price;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Amount Payable',
              style: TextStyle(color: kSub, fontSize: 14),
            ),
            Text(
              '₹${total.toStringAsFixed(0)}',
              style: TextStyle(
                color: kForest,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              if (_selectedPaymentIndex == 0 || _selectedPaymentIndex == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BankTransferScreen(
                      toAccount: "987654321012",
                      toIfsc: "PSIB0001234",
                      toNominee: "PSB Investment Portal",
                      toBank: "Punjab National Bank",
                      amount: total.toStringAsFixed(2),
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
                      prefilledAmount: total.toStringAsFixed(2),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kForest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Submit Application',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: TextStyle(
            color: kForest,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: List.generate(_paymentMethods.length, (index) {
            bool isSelected = _selectedPaymentIndex == index;
            var method = _paymentMethods[index];
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedPaymentIndex = index),
                child: Container(
                  margin: EdgeInsets.only(right: index == 2 ? 0 : 12),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? kForest.withValues(alpha: 0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? kForest : Colors.grey.shade200,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        method['icon'],
                        color: isSelected ? kForest : kSub,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        method['title'],
                        style: TextStyle(
                          color: isSelected ? kForest : kSub,
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
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
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isAccSelected ? kForest : Colors.grey.shade100,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isAccSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: isAccSelected ? kForest : kSub,
                        size: 16,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        acc,
                        style: TextStyle(
                          color: kForest,
                          fontSize: 12,
                          fontWeight:
                              isAccSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
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
}
