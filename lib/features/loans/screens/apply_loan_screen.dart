import 'package:flutter/material.dart';
import 'dart:math';
import '../../home/widgets/home_navigation_widgets.dart';
import '../../home/screens/home_screen.dart';
import '../widgets/loan_header.dart';

class ApplyLoanScreen extends StatefulWidget {
  final String? initialLoanType;
  final VoidCallback onBack;
  final VoidCallback onSuccess;
  const ApplyLoanScreen({super.key, this.initialLoanType, required this.onBack, required this.onSuccess});

  @override
  State<ApplyLoanScreen> createState() => _ApplyLoanScreenState();
}

class _ApplyLoanScreenState extends State<ApplyLoanScreen> {
  int _currentStep = 1;
  final ScrollController _scrollController = ScrollController();

  // Step 1: Loan Type
  String? _selectedLoanType;

  // Step 2: Loan Details
  final _amountController = TextEditingController();
  final _purposeController = TextEditingController();
  String? _selectedTenure;
  String _emiResult = '₹ 0';

  // Step 3: Personal Information
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _panController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedLoanType = widget.initialLoanType;
    // Listeners for dynamic button styling and EMI calculation
    _amountController.addListener(_updateState);
    _purposeController.addListener(_updateState);
    _nameController.addListener(_updateState);
    _phoneController.addListener(_updateState);
    _emailController.addListener(_updateState);
    _panController.addListener(_updateState);
  }

  void _updateState() {
    _calculateEMI();
    setState(() {});
  }

  void _calculateEMI() {
    double p = double.tryParse(_amountController.text) ?? 0;
    int n = _selectedTenure != null ? int.tryParse(_selectedTenure!.split(' ')[0]) ?? 0 : 0;
    double r = 10.5 / 12 / 100; // 10.5% p.a.

    if (p > 0 && n > 0) {
      double emi = (p * r * pow(1 + r, n)) / (pow(1 + r, n) - 1);
      setState(() {
        _emiResult = '₹ ${emi.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
      });
    } else {
      setState(() {
        _emiResult = '₹ 0';
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _purposeController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _panController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool get _isStep1Valid => _selectedLoanType != null;
  
  bool get _isStep2Valid =>
      _amountController.text.isNotEmpty &&
      _purposeController.text.isNotEmpty &&
      _selectedTenure != null;

  bool get _isStep3Valid =>
      _nameController.text.isNotEmpty &&
      _phoneController.text.isNotEmpty &&
      _emailController.text.isNotEmpty &&
      _panController.text.isNotEmpty;

  void _nextStep() {
    if (_currentStep == 1 && !_isStep1Valid) return;
    if (_currentStep == 2 && !_isStep2Valid) return;
    if (_currentStep == 3 && !_isStep3Valid) return;

    setState(() {
      if (_currentStep < 4) _currentStep++;
    });
    _scrollToTop();
  }

  void _prevStep() {
    setState(() {
      if (_currentStep > 1) _currentStep--;
    });
    _scrollToTop();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LoanHeader(
          title: 'Loan Application',
          subtitle: 'Apply for a new loan',
          icon: Icons.assignment_outlined,
          onBack: widget.onBack,
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                const Text(
                  'Apply for Loan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Quick and easy application',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
                if (_currentStep < 4) ...[
                  _buildStepIndicator(),
                  const SizedBox(height: 24),
                ],
                _buildStepContent(),
              ],
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStepItem(1, 'Loan Type', _currentStep >= 1, _currentStep > 1),
          _buildStepLine(_currentStep > 1),
          _buildStepItem(2, 'Details', _currentStep >= 2, _currentStep > 2),
          _buildStepLine(_currentStep > 2),
          _buildStepItem(3, 'Personal', _currentStep >= 3, _currentStep > 3),
        ],
      ),
    );
  }

  Widget _buildStepItem(int step, String label, bool active, bool completed) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: completed ? const Color(0xFF3BB77E) : (active ? kMid : const Color(0xFFF2F0EB)),
            shape: BoxShape.circle,
          ),
          child: completed
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : Text(
                  step.toString(),
                  style: TextStyle(
                    color: active ? Colors.white : kSub,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: active ? kInk : kSub,
            fontWeight: active ? FontWeight.bold : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool active) {
    return Container(
      width: 24,
      height: 2,
      color: active ? const Color(0xFF3BB77E) : const Color(0xFFDEDBD2),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildLoanTypeSelection();
      case 2:
        return _buildLoanDetails();
      case 3:
        return _buildPersonalDetails();
      case 4:
        return _buildSuccessPage();
      default:
        return _buildLoanTypeSelection();
    }
  }

  Widget _buildLoanTypeSelection() {
    return Column(
      children: [
        _buildChoiceCard('Personal Loan', Icons.person_outline, 'Quick funds for personal needs'),
        _buildChoiceCard('Home Loan', Icons.home_outlined, 'Finance your dream home'),
        _buildChoiceCard('Education Loan', Icons.school_outlined, 'Invest in your education'),
        _buildChoiceCard('Car Loan', Icons.directions_car_outlined, 'Drive your dream car today'),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isStep1Valid ? _nextStep : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isStep1Valid ? kMid : const Color(0xFFA5B9B0),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ],
    );
  }

  Widget _buildChoiceCard(String title, IconData icon, String subtitle) {
    final isSelected = _selectedLoanType == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedLoanType = title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? kMid : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? kMid.withValues(alpha: 0.1) : const Color(0xFFF2F0EB),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isSelected ? kMid : kSub, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kInk)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: kSub)),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: kMid, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.currency_rupee, color: kMid, size: 22),
              SizedBox(width: 10),
              Text(
                'Loan Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kInk,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildLabel('Loan Amount (₹)'),
          _buildTextField(_amountController, 'e.g. 500000', keyboardType: TextInputType.number),
          const SizedBox(height: 20),
          _buildLabel('Tenure (months)'),
          _buildTenureDropdown(),
          const SizedBox(height: 20),
          _buildLabel('Purpose'),
          _buildTextField(_purposeController, 'e.g. Home renovation'),
          const SizedBox(height: 24),
          if (_amountController.text.isNotEmpty && _selectedTenure != null)
            _buildEMIBox(),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _prevStep,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFDEDBD2)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Back', style: TextStyle(color: kInk, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isStep2Valid ? _nextStep : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isStep2Valid ? kMid : const Color(0xFFA5B9B0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEMIBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF6F0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Estimated Monthly EMI',
            style: TextStyle(color: kSub, fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            _emiResult,
            style: const TextStyle(color: kMid, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '${_selectedLoanType ?? 'Loan'} • ${_selectedTenure ?? ''}',
            style: const TextStyle(color: kSub, fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.assignment_ind_outlined, color: kMid, size: 22),
              SizedBox(width: 10),
              Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kInk,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildLabel('Full Name'),
          _buildTextField(_nameController, 'Enter your full name'),
          const SizedBox(height: 20),
          _buildLabel('Phone Number'),
          _buildTextField(_phoneController, '+91 XXXXX XXXXX', keyboardType: TextInputType.phone),
          const SizedBox(height: 20),
          _buildLabel('Email Address'),
          _buildTextField(_emailController, 'you@email.com', keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 20),
          _buildLabel('PAN Number'),
          _buildTextField(_panController, 'ABCDE1234F'),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _prevStep,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFDEDBD2)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Back', style: TextStyle(color: kInk, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isStep3Valid ? _nextStep : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isStep3Valid ? kMid : const Color(0xFFA5B9B0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Submit Application', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessPage() {
    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEAF5F0), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF3BB77E),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 20),
          const Text(
            'Application Submitted!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: kInk,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your ${_selectedLoanType ?? 'Personal Loan'} application has been received',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: kSub,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF5F0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _buildSummaryRow('Application ID', 'LA-048046', isBold: true),
                const Divider(height: 24, color: Colors.white24),
                _buildSummaryRow('Loan Type', _selectedLoanType ?? 'Personal Loan'),
                const SizedBox(height: 12),
                _buildSummaryRow('Amount', '₹ ${_amountController.text}'),
                const SizedBox(height: 12),
                _buildSummaryRow('Tenure', _selectedTenure ?? ''),
                const SizedBox(height: 12),
                _buildSummaryRow('Est. EMI', _emiResult, valueColor: const Color(0xFF2D5A47)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'We\'ll review your application and contact you within 24 hours.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: kSub),
          ),
          const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.onBack,
            style: ElevatedButton.styleFrom(
              backgroundColor: kMid,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Back to Home', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: kSub, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? kInk,
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: kSub,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {TextInputType? keyboardType}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F0EB),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(color: kSub, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildTenureDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F0EB),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedTenure,
          hint: const Text('Select Tenure', style: TextStyle(color: kSub, fontSize: 14)),
          isExpanded: true,
          items: ['12 months', '24 months', '36 months', '48 months', '60 months']
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (val) {
            setState(() {
              _selectedTenure = val;
            });
            _calculateEMI();
          },
        ),
      ),
    );
  }
}
