import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../home/widgets/home_navigation_widgets.dart';
import '../../send/screens/send_transfer_screen.dart';

class SIPInvestmentScreen extends StatefulWidget {
  final String fundName;
  const SIPInvestmentScreen({super.key, required this.fundName});

  @override
  State<SIPInvestmentScreen> createState() => _SIPInvestmentScreenState();
}

class _SIPInvestmentScreenState extends State<SIPInvestmentScreen> {
  late String _selectedFund;
  double _amount = 1000;
  late TextEditingController _amountController;
  String _selectedFrequency = 'Quarterly';
  int _selectedDate = 20;
  bool _autoDebit = true;
  double _years = 2;
  int _selectedPaymentIndex = 0;
  String? _selectedAccount;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<Map<String, String>> _availableInvestments = [
    {'name': 'Nippon India Taiwan Equity Fund', 'type': 'Mutual Fund', 'category': 'International'},
    {'name': 'SBI PSU Fund', 'type': 'Mutual Fund', 'category': 'PSU'},
    {'name': 'Bandhan Small Cap Fund', 'type': 'Mutual Fund', 'category': 'Small Cap'},
    {'name': 'LIC MF Infrastructure Fund', 'type': 'Mutual Fund', 'category': 'Infrastructure'},
    {'name': 'ICICI Prudential Pharma Healthcare and Diagnostics (P.H.D) Fund', 'type': 'Mutual Fund', 'category': 'Sectoral'},
    {'name': 'Aditya Birla Sun Life PSU Equity Fund', 'type': 'Mutual Fund', 'category': 'PSU'},
    {'name': 'Invesco India PSU Equity Fund', 'type': 'Mutual Fund', 'category': 'PSU'},
    {'name': 'HSBC Midcap Fund', 'type': 'Mutual Fund', 'category': 'Mid Cap'},
    {'name': 'UTI Healthcare Fund', 'type': 'Mutual Fund', 'category': 'Sectoral'},
    {'name': 'DSP India T.I.G.E.R. (The Infrastructure Growth and Economic Reforms Fund)', 'type': 'Mutual Fund', 'category': 'Infrastructure'},
    {'name': 'Mirae Asset Healthcare Fund', 'type': 'Mutual Fund', 'category': 'Sectoral'},
    {'name': 'Nippon India Power & Infra Fund', 'type': 'Mutual Fund', 'category': 'Infrastructure'},
    {'name': 'Quant Value Fund', 'type': 'Mutual Fund', 'category': 'Value'},
    {'name': 'ITI Small Cap Fund', 'type': 'Mutual Fund', 'category': 'Small Cap'},
    {'name': 'WhiteOak Capital Mid Cap Fund', 'type': 'Mutual Fund', 'category': 'Mid Cap'},
    {'name': 'Canara Robeco Infrastructure Fund', 'type': 'Mutual Fund', 'category': 'Infrastructure'},
    {'name': 'Edelweiss Mid Cap Fund', 'type': 'Mutual Fund', 'category': 'Mid Cap'},
    {'name': 'Mahindra Manulife Mid Cap Fund', 'type': 'Mutual Fund', 'category': 'Mid Cap'},
    {'name': 'Franklin Build India Fund', 'type': 'Mutual Fund', 'category': 'Infrastructure'},
    {'name': 'HDFC Short Term Debt Fund', 'type': 'Mutual Fund', 'category': 'Debt'},
  ];

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
    _selectedFund = (widget.fundName == 'Multiple Funds' || widget.fundName.isEmpty) 
        ? _availableInvestments[0]['name']! 
        : widget.fundName;
    _amountController = TextEditingController(text: _amount.toStringAsFixed(0));

