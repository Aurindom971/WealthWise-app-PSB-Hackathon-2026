import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class OTPConfirmationScreen extends StatefulWidget {
  final String title;
  final VoidCallback onVerified;

  const OTPConfirmationScreen({
    super.key,
    this.title = 'Confirm Changes',
    required this.onVerified,
  });

  @override
  State<OTPConfirmationScreen> createState() => _OTPConfirmationScreenState();
}

class _OTPConfirmationScreenState extends State<OTPConfirmationScreen> {
  final List<String> _otp = ['', '', '', ''];
  int _secondsRemaining = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onKeyTap(String key) {
    setState(() {
      for (int i = 0; i < _otp.length; i++) {
        if (_otp[i] == '') {
          _otp[i] = key;
          break;
        }
      }
    });

    if (!_otp.contains('')) {
      _verifyOTP();
    }
  }

  void _onBackspace() {
    setState(() {
      for (int i = _otp.length - 1; i >= 0; i--) {
        if (_otp[i] != '') {
          _otp[i] = '';
          break;
        }
      }
    });
  }

  Future<void> _verifyOTP() async {
    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF2ECC71), size: 64),
              const SizedBox(height: 20),
              Text(
                'Success!',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Changes verified successfully',
                style: GoogleFonts.inter(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pop(context); // Close dialog
      Navigator.pop(context); // Go back from OTP screen
      widget.onVerified();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.title,
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Please enter the 4-digit code sent to\n+91 •••• ••• 482',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(4, (index) => _buildOTPBox(index)),
                  ),
                  const SizedBox(height: 48),
                  Text(
                    _secondsRemaining > 0 
                        ? 'Resend in ${_secondsRemaining}s' 
                        : 'Resend Code',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: _secondsRemaining > 0 ? Colors.grey : const Color(0xFF2ECC71),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildNumericKeypad(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildOTPBox(int index) {
    bool hasValue = _otp[index] != '';
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasValue ? const Color(0xFF2ECC71) : Colors.transparent,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          _otp[index],
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1A1A),
          ),
        ),
      ),
    );
  }

  Widget _buildNumericKeypad() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['1', '2', '3'].map((k) => _buildKey(k)).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['4', '5', '6'].map((k) => _buildKey(k)).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['7', '8', '9'].map((k) => _buildKey(k)).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 80),
              _buildKey('0'),
              _buildKey('backspace', isIcon: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String label, {bool isIcon = false}) {
    return GestureDetector(
      onTap: () => isIcon ? _onBackspace() : _onKeyTap(label),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80,
        height: 60,
        child: Center(
          child: isIcon 
              ? const Icon(Icons.backspace_outlined, color: Color(0xFF1A1A1A))
              : Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
        ),
      ),
    );
  }
}
