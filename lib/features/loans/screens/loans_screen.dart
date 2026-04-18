import 'package:flutter/material.dart';
import 'dart:math';
import '../../home/screens/home_screen.dart';
import '../../home/widgets/home_navigation_widgets.dart';
import '../widgets/active_loan_card.dart';

class LoansScreen extends StatefulWidget {
  final VoidCallback onBack;
  final Function(LoanSubState, {String? loanType, String? loanId}) onNavigate;
  final String? highlightType;

  const LoansScreen({super.key, required this.onBack, required this.onNavigate, this.highlightType});

  @override
  State<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _loanKeys = {
    'Personal Loan': GlobalKey(),
    'Home Loan': GlobalKey(),
    'Education Loan': GlobalKey(),
    'Car Loan': GlobalKey(),
  };

  // EMI Calculator Controllers
  final _amtController = TextEditingController();
  final _tenureController = TextEditingController();
  final _rateController = TextEditingController();
  String _emiResult = '₹ 0 / mo';


  @override
  void initState() {
    super.initState();
    if (widget.highlightType != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final key = _loanKeys[widget.highlightType];
        if (key?.currentContext != null) {
          Scrollable.ensureVisible(
            key!.currentContext!,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  void _calculateEMI() {
    double p = double.tryParse(_amtController.text.replaceAll(',', '')) ?? 0;
    double r = (double.tryParse(_rateController.text) ?? 0) / 12 / 100;
    int n = int.tryParse(_tenureController.text) ?? 0;

    if (p > 0 && r > 0 && n > 0) {
      double emi = (p * r * pow(1 + r, n)) / (pow(1 + r, n) - 1);
      setState(() {
        _emiResult = '₹ ${emi.toStringAsFixed(0)} / mo';
      });
    } else {
      _showStyledSnackBar('Please enter valid numbers for all fields');
    }
  }

  void _showStyledSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: isError ? const Color(0xFFE74C3C) : kMid,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(18),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _amtController.dispose();
    _tenureController.dispose();
    _rateController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                    _EligibilityBanner(onNavigate: widget.onNavigate),
                    const SizedBox(height: 24),
                    _ActiveLoansSection(onNavigate: widget.onNavigate),
                    const SizedBox(height: 24),
                    _AvailableOptionsSection(
                      onNavigate: widget.onNavigate, 
                      highlightType: widget.highlightType,
                      itemKeys: _loanKeys,
                    ),
                    _CompareOptionsCard(onNavigate: widget.onNavigate),
                    
                    _PaymentPlanningSection(
                      amtController: _amtController,
                      tenureController: _tenureController,
                      rateController: _rateController,
                      emiResult: _emiResult,
                      onCalc: _calculateEMI,
                    ),
                    
                    const _TrackApplicationSection(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            _StickyApplyButton(onNavigate: widget.onNavigate),
          ],
        );
  }
}

class _EligibilityBanner extends StatelessWidget {
  final Function(LoanSubState, {String? loanType, String? loanId}) onNavigate;
  const _EligibilityBanner({required this.onNavigate});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: kMid.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: NetworkImage('https://www.transparenttextures.com/patterns/carbon-fibre.png'),
          opacity: 0.05,
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield_outlined, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Check Your Eligibility', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Get instant approval status in 30 seconds', style: TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => onNavigate(LoanSubState.eligibility),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: kMid,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Row(
              children: [
                Text('Check', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveLoansSection extends StatelessWidget {
  final Function(LoanSubState, {String? loanType, String? loanId}) onNavigate;
  const _ActiveLoansSection({required this.onNavigate});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('My Active Loans',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kInk)),
              TextButton(
                onPressed: () => onNavigate(LoanSubState.activeLoans),
                child: const Row(
                  children: [
                    Text('View All',
                        style: TextStyle(
                            color: kSub,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    Icon(Icons.arrow_forward, size: 14, color: kSub),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ActiveLoanCard(
            type: 'Personal Loan',
            loanId: 'PL-2024-00891',
            principal: '₹5,00,000',
            outstanding: '₹2,75,000',
            emi: '₹15,000',
            nextDue: '5 Apr 2026',
            paidText: '9 of 20 EMIs paid',
            progress: 0.45,
            onViewStatement: () => onNavigate(
              LoanSubState.statement,
              loanType: 'Personal Loan',
              loanId: 'PL-2024-00891',
            ),
          ),
          const SizedBox(height: 16),
          ActiveLoanCard(
            type: 'Car Loan',
            loanId: 'CL-2023-01234',
            principal: '₹8,00,000',
            outstanding: '₹5,60,000',
            emi: '₹18,500',
            nextDue: '10 Apr 2026',
            paidText: '18 of 60 EMIs paid',
            progress: 0.30,
            onViewStatement: () => onNavigate(
              LoanSubState.statement,
              loanType: 'Car Loan',
              loanId: 'CL-2023-01234',
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _AvailableOptionsSection extends StatelessWidget {
  final Function(LoanSubState, {String? loanType, String? loanId}) onNavigate;
  final String? highlightType;
  final Map<String, GlobalKey> itemKeys;
  const _AvailableOptionsSection({
    required this.onNavigate, 
    this.highlightType,
    required this.itemKeys,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Available Loan Options', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kInk)),
          const SizedBox(height: 16),
          _LoanOptionCard(
            key: itemKeys['Personal Loan'],
            title: 'Personal Loan',
            desc: 'Quick funds for your personal needs',
            emiStart: '₹8,850/month',
            amount: '₹5 Lakh',
            interest: '10.5% p.a.',
            tag: 'Best Offer',
            tagColor: Colors.orange,
            icon: Icons.person_outline,
            onNavigate: onNavigate,
            isHighlighted: highlightType == 'Personal Loan',
          ),
          const SizedBox(height: 16),
          _LoanOptionCard(
            key: itemKeys['Home Loan'],
            title: 'Home Loan',
            desc: 'Fulfill your dream of owning a home',
            emiStart: '₹7,689/month',
            amount: '₹50 Lakh',
            interest: '8.5% p.a.',
            tag: 'Popular',
            tagColor: Colors.orangeAccent,
            icon: Icons.home_outlined,
            onNavigate: onNavigate,
            isHighlighted: highlightType == 'Home Loan',
          ),
          const SizedBox(height: 16),
          _LoanOptionCard(
            key: itemKeys['Education Loan'],
            title: 'Education Loan',
            desc: 'Invest in your future education',
            emiStart: '₹12,668/month',
            amount: '₹10 Lakh',
            interest: '9.0% p.a.',
            icon: Icons.school_outlined,
            onNavigate: onNavigate,
            isHighlighted: highlightType == 'Education Loan',
          ),
          const SizedBox(height: 16),
          _LoanOptionCard(
            key: itemKeys['Car Loan'],
            title: 'Car Loan',
            desc: 'Drive home your dream car today',
            emiStart: '₹10,455/month',
            amount: '₹8 Lakh',
            interest: '9.5% p.a.',
            tag: 'Low Rate',
            tagColor: Colors.redAccent,
            icon: Icons.directions_car_outlined,
            onNavigate: onNavigate,
            isHighlighted: highlightType == 'Car Loan',
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _LoanOptionCard extends StatelessWidget {
  final String title;
  final String desc;
  final String emiStart;
  final String amount;
  final String interest;
  final String? tag;
  final Color? tagColor;
  final IconData icon;
  final Function(LoanSubState, {String? loanType, String? loanId}) onNavigate;
  final bool isHighlighted;

  const _LoanOptionCard({
    super.key,
    required this.title, 
    required this.desc, 
    required this.emiStart, 
    required this.amount, 
    required this.interest, 
    this.tag, 
    this.tagColor, 
    required this.icon,
    required this.onNavigate,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(24),
        border: isHighlighted
            ? Border.all(color: const Color(0xFF2E9461), width: 2)
            : null,
        boxShadow: [
          if (isHighlighted)
            BoxShadow(
              color: const Color(0xFF2E9461).withOpacity(0.15),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFEAF6F0), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: const Color(0xFF1F7A5A), size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: kInk, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(desc, style: const TextStyle(color: kSub, fontSize: 13)),
                  ],
                ),
              ),
              if (tag != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: tagColor, borderRadius: BorderRadius.circular(12)),
                  child: Text(tag!, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _AmountBox(label: 'EMI starting from', value: emiStart)),
              const SizedBox(width: 12),
              Expanded(child: _AmountBox(label: 'Loan amount', value: amount)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Interest rate', style: TextStyle(color: kSub, fontSize: 11, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(interest, style: const TextStyle(color: kInk, fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
              ElevatedButton(
                onPressed: () => onNavigate(
                  LoanSubState.apply,
                  loanType: title,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kMid,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: const Text('Apply Now', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AmountBox extends StatelessWidget {
  final String label;
  final String value;
  const _AmountBox({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFEAF6F0).withValues(alpha: 0.4), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: kSub, fontSize: 10, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: kInk, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ─── COMPARE OPTIONS CARD ─────────────────────────────────────────────────────
class _CompareOptionsCard extends StatelessWidget {
  final Function(LoanSubState, {String? loanType, String? loanId}) onNavigate;
  const _CompareOptionsCard({required this.onNavigate});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFEAF6F0), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.compare_arrows_rounded, color: Color(0xFF1F7A5A), size: 24),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Compare Loan Options', style: TextStyle(color: kInk, fontSize: 15, fontWeight: FontWeight.bold)),
                Text('Find the best rates and terms for you', style: TextStyle(color: kSub, fontSize: 12)),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () => onNavigate(LoanSubState.compare),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: kInk.withValues(alpha: 0.2)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            child: const Text('Compare', style: TextStyle(color: kInk, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ─── PAYMENT PLANNING SECTION ─────────────────────────────────────────────────
class _PaymentPlanningSection extends StatelessWidget {
  final TextEditingController amtController;
  final TextEditingController tenureController;
  final TextEditingController rateController;
  final String emiResult;
  final VoidCallback onCalc;

  const _PaymentPlanningSection({
    required this.amtController,
    required this.tenureController,
    required this.rateController,
    required this.emiResult,
    required this.onCalc,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Plan Your Payments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kInk)),
          const SizedBox(height: 16),
          _EMICalculatorCard(
            amtController: amtController,
            tenureController: tenureController,
            rateController: rateController,
            emiResult: emiResult,
            onCalc: onCalc,
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _EMICalculatorCard extends StatelessWidget {
  final TextEditingController amtController;
  final TextEditingController tenureController;
  final TextEditingController rateController;
  final String emiResult;
  final VoidCallback onCalc;

  const _EMICalculatorCard({
    required this.amtController,
    required this.tenureController,
    required this.rateController,
    required this.emiResult,
    required this.onCalc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFEAF6F0), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.calculate_outlined, color: Color(0xFF1F7A5A), size: 24),
              ),
              const SizedBox(width: 14),
              const Text('EMI Calculator', style: TextStyle(color: kInk, fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(emiResult, style: const TextStyle(color: Color(0xFF1F7A5A), fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          _SmallInput(label: 'Loan Amount (₹)', controller: amtController, hint: 'e.g. 500000'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _SmallInput(label: 'Tenure (months)', controller: tenureController, hint: 'e.g. 24')),
              const SizedBox(width: 12),
              Expanded(child: _SmallInput(label: 'Interest (%)', controller: rateController, hint: 'e.g. 10.5')),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onCalc,
              style: ElevatedButton.styleFrom(
                backgroundColor: kMid,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Calculate EMI', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  const _SmallInput({required this.label, required this.controller, required this.hint});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: kSub, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Container(
          height: 48,
          decoration: BoxDecoration(color: const Color(0xFFF2F0EB), borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kInk),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: TextStyle(color: kSub.withValues(alpha: 0.5), fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── TRACK APPLICATION SECTION ───────────────────────────────────────────────
class _TrackApplicationSection extends StatefulWidget {
  const _TrackApplicationSection();

  @override
  State<_TrackApplicationSection> createState() => _TrackApplicationSectionState();
}

class _TrackApplicationSectionState extends State<_TrackApplicationSection> {
  bool _isExpanded = false;
  int? _selectedAppIndex;

  final List<Map<String, String>> _applications = [
    {'id': 'PL-2024-00891', 'type': 'Personal Loan', 'amount': '₹5,00,000'},
    {'id': 'HL-2024-01254', 'type': 'Home Loan', 'amount': '₹45,00,000'},
    {'id': 'CL-2024-00732', 'type': 'Car Loan', 'amount': '₹12,50,000'},
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kMid.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // Header Row (Matches Secure Wealth AI)
          InkWell(
            onTap: () => setState(() {
              _isExpanded = !_isExpanded;
              if (!_isExpanded) _selectedAppIndex = null;
            }),
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [kMid, kAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: kAccent.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3))
                      ],
                    ),
                    child: const Icon(Icons.radar_outlined, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('LOAN STATUS',
                            style: TextStyle(
                                color: kAccent,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2)),
                        const SizedBox(height: 2),
                        const Text('Track Your Application',
                            style: TextStyle(
                                color: kForest,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3)),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 300),
                    turns: _isExpanded ? 0.25 : 0,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: kForest.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: kForest),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Dropdown Details
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: List.generate(_applications.length, (index) {
                  final app = _applications[index];
                  final isSelected = _selectedAppIndex == index;
                  
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: InkWell(
                          onTap: () => setState(() {
                            _selectedAppIndex = isSelected ? null : index;
                          }),
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected ? kMid.withValues(alpha: 0.05) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? kMid.withValues(alpha: 0.2) : Colors.transparent,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: kMid.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    index == 0 ? Icons.person : (index == 1 ? Icons.home : Icons.directions_car),
                                    size: 16,
                                    color: kMid,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        app['id']!,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: kInk),
                                      ),
                                      Text(
                                        '${app['type']} • ${app['amount']}',
                                        style: const TextStyle(color: kSub, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  isSelected ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                  color: kSub,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (isSelected)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
                          child: const _CompactStatusTracker(),
                        ),
                      if (index < _applications.length - 1)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Divider(color: kSub.withValues(alpha: 0.1), height: 1),
                        ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CompactStatusTracker extends StatelessWidget {
  const _CompactStatusTracker();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Loan Status Tracker',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kInk),
        ),
        const SizedBox(height: 20),
        const _StatusStep(
          icon: Icons.description_outlined,
          title: 'Application',
          status: 'Completed',
          statusColor: Colors.green,
          isActive: true,
          showLine: true,
          isCompleted: true,
        ),
        const _StatusStep(
          icon: Icons.fact_check_outlined,
          title: 'Verification',
          status: 'Completed',
          statusColor: Colors.green,
          isActive: true,
          showLine: true,
          isCompleted: true,
        ),
        _StatusStep(
          icon: Icons.visibility_outlined,
          title: 'Approval',
          status: 'In Progress',
          statusColor: Colors.blue.shade700,
          isActive: true,
          showLine: true,
          isCompleted: false,
        ),
        const _StatusStep(
          icon: Icons.monetization_on_outlined,
          title: 'Disbursement',
          status: 'Pending',
          statusColor: kSub,
          isActive: false,
          showLine: false,
          isCompleted: false,
        ),
      ],
    );
  }
}

class _StatusStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String status;
  final Color statusColor;
  final bool isActive;
  final bool showLine;
  final bool isCompleted;

  const _StatusStep({
    required this.icon,
    required this.title,
    required this.status,
    required this.statusColor,
    required this.isActive,
    required this.showLine,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isCompleted ? const Color(0xFF2E5B4B) : (isActive ? const Color(0xFF2E5B4B).withValues(alpha: 0.8) : const Color(0xFFF0F4F2)),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: isCompleted || isActive ? Colors.white : kSub, size: 22),
              ),
              if (showLine)
                Expanded(
                  child: Container(
                    width: 2,
                    color: const Color(0xFFE0E0E0),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kInk),
                ),
                Text(
                  status,
                  style: TextStyle(fontSize: 13, color: statusColor, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// ─── STICKY APPLY BUTTON ─────────────────────────────────────────────────────
class _StickyApplyButton extends StatelessWidget {
  final Function(LoanSubState, {String? loanType, String? loanId}) onNavigate;
  const _StickyApplyButton({required this.onNavigate});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: kCream,
        border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () => onNavigate(LoanSubState.apply),
          style: ElevatedButton.styleFrom(
            backgroundColor: kMid,
            foregroundColor: Colors.white,
            elevation: 4,
            shadowColor: kMid.withValues(alpha: 0.4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Apply for Loan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
        ),
      ),
    );
  }
}
