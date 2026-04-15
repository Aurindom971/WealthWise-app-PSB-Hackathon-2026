import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../../features/home/widgets/home_navigation_widgets.dart';

enum InvestmentMode { lumpsum, sip }

class InvestmentDetailsScreen extends StatefulWidget {
  final InvestmentMode mode;
  final String? initialAmount;

  const InvestmentDetailsScreen({
    super.key,
    required this.mode,
    this.initialAmount,
  });

  @override
  State<StatefulWidget> createState() => _InvestmentDetailsScreenState();
}

class _InvestmentDetailsScreenState extends State<InvestmentDetailsScreen> {
  late final TextEditingController _amountController;
  String _selectedFrequency = 'Monthly';
  int _selectedDate = 15;
  bool _eMandateEnabled = true;
  String _selectedPayment = 'UPI';

  final List<String> _frequencies = ['Weekly', 'Monthly', 'Quarterly'];
  final List<int> _dates = [1, 5, 8, 10, 15, 20, 25];
  final List<String> _quickAmounts = ['1,000', '2,500', '5,000', '10,000'];
  final List<String> _lumpsumQuickAmounts = [
    '5,000',
    '10,000',
    '25,000',
    '50,000',
  ];

  double _years = 5.0;
  final double _expectedReturn = 12.0;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text:
          widget.initialAmount ??
          (widget.mode == InvestmentMode.sip ? '5,000' : '10,000'),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _updateAmount(String amt) {
    setState(() {
      _amountController.text = amt;
    });
  }

  double _getAmount() {
    return double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0.0;
  }

  double _calculateProjectedValue() {
    double monthlyInvest = _getAmount();
    double rate = _expectedReturn / 100 / 12;
    double months = _years * 12;

    if (rate == 0) return monthlyInvest * months;

    // Future Value of an Annuity formula: FV = P * [((1 + r)^n - 1) / r] * (1 + r)
    double fv =
        monthlyInvest * ((math.pow(1 + rate, months) - 1) / rate) * (1 + rate);
    return fv;
  }

