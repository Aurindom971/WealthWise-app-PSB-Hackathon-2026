import 'package:flutter/material.dart';
import '../../features/home/widgets/home_navigation_widgets.dart';
import '../../features/send/screens/send_transfer_screen.dart';

class SBIInnovationNFOScreen extends StatefulWidget {
  const SBIInnovationNFOScreen({super.key});

  @override
  State<SBIInnovationNFOScreen> createState() => _SBIInnovationNFOScreenState();
}

class _SBIInnovationNFOScreenState extends State<SBIInnovationNFOScreen> {
  final double _minInvestment = 5000;
  bool _understandsRisk = false;
  late DateTime _expiryDate;
  late Duration _remainingTime;

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
  void initState() {
    super.initState();
    _expiryDate = DateTime(2026, 4, 22, 11, 0, 0); // April 22, 11 AM
    _calculateRemainingTime();
  }

  void _calculateRemainingTime() {
    _remainingTime = _expiryDate.difference(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: kForest, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Thematic NFO',
          style: TextStyle(
            color: kForest,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroSection(),
                  const SizedBox(height: 32),
                  _buildPriceAnchor(),
                  const SizedBox(height: 32),
                  _buildInvestmentLogic(),
                  const SizedBox(height: 32),
                  _buildPortfolioPreview(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          _buildBottomCTA(),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.psychology_outlined,
            color: Colors.blue,
            size: 40,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'SBI Innovation Opportunities Fund',
          style: TextStyle(
            color: kForest,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.timer_outlined, color: Colors.orange, size: 16),
            const SizedBox(width: 8),
            Text(
              'CLOSES IN ${_remainingTime.inDays} DAYS (${_remainingTime.inHours % 24}H LEFT)',
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceAnchor() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kForest, kForest.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FACE VALUE OFFER',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '₹ 10.00',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Per Unit Launch Price',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.keyboard_double_arrow_up,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestmentLogic() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Why Invest?',
          style: TextStyle(
            color: kForest,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        _buildLogicPoint(
          Icons.biotech_outlined,
          'Exposure to R&D Leaders',
          'Targeting companies spending >5% of revenue on innovation.',
        ),
        _buildLogicPoint(
          Icons.rocket_launch_outlined,
          'Focus on Disruptors',
          'Portfolio of "Future 50" stocks in EV, AI, and Fintech.',
        ),
        _buildLogicPoint(
          Icons.category_outlined,
          'IT & Pharma Hedge',
          'Pure-play tech growth with a defensive Pharma overlay.',
        ),
      ],
    );
  }

  Widget _buildLogicPoint(IconData icon, String title, String sub) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: kCream,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: kForest, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: kForest,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  sub,
                  style: const TextStyle(
                    color: kSub,
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

  Widget _buildPortfolioPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Target Holdings Preview',
          style: TextStyle(
            color: kForest,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildHoldingChip('NVIDIA (Potential)'),
              _buildHoldingChip('ZOMATO'),
              _buildHoldingChip('TCS'),
              _buildHoldingChip('DR REDDYS'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHoldingChip(String name) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          name,
          style: const TextStyle(
            color: kForest,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomCTA() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Checkbox(
                value: _understandsRisk,
                onChanged: (val) => setState(() => _understandsRisk = val!),
                activeColor: kForest,
              ),
              Expanded(
                child: Text(
                  'I understand this is a Very High-Risk thematic fund.',
                  style: TextStyle(color: kSub, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _paymentMethods.asMap().entries.map((entry) {
              int idx = entry.key;
              var method = entry.value;
              bool isSelected = _selectedPaymentIndex == idx;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedPaymentIndex = idx),
                  child: Container(
                    margin: EdgeInsets.only(right: idx == 2 ? 0 : 8),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? kForest.withValues(alpha: 0.05) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? kForest : Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        Icon(method['icon'], color: isSelected ? kForest : kSub, size: 20),
                        const SizedBox(height: 4),
                        Text(method['title'], style: TextStyle(color: isSelected ? kForest : kSub, fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (_selectedPaymentIndex == 0) ...[
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: userAccounts.where((a) => a.contains('Savings')).map((acc) {
                  bool isAccSelected = _selectedAccount == acc;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedAccount = acc),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isAccSelected ? kForest.withValues(alpha: 0.05) : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isAccSelected ? kForest : Colors.grey.shade100),
                        ),
                        child: Row(
                          children: [
                            Icon(isAccSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isAccSelected ? kForest : kSub, size: 14),
                            const SizedBox(width: 8),
                            Text(acc, style: TextStyle(color: kForest, fontSize: 11, fontWeight: isAccSelected ? FontWeight.bold : FontWeight.normal)),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _understandsRisk
                  ? () {
                      if (_selectedPaymentIndex == 0 || _selectedPaymentIndex == 2) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BankTransferScreen(
                              toAccount: "987654321012",
                              toIfsc: "PSIB0001234",
                              toNominee: "PSB Investment Portal",
                              toBank: "Punjab National Bank",
                              amount: _minInvestment.toStringAsFixed(2),
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
                              prefilledAmount: _minInvestment.toStringAsFixed(2),
                            ),
                          ),
                        );
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: kForest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                'Invest ₹${_minInvestment.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
