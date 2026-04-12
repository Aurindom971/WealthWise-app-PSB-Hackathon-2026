import 'package:flutter/material.dart';
import '../../home/widgets/home_navigation_widgets.dart';
import '../widgets/loan_header.dart';
import '../../home/screens/home_screen.dart';

class LoanEligibilityScreen extends StatefulWidget {
  final VoidCallback onBack;
  const LoanEligibilityScreen({super.key, required this.onBack});

  @override
  State<LoanEligibilityScreen> createState() => _LoanEligibilityScreenState();
}

class _LoanEligibilityScreenState extends State<LoanEligibilityScreen> {
  int _currentStep = 1;
  final ScrollController _scrollController = ScrollController();

  // Controllers for Step 1
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String? _employmentType;

  // Controllers for Step 2
  final _incomeController = TextEditingController();
  final _scoreController = TextEditingController();
  final _emiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Add listeners to rebuild UI when text changes
    _nameController.addListener(_updateState);
    _ageController.addListener(_updateState);
    _incomeController.addListener(_updateState);
    _scoreController.addListener(_updateState);
    _emiController.addListener(_updateState);
  }

  void _updateState() {
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _incomeController.dispose();
    _scoreController.dispose();
    _emiController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  bool get _isStep1Valid =>
      _nameController.text.isNotEmpty &&
      _ageController.text.isNotEmpty &&
      _employmentType != null;

  bool get _isStep2Valid =>
      _incomeController.text.isNotEmpty &&
      _scoreController.text.isNotEmpty &&
      _emiController.text.isNotEmpty;

  void _nextStep() {
    if (_currentStep == 1 && !_isStep1Valid) return;
    if (_currentStep == 2 && !_isStep2Valid) return;
    setState(() {
      if (_currentStep < 3) _currentStep++;
    });
    _scrollToTop();
  }

  void _prevStep() {
    setState(() {
      if (_currentStep > 1) _currentStep--;
    });
    _scrollToTop();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LoanHeader(
          title: 'Eligibility Check',
          subtitle: 'Instant approval check',
          icon: Icons.shield_outlined,
          onBack: widget.onBack,
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                _buildStepIndicator(),
                const SizedBox(height: 24),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStepItem(1, 'Personal', _currentStep >= 1),
          _buildStepLine(_currentStep > 1),
          _buildStepItem(2, 'Financial', _currentStep >= 2),
          _buildStepLine(_currentStep > 2),
          _buildStepItem(3, 'Result', _currentStep >= 3),
        ],
      ),
    );
  }

  Widget _buildStepItem(int step, String label, bool active) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? kMid : const Color(0xFFF2F0EB),
            shape: BoxShape.circle,
          ),
          child: Text(
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
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool active) {
    return Container(
      width: 30,
      height: 2,
      color: active ? kMid : const Color(0xFFDEDBD2),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildPersonalDetails();
      case 2:
        return _buildFinancialDetails();
      case 3:
        return _buildResult();
      default:
        return _buildPersonalDetails();
    }
  }

  Widget _buildPersonalDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
              Icon(Icons.person_outline, color: kMid, size: 22),
              SizedBox(width: 10),
              Text(
                'Personal Details',
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
          _buildLabel('Age'),
          _buildTextField(_ageController, 'Enter your age', keyboardType: TextInputType.number),
          const SizedBox(height: 20),
          _buildLabel('Employment Type'),
          _buildDropdown(),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextStep,
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
      ),
    );
  }

  Widget _buildFinancialDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
              Icon(Icons.business_center_outlined, color: kMid, size: 22),
              SizedBox(width: 10),
              Text(
                'Financial Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kInk,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildLabel('Monthly Income (₹)'),
          _buildTextField(_incomeController, 'e.g. 50000', keyboardType: TextInputType.number),
          const SizedBox(height: 20),
          _buildLabel('Credit Score'),
          _buildTextField(_scoreController, 'e.g. 750', keyboardType: TextInputType.number),
          const SizedBox(height: 20),
          _buildLabel('Existing Monthly EMIs (₹)'),
          _buildTextField(_emiController, 'e.g. 5000', keyboardType: TextInputType.number),
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
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isStep2Valid ? kMid : const Color(0xFFA5B9B0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Check Now', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    // For now, showing the "Not Eligible" result as per reference image
    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.red.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, color: Colors.red, size: 40),
          ),
          const SizedBox(height: 20),
          const Text(
            'Not Eligible',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You don\'t meet the minimum criteria at this time',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: kSub,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF6F0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tips to improve eligibility:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: kInk,
                  ),
                ),
                const SizedBox(height: 12),
                _buildTip('Maintain a credit score above 650'),
                _buildTip('Reduce existing EMI obligations'),
                _buildTip('Ensure monthly income exceeds ₹20,000'),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _currentStep = 1;
                });
                _scrollToTop();
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFDEDBD2)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text(
                'Check Again',
                style: TextStyle(color: kInk, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: kSub, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: kSub, height: 1.4),
            ),
          ),
        ],
      ),
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

  Widget _buildDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F0EB),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _employmentType,
          hint: const Text('Select', style: TextStyle(color: kInk, fontSize: 14)),
          isExpanded: true,
          items: ['Salaried', 'Self-Employed', 'Business Owner']
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (val) {
            setState(() {
              _employmentType = val;
            });
          },
        ),
      ),
    );
  }
}