  @override
  Widget build(BuildContext context) {
    final isSIP = widget.mode == InvestmentMode.sip;
    final title = isSIP ? "Start SIP" : "Invest Lumpsum";

    return Scaffold(
      backgroundColor: kCream,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(title),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (isSIP) _buildSIPContent() else _buildLumpSumContent(),
                    const SizedBox(height: 32),
                    _buildCTA(isSIP),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: kForest, size: 20),
            ),
          ),
          const SizedBox(width: 20),
          Text(
            title,
            style: const TextStyle(
              color: kForest,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSIPContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Amount Card
        _buildSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Monthly SIP Amount',
                style: TextStyle(
                  color: kSub,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
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
                      onChanged: (val) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(height: 1.5, color: kForest.withValues(alpha: 0.1)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _quickAmounts
                    .map((amt) => _buildQuickChip(amt))
                    .toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Frequency
        _buildSectionTitle('Frequency'),
        _buildSectionCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _frequencies
                .map(
                  (f) => _buildSelectionChip(f, _selectedFrequency == f, () {
                    setState(() => _selectedFrequency = f);
                  }),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 20),

        // Deduction Date
        _buildSectionTitle(
          'SIP Deduction Date',
          icon: Icons.calendar_today_outlined,
        ),
        _buildSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _dates
                      .map(
                        (d) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildSelectionChipCircle(
                            d.toString(),
                            _selectedDate == d,
                            () {
                              setState(() => _selectedDate = d);
                            },
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your SIP will be debited on the ${_selectedDate}th of every month',
                style: TextStyle(color: kSub, fontSize: 11),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // E-Mandate
        _buildSectionCard(
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
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Automatic deduction from bank account',
                      style: TextStyle(color: kSub, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _eMandateEnabled,
                onChanged: (val) => setState(() => _eMandateEnabled = val),
                activeTrackColor: kForest,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Calculator
        _buildSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'SIP Calculator',
                    style: TextStyle(
                      color: kForest,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: kForest.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_years.toInt()} Years',
                      style: const TextStyle(
                        color: kForest,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: kForest,
                  inactiveTrackColor: kForest.withValues(alpha: 0.1),
                  thumbColor: kForest,
                  overlayColor: kForest.withValues(alpha: 0.2),
                  trackHeight: 4,
                ),
                child: Slider(
                  value: _years,
                  min: 1,
                  max: 30,
                  onChanged: (val) => setState(() => _years = val),
                ),
              ),
              const SizedBox(height: 16),
              _buildCalcRow(
                'Monthly Investment',
                '₹ ${NumberFormat('#,##,###').format(_getAmount())}',
              ),
              const SizedBox(height: 8),
              _buildCalcRow('Duration', '${_years.toInt()} years'),
              const SizedBox(height: 8),
              _buildCalcRow(
                'Expected Return',
                '${_expectedReturn.toInt()}% p.a.',
              ),
              const Divider(height: 24),
              _buildCalcRow(
                'Estimated Total Value',
                '₹ ${NumberFormat('#,##,###').format(_calculateProjectedValue().toInt())}',
                isBold: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLumpSumContent() {
    final amount = _getAmount();
    final fees = 15.00;
    final total = amount + fees;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Large Input
        _buildSectionCard(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
          child: Column(
            children: [
              Text(
                'Enter Amount',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: kSub,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: kForest,
                ),
                decoration: const InputDecoration(
                  prefixText: "₹ ",
                  prefixStyle: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: kForest,
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (val) => setState(() {}),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 8,
                alignment: WrapAlignment.center,
                children: _lumpsumQuickAmounts
                    .map((amt) => _buildQuickChip(amt, isLumpsum: true))
                    .toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Summary Card
        _buildSectionTitle('Payment Summary'),
        _buildSectionCard(
          child: Column(
            children: [
              _summaryRow(
                "Amount to Invest",
                "₹ ${NumberFormat('#,##,###').format(amount)}",
              ),
              const SizedBox(height: 8),
              _summaryRow("Stamp Duty/Fees", "₹ ${fees.toStringAsFixed(2)}"),
              const Divider(height: 24),
              _summaryRow(
                "Total Payable",
                "₹ ${NumberFormat('#,##,###').format(total)}",
                isBold: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Payment Method
        _buildSectionTitle('Select Payment Method'),
        _buildSectionCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _buildPaymentTile('UPI', Icons.phone_android),
              const Divider(height: 1),
              _buildPaymentTile('Net Banking', Icons.account_balance),
              const Divider(height: 1),
              _buildPaymentTile('Linked Bank Account', Icons.credit_card),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: kForest),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: const TextStyle(
              color: kForest,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildQuickChip(String label, {bool isLumpsum = false}) {
    return GestureDetector(
      onTap: () => _updateAmount(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isLumpsum ? kForest.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: Text(
          isLumpsum ? '₹ $label' : '₹$label',
          style: TextStyle(
            color: kForest,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? kForest : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? kForest : Colors.grey.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : kForest,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionChipCircle(
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? kForest : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? kForest : Colors.grey.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : kForest,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCalcRow(String title, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: kSub, fontSize: 12)),
        Text(
          value,
          style: TextStyle(
            color: kForest,
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String title, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isBold ? kForest : kSub,
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: kForest,
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentTile(String title, IconData icon) {
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: Colors.transparent,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: kForest.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: kForest, size: 20),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                color: kForest,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _selectedPayment == title ? kForest : Colors.grey.shade400,
                  width: _selectedPayment == title ? 6 : 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCTA(bool isSIP) {
    return ElevatedButton(
      onPressed: () {
        // Implement payment logic here
        _showSuccessDialog(isSIP);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: kForest,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        shadowColor: kForest.withValues(alpha: 0.3),
      ),
      child: Text(
        isSIP ? "Start SIP" : "Invest Now",
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showSuccessDialog(bool isSIP) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Investment Initiated',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isSIP
                  ? 'Your monthly SIP has been set up successfully.'
                  : 'Your lumpsum investment is being processed.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kForest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Back to Dashboard',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
