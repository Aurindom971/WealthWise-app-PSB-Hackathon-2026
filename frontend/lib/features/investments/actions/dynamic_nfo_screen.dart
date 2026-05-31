import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../home/widgets/home_navigation_widgets.dart';
import '../../send/screens/send_transfer_screen.dart';

class DynamicNFOScreen extends StatefulWidget {
  final String name;
  final String date;
  final double minInvestment;
  final int closesInDays;
  final String description;

  const DynamicNFOScreen({
    super.key,
    required this.name,
    required this.date,
    required this.minInvestment,
    required this.closesInDays,
    required this.description,
  });

  @override
  State<DynamicNFOScreen> createState() => _DynamicNFOScreenState();
}

class _DynamicNFOScreenState extends State<DynamicNFOScreen> {
  final Color kForest = const Color(0xFF1F5D3A);
  final Color kSub = const Color(0xFF757575);
  final Color kCream = const Color(0xFFF2F0EB);
  final Color kLightGreenBg = const Color(0xFFEAF1ED);

  int _selectedPaymentIndex = 0;
  String? _selectedAccount;

  final List<Map<String, dynamic>> _paymentMethods = [
    {'title': 'Bank Account', 'icon': Icons.account_balance_outlined},
    {'title': 'UPI', 'icon': Icons.phone_android_outlined},
    {'title': 'Net Banking', 'icon': Icons.language_outlined},
  ];

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
                searchText: 'Search in NFOs',
                onHomeTap: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                onLogoutTap: () => Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (route) => false),
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
                      decoration: const BoxDecoration(
                        color: Color(0xFFF7F9F8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_back, color: kForest, size: 18),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'NFO Application',
                    style: TextStyle(
                      color: kForest,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
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
                    _buildHeader(),
                    const SizedBox(height: 32),
                    _buildKeyStats(),
                    const SizedBox(height: 32),
                    _buildSectoralBreakup(),
                    const SizedBox(height: 32),
                    _buildTaxCalculator(),
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

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.name,
                style: TextStyle(
                  color: kForest,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'LIVE NOW',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(widget.description, style: TextStyle(color: kSub, fontSize: 14)),
      ],
    );
  }

  Widget _buildKeyStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatItem('NAV PRICE', '₹ 10.00', 'Launch Value', Colors.green),
        _buildStatItem(
          'CLOSES IN',
          '${widget.closesInDays} Days',
          widget.date,
          Colors.orange,
        ),
        _buildStatItem(
          'MIN. INVEST',
          '₹ ${widget.minInvestment.toInt()}',
          'Entry Barrier',
          kForest,
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, String sub, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: kSub,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(sub, style: TextStyle(color: kSub, fontSize: 10)),
      ],
    );
  }

  Widget _buildSectoralBreakup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sectoral Distribution',
          style: TextStyle(
            color: kForest,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 35,
                  sections: [
                    PieChartSectionData(
                      color: kForest,
                      value: 40,
                      title: '',
                      radius: 15,
                    ),
                    PieChartSectionData(
                      color: kForest.withValues(alpha: 0.6),
                      value: 25,
                      title: '',
                      radius: 15,
                    ),
                    PieChartSectionData(
                      color: kForest.withValues(alpha: 0.3),
                      value: 20,
                      title: '',
                      radius: 15,
                    ),
                    PieChartSectionData(
                      color: kCream,
                      value: 15,
                      title: '',
                      radius: 15,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                children: [
                  _buildLegendItem('Sector Heavyweights', '40%'),
                  _buildLegendItem('Mid Cap Boosters', '25%'),
                  _buildLegendItem('Tech & Services', '20%'),
                  _buildLegendItem('Liquidity/Cash', '15%'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, String p) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: kSub, fontSize: 12)),
          Text(
            p,
            style: TextStyle(
              color: kForest,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxCalculator() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCream,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calculate_outlined, color: kForest, size: 20),
              const SizedBox(width: 12),
              Text(
                'Tax Efficiency Calculator',
                style: TextStyle(
                  color: kForest,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCalcRow('Long Term Capital Gains (>1Y)', '10% Tax'),
          _buildCalcRow('Indexation Benefit', 'Available'),
          const Divider(height: 24),
          Text(
            'Dynamic thematic funds offer index-like tracking efficiency with enhanced tactical flexibility.',
            style: TextStyle(color: kSub, fontSize: 11, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildCalcRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: kSub, fontSize: 12)),
          Text(
            val,
            style: TextStyle(
              color: kForest,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
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
              Text(
                'Application Amount',
                style: TextStyle(color: kSub, fontSize: 12),
              ),
              Text(
                '₹ ${widget.minInvestment.toStringAsFixed(0)}',
                style: TextStyle(
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
                      color: isSelected
                          ? kForest.withValues(alpha: 0.05)
                          : Colors.white,
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
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          method['title'],
                          style: TextStyle(
                            color: isSelected ? kForest : kSub,
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
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
                children: userAccounts.where((a) => a.contains('Savings')).map((
                  acc,
                ) {
                  bool isAccSelected = _selectedAccount == acc;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedAccount = acc),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isAccSelected
                              ? kForest.withValues(alpha: 0.05)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isAccSelected
                                ? kForest
                                : Colors.grey.shade100,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isAccSelected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: isAccSelected ? kForest : kSub,
                              size: 14,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              acc,
                              style: TextStyle(
                                color: kForest,
                                fontSize: 11,
                                fontWeight: isAccSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
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
                        toNominee: widget.name,
                        toBank: "Punjab National Bank",
                        amount: widget.minInvestment.toStringAsFixed(2),
                        purpose: "NFO Subscription",
                        fromAccount: _selectedPaymentIndex == 0
                            ? _selectedAccount
                            : null,
                      ),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UpiScreen(
                        prefilledUpiId: "psb.invest@upi",
                        prefilledAmount: widget.minInvestment.toStringAsFixed(
                          2,
                        ),
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
                'Confirm Application',
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