    if (widget.fundName == 'Multiple Funds' || widget.fundName.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showFundSelectionModal();
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  final List<String> _frequencies = ['Weekly', 'Monthly', 'Quarterly'];
  final List<int> _dates = [1, 5, 8, 10, 15, 20, 25];

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
                searchText: 'Search in Investments',
                onHomeTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
                onLogoutTap: () => Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false),
                onNotificationTap: () {},
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: const Icon(Icons.arrow_back, color: kForest, size: 20),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Start SIP',
                          style: TextStyle(color: kForest, fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildFundSelectionCard(),
                    const SizedBox(height: 20),
                    _buildAmountCard(),
                    const SizedBox(height: 20),
                    _buildFrequencyCard(),
                    const SizedBox(height: 20),
                    _buildDeductionDateCard(),
                    const SizedBox(height: 20),
                    _buildEMandateCard(),
                    const SizedBox(height: 20),
                    _buildPaymentMethodCard(),
                    const SizedBox(height: 20),
                    _buildCalculatorCard(),
                    const SizedBox(height: 32),
                    _buildSetupButton(),
                  ],
                ),
              ),
            ),
            BottomNav(
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
          ],
        ),
      ),
    );
  }

  Widget _buildFundSelectionCard() {
    var selectedItem = _availableInvestments.firstWhere((i) => i['name'] == _selectedFund, orElse: () => _availableInvestments[0]);
    return GestureDetector(
      onTap: _showFundSelectionModal,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kForest,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: kForest.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
              child: Icon(selectedItem['type'] == 'Mutual Fund' ? Icons.auto_graph_rounded : Icons.business_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_selectedFund, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFF2E7D5B).withValues(alpha: 0.3), borderRadius: BorderRadius.circular(6)),
                        child: Text(selectedItem['type']!.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      Text(selectedItem['category']!, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }

  void _showFundSelectionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          var filteredItems = _availableInvestments.where((item) {
            bool matchesSearch = item['name']!.toLowerCase().contains(_searchQuery.toLowerCase());
            bool matchesCategory = _selectedCategory == 'All' || item['type'] == _selectedCategory;
            return matchesSearch && matchesCategory;
          }).toList();

          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Color(0xFFF7F9F8),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Text('Invest in Funds or Stocks', style: TextStyle(color: kForest, fontSize: 22, fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextField(
                      onChanged: (val) {
                        setModalState(() => _searchQuery = val);
                        setState(() {});
                      },
                      decoration: const InputDecoration(
                        hintText: 'Search for mutual fund or stock company',
                        hintStyle: TextStyle(color: kSub, fontSize: 14),
                        icon: Icon(Icons.search, color: kForest),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: ['All', 'Mutual Fund', 'Stock'].map((cat) {
                      bool isSelected = _selectedCategory == cat;
                      return GestureDetector(
                        onTap: () {
                          setModalState(() => _selectedCategory = cat);
                          setState(() {});
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? kForest : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isSelected ? kForest : Colors.grey.shade200),
                          ),
                          child: Text(cat == 'Mutual Fund' ? 'Funds' : cat == 'Stock' ? 'Stocks' : 'All', 
                            style: TextStyle(color: isSelected ? Colors.white : kForest, fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: filteredItems.isEmpty 
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          const Text('No results found', style: TextStyle(color: kSub, fontSize: 16)),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          var item = filteredItems[index];
                          bool isSelected = _selectedFund == item['name'];
                          return GestureDetector(
                            onTap: () {
                              setState(() => _selectedFund = item['name']!);
                              Navigator.pop(context);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected ? kForest.withValues(alpha: 0.05) : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: isSelected ? kForest : Colors.transparent, width: 1.5),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isSelected ? kForest : kLightGreenBg,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(
                                      item['type'] == 'Mutual Fund' ? Icons.auto_graph_rounded : Icons.business_rounded, 
                                      color: isSelected ? Colors.white : kForest,
                                      size: 22
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item['name']!, style: TextStyle(color: kForest, fontWeight: isSelected ? FontWeight.bold : FontWeight.w700, fontSize: 15)),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(item['type']!, style: const TextStyle(color: kSub, fontSize: 11)),
                                            const SizedBox(width: 8),
                                            const Text('•', style: TextStyle(color: kSub, fontSize: 11)),
                                            const SizedBox(width: 8),
                                            Text(item['category']!, style: const TextStyle(color: kSub, fontSize: 11)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected) const Icon(Icons.check_circle_rounded, color: kForest, size: 28),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                ),
              ],
            ),
          );
        }
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
          const Text(
            'Monthly SIP Amount',
            style: TextStyle(
              color: kSub,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text(
                '₹ ',
                style: TextStyle(
                  color: kForest,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                    color: kForest,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
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
            children: [1000, 2500, 5000, 10000].map((val) {
              bool isSelected = _amount == val;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _amount = val.toDouble();
                    _amountController.text = val.toStringAsFixed(0);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? kForest : const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? kForest
                          : Colors.grey.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Text(
                    '₹${val ~/ 1000},${(val % 1000).toString().padLeft(3, '0').replaceAll('000', '00')}',
                    style: TextStyle(
                      color: isSelected ? Colors.white : kSub,
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

  Widget _buildFrequencyCard() {
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
          const Text(
            'Frequency',
            style: TextStyle(
              color: kForest,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: _frequencies.map((freq) {
              bool isSelected = _selectedFrequency == freq;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedFrequency = freq),
                  child: Container(
                    margin: EdgeInsets.only(
                      right: freq == 'Quarterly' ? 0 : 8,
                      left: freq == 'Weekly' ? 0 : 8,
                    ),
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected ? kForest : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? kForest
                            : Colors.grey.withValues(alpha: 0.2),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      freq,
                      style: TextStyle(
                        color: isSelected ? Colors.white : kForest,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
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

  Widget _buildDeductionDateCard() {
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
          const Row(
            children: [
              Icon(Icons.calendar_today_outlined, color: kForest, size: 18),
              SizedBox(width: 12),
              Text(
                'SIP Deduction Date',
                style: TextStyle(
                  color: kForest,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _dates.map((date) {
                bool isSelected = _selectedDate == date;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDate = date),
                  child: Container(
                    width: 44,
                    height: 44,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? kForest : const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      date.toString(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : kForest,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your SIP will be debited on the ${_selectedDate}th of every month',
            style: const TextStyle(color: kSub, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildEMandateCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'E-Mandate (Auto-Debit)',
                  style: TextStyle(
                    color: kForest,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Automatic deduction from bank account',
                  style: TextStyle(color: kSub, fontSize: 11),
                ),
              ],
            ),
          ),
          Switch(
            value: _autoDebit,
            onChanged: (val) => setState(() => _autoDebit = val),
            activeTrackColor: kForest.withValues(alpha: 0.5),
            activeThumbColor: kForest,
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

  Widget _buildCalculatorCard() {
    double totalInvested = _amount * 12 * _years;
    double futureValue = _calculateSIPWealth(_amount, _years, 0.12);

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
          const Text(
            'SIP Calculator',
            style: TextStyle(
              color: kForest,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Duration',
                style: TextStyle(color: kSub, fontSize: 13),
              ),
              Text(
                '${_years.toInt()} years',
                style: const TextStyle(
                  color: kForest,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: kForest,
              inactiveTrackColor: const Color(0xFFF7F7F7),
              thumbColor: kForest,
              overlayColor: kForest.withValues(alpha: 0.2),
              trackHeight: 2,
            ),
            child: Slider(
              value: _years,
              min: 1,
              max: 20,
              onChanged: (val) => setState(() => _years = val),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9).withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'If you invest ₹${_amount.toStringAsFixed(0)}/month for ${_years.toInt()} years',
                  style: const TextStyle(color: kSub, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total invested: ₹${totalInvested.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                  style: const TextStyle(
                    color: kForest,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text(
                      'You could have ',
                      style: TextStyle(
                        color: kForest,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '₹${futureValue.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                      style: const TextStyle(
                        color: Color(0xFF2E7D32),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '*Assuming 12% annual returns',
                  style: TextStyle(
                    color: kSub,
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _calculateSIPWealth(double monthly, double years, double rate) {
    double r = rate / 12;
    double n = years * 12;
    return monthly * ((math.pow(1 + r, n) - 1) / r) * (1 + r);
  }

  Widget _buildSetupButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: () {
          if (_selectedPaymentIndex == 0 || _selectedPaymentIndex == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BankTransferScreen(
                  toAccount: "987654321012",
                  toIfsc: "PSIB0001234",
                  toNominee: _selectedFund,
                  toBank: "Punjab National Bank",
                  amount: _amount.toStringAsFixed(2),
                  purpose: "Investment",
                  fromAccount: _selectedPaymentIndex == 0 ? _selectedAccount : null,
                ),
              ),
            );
          } else if (_selectedPaymentIndex == 1) {
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          'Setup $_selectedFrequency SIP',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
