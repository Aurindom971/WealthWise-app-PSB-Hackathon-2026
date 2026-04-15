import 'package:flutter/material.dart';
import 'package:securewealth_twin/features/home/widgets/home_navigation_widgets.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  int _currentStep = 1;
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final List<TextEditingController> _emailOtpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<TextEditingController> _phoneOtpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _showPassword = false;
  String? _errorMessage;

  void _nextStep() {
    setState(() {
      _errorMessage = null;
      if (_currentStep < 4) {
        _currentStep++;
      } else {
        _submitPasswordChange();
      }
    });
  }

  void _submitPasswordChange() {
    String newPass = _newPasswordController.text;
    String confirmPass = _confirmPasswordController.text;

    if (newPass != confirmPass) {
      setState(() {
        _errorMessage = 'Entered passwords do not match';
      });
      return;
    }

    bool hasCapital = newPass.contains(RegExp(r'[A-Z]'));
    bool hasDigit = newPass.contains(RegExp(r'[0-9]'));
    bool hasSymbol = newPass.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    bool hasLength = newPass.length > 8;

    if (!hasCapital || !hasDigit || !hasSymbol || !hasLength) {
      setState(() {
        _errorMessage =
            'Password must be >8 characters, with 1 capital, 1 symbol, and 1 digit';
      });
      return;
    }

    // Success
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password has been changed successfully'),
        backgroundColor: kForest,
      ),
    );
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) Navigator.pop(context);
    });
  }

  Widget _buildStepHeader() {
    String stepTitle = '';
    String stepDesc = '';
    IconData stepIcon = Icons.lock_outline_rounded;

    switch (_currentStep) {
      case 1:
        stepTitle = 'Step 1 of 4';
        stepDesc = 'Enter your current login password';
        break;
      case 2:
        stepTitle = 'Step 2 of 4';
        stepDesc = 'Enter OTP sent to j***@email.com';
        stepIcon = Icons.mail_outline_rounded;
        break;
      case 3:
        stepTitle = 'Step 3 of 4';
        stepDesc = 'Enter OTP sent to +91 ****7890';
        stepIcon = Icons.phone_android_rounded;
        break;
      case 4:
        stepTitle = 'Step 4 of 4';
        stepDesc = 'Set your new login password';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(stepIcon, color: kForest, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stepTitle,
                  style: const TextStyle(
                    color: kForest,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stepDesc,
                  style: const TextStyle(color: kSub, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpInput(List<TextEditingController> controllers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        return Container(
          width: 45,
          height: 55,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kSub.withOpacity(0.2)),
          ),
          child: TextField(
            controller: controllers[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < 5) {
                FocusScope.of(context).nextFocus();
              } else if (value.isEmpty && index > 0) {
                FocusScope.of(context).previousFocus();
              }
            },
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: kForest,
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: kForest),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Change Password',
          style: TextStyle(
            color: kForest,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: kForest),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.power_settings_new_rounded, color: kForest),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: kSub.withOpacity(0.1), height: 1),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_currentStep == 2 || _currentStep == 3)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kSub.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'OTP sent to your registered ${_currentStep == 2 ? 'email' : 'phone number'}',
                      style: const TextStyle(
                        color: kForest,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                _buildStepHeader(),
                const SizedBox(height: 32),
                if (_currentStep == 1) ...[
                  const Text(
                    'Current Password',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: kForest,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _currentPasswordController,
                    obscureText: !_showPassword,
                    decoration: InputDecoration(
                      hintText: 'Enter current password',
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: kSub,
                        ),
                        onPressed: () =>
                            setState(() => _showPassword = !_showPassword),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: kMid),
                      ),
                    ),
                  ),
                ] else if (_currentStep == 2) ...[
                  const Text(
                    'Email OTP',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: kForest,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildOtpInput(_emailOtpControllers),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Resend OTP',
                        style: TextStyle(
                          color: kMid,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ] else if (_currentStep == 3) ...[
                  const Text(
                    'Phone OTP',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: kForest,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildOtpInput(_phoneOtpControllers),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Resend OTP',
                        style: TextStyle(
                          color: kMid,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ] else if (_currentStep == 4) ...[
                  const Text(
                    'New Password',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: kForest,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _newPasswordController,
                    obscureText: !_showPassword,
                    decoration: InputDecoration(
                      hintText: 'Enter new password',
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: kSub,
                        ),
                        onPressed: () =>
                            setState(() => _showPassword = !_showPassword),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: kMid),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Confirm New Password',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: kForest,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: !_showPassword,
                    decoration: InputDecoration(
                      hintText: 'Re-enter new password',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: kMid),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: _nextStep,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: kMid,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        _currentStep == 1
                            ? 'Verify & Send OTP'
                            : _currentStep == 2 || _currentStep == 3
                            ? 'Verify and Next'
                            : 'Change Password',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_errorMessage != null)
            Positioned(
              top: 0,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _errorMessage = null),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
