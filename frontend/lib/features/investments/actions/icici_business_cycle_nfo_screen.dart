import 'package:flutter/material.dart';
import '../../home/widgets/home_navigation_widgets.dart';
import '../../send/screens/send_transfer_screen.dart';

class ICICIBusinessCycleNFOScreen extends StatefulWidget {
  const ICICIBusinessCycleNFOScreen({super.key});

  @override
  State<ICICIBusinessCycleNFOScreen> createState() =>
      _ICICIBusinessCycleNFOScreenState();
}

class _ICICIBusinessCycleNFOScreenState
    extends State<ICICIBusinessCycleNFOScreen>
    with SingleTickerProviderStateMixin {
  final double _minInvestment = 1000;
  bool _converttoSIP = false;
  late DateTime _expiryDate;
  late Duration _remainingTime;
  late AnimationController _rotationController;

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
    _expiryDate = DateTime(2026, 4, 24, 23, 59, 59); // April 24, midnight
    _calculateRemainingTime();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _calculateRemainingTime() {
    _remainingTime = _expiryDate.difference(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: TopBar(
                searchText: 'Search Business Cycle Funds',
                onHomeTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
                onLogoutTap: () => Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false),
                onNotificationTap: () {},
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Color(0xFFF7F9F8), shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back, color: kForest, size: 18),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Cyclical NFO',
                    style: TextStyle(color: kForest, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCycleClock(),
                    const SizedBox(height: 32),
                    _buildTitle(),
                    const SizedBox(height: 24),
                    _buildSummaryGrid(),
                    const SizedBox(height: 32),
                    _buildToggleSection(),
                    const SizedBox(height: 32),
                    _buildFooterLinks(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            _buildBottomCTA(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: 4,
        onTap: (index) {
          if (index == 4) return;
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/home',
            (route) => false,
            arguments: {'index': index},
          );
        },
        onLogoutTap: () => Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false),
        onNotificationTap: () {},
      ),
    );
  }

  Widget _buildCycleClock() {
    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              RotationTransition(
                turns: _rotationController,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: kCream, width: 8),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 60,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Column(
                children: [
                  Text(
                    'EXPANSION',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text('Phase 2', style: TextStyle(color: kSub, fontSize: 10)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Currently identified as "High Growth Transition"',
            style: TextStyle(color: kSub, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ICICI Pru Business Cycle Fund',
          style: TextStyle(
            color: kForest,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'CLOSING IN ${_remainingTime.inDays} DAYS',
            style: const TextStyle(
              color: Colors.orange,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.5,
      children: [
        _buildGridItem('Launch Price', '₹ 10.00'),
        _buildGridItem('Min. Invest', '₹ 1,000'),
        _buildGridItem('Exit Load', '1.0% (<1Y)'),
        _buildGridItem('Category', 'Thematic'),
      ],
    );
  }

  Widget _buildGridItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: kSub,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: kForest,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildToggleSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCream,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Auto-convert to SIP',
                  style: TextStyle(
                    color: kForest,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Make this a Monthly SIP after NFO ends.',
                  style: TextStyle(color: kSub, fontSize: 11),
                ),
              ],
            ),
          ),
          Switch(
            value: _converttoSIP,
            onChanged: (val) => setState(() => _converttoSIP = val),
            activeThumbColor: kForest,
            activeTrackColor: kForest.withValues(alpha: 0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLinks() {
    return Center(
      child: TextButton.icon(
        onPressed: () {},
        icon: const Icon(
          Icons.file_download_outlined,
          color: Colors.blue,
          size: 18,
        ),
        label: const Text(
          'Download Scheme Document (SID)',
          style: TextStyle(
            color: Colors.blue,
            fontSize: 12,
            fontWeight: FontWeight.w500,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'NFO Entry Price',
                style: TextStyle(color: kSub, fontSize: 12),
              ),
              Text(
                '₹ ${_minInvestment.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: kForest,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
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
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kForest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Apply for NFO',
                style: TextStyle(
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
