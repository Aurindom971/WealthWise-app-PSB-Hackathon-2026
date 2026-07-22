import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wealthwise/features/home/widgets/home_navigation_widgets.dart';
import '../../loans/widgets/loan_header.dart';
import '../../home/screens/notifications_screen.dart';
import '../../../../core/services/otp_security_service.dart';

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
  bool _isVerifying = false;
  String? _errorMessage;

  Future<void> _nextStep() async {
    setState(() => _errorMessage = null);

    if (_currentStep == 1) {
      // Verify current password against Supabase
      await _verifyCurrentPassword();
    } else if (_currentStep < 4) {
      setState(() => _currentStep++);
    } else {
      await _submitPasswordChange();
    }
  }

  Future<void> _verifyCurrentPassword() async {
    final password = _currentPasswordController.text.trim();
    if (password.isEmpty) {
      setState(() => _errorMessage = 'Please enter your current password');
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final supabase = Supabase.instance.client;
      final email = supabase.auth.currentUser?.email;

      if (email == null) {
        setState(() {
          _isVerifying = false;
          _errorMessage = 'Could not retrieve user email. Please log in again.';
        });
        return;
      }

      // Attempt to sign in with the entered password to verify it
      await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // Password is correct — move to next step
      if (mounted) {
        setState(() {
          _isVerifying = false;
          _currentStep = 2;
        });
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _isVerifying = false;
          _errorMessage = e.message.contains('Invalid')
              ? 'Incorrect password. Please try again.'
              : e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVerifying = false;
          _errorMessage = 'Something went wrong. Please try again.';
        });
      }
    }
  }

  Future<void> _submitPasswordChange() async {
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

    setState(() => _isVerifying = true);

    try {
      final supabase = Supabase.instance.client;
      await supabase.auth.updateUser(
        UserAttributes(password: newPass),
      );
      await OtpSecurityService.instance.recordPasswordChanged();

      if (mounted) {
        setState(() => _isVerifying = false);
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
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _isVerifying = false;
          _errorMessage = e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVerifying = false;
          _errorMessage = 'Failed to update password. Please try again.';
        });
      }
    }
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kAccent.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mark_email_read_outlined,
                    color: kForest, size: 36),
              ),
              const SizedBox(height: 20),
              const Text(
                'Reset Instructions Sent',
                style: TextStyle(
                  color: kForest,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Password reset instructions have been sent to your registered email address and mobile number via SMS.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: kSub,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: kMid,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'OK, Got it',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: TopBar(
                onHomeTap: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                onLogoutTap: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                onNotificationTap: () => showNotifications(context),
              ),
            ),
            LoanHeader(
              title: "",
              subtitle: "Change Password",
              icon: Icons.lock_person_outlined,
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: Stack(
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
                                onPressed: () => setState(
                                    () => _showPassword = !_showPassword),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: kMid),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: _showForgotPasswordDialog,
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: kMid,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
                                  decorationColor: kMid,
                                ),
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
                                onPressed: () => setState(
                                    () => _showPassword = !_showPassword),
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
                          onTap: _isVerifying ? null : _nextStep,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: _isVerifying ? kMid.withOpacity(0.5) : kMid,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: _isVerifying
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Text(
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
            ),
            BottomNav(
              currentIndex: -1,
              onTap: (i) =>
                  Navigator.popUntil(context, (route) => route.isFirst),
            ),
          ],
        ),
      ),
    );
  }
}
