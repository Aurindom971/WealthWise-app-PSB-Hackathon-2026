import 'package:flutter/material.dart';
import 'package:wealthwise/features/home/widgets/home_navigation_widgets.dart';
import '../../loans/widgets/loan_header.dart';
import '../../home/screens/notifications_screen.dart';

class ModifyAccountDetailsPage extends StatefulWidget {
  const ModifyAccountDetailsPage({super.key});

  @override
  State<ModifyAccountDetailsPage> createState() => _ModifyAccountDetailsPageState();
}

class _ModifyAccountDetailsPageState extends State<ModifyAccountDetailsPage> {
  final _nameController = TextEditingController(text: 'Rajesh Kumar');
  final _addressController = TextEditingController(text: '42, MG Road, New Delhi, 110001');
  final _phoneController = TextEditingController(text: '+91 98765 43210');
  final _emailController = TextEditingController(text: 'rajeshkumar@gmail.com');

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _showPolicyPopup() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kMid.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.security_rounded, color: kMid, size: 40),
              ),
              const SizedBox(height: 20),
              const Text(
                'Sensitive Information',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kInk),
              ),
              const SizedBox(height: 12),
              const Text(
                'This is sensitive information. To update it, you will need to follow the steps sent to your email for extra verification.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: kSub, height: 1.5),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kMid,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('I Understand', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEmailSentPopup(String title) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFEAF6F0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mark_email_read_outlined, color: kMid, size: 40),
              ),
              const SizedBox(height: 20),
              Text(
                '$title Request',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kInk),
              ),
              const SizedBox(height: 12),
              const Text(
                'Email Sent! Please check your inbox for the verification link to proceed with this update.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: kSub, height: 1.5),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kMid,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
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
                onHomeTap: () => Navigator.popUntil(context, (route) => route.isFirst),
                onLogoutTap: () => Navigator.popUntil(context, (route) => route.isFirst),
                onNotificationTap: () => showNotifications(context),
              ),
            ),
            LoanHeader(
              title: "",
              subtitle: "Modify Account Details",
              icon: Icons.sync_rounded,
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                children: [
                  const Text(
                    'Basic Information',
                    style: TextStyle(color: kForest, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField('Full Name', _nameController, Icons.person_outline),
                  _buildTextField('Address', _addressController, Icons.location_on_outlined, maxLines: 2),
                  _buildTextField('Phone Number', _phoneController, Icons.phone_android_outlined),
                  _buildTextField('Email Address', _emailController, Icons.alternate_email_outlined),
                  
                  const SizedBox(height: 32),
                  
                  // Verification Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: kMid, width: 1.5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Verification Required',
                              style: TextStyle(color: kMid, fontSize: 13, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: _showPolicyPopup,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: kMid,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.question_mark_rounded, color: Colors.white, size: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildSensitiveTile('Update KYC', Icons.assignment_turned_in_outlined),
                        _buildSensitiveTile('Update PAN Details', Icons.badge_outlined, isLast: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Basic details updated successfully'),
                            backgroundColor: kMid,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.all(18),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kForest,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        elevation: 0,
                      ),
                      child: const Text('SAVE BASIC CHANGES', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
            BottomNav(
              currentIndex: -1,
              onTap: (i) => Navigator.popUntil(context, (route) => route.isFirst),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: kSub, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(color: kForest, fontWeight: FontWeight.w600),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ).toInputDecoration().copyWith(
              prefixIcon: Icon(icon, color: kMid, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensitiveTile(String title, IconData icon, {bool isLast = false}) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _showEmailSentPopup(title),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kMid.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: kMid, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(color: kForest, fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: kSub, size: 16),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(color: kMid.withValues(alpha: 0.1), height: 20, thickness: 1),
      ],
    );
  }
}

extension on BoxDecoration {
  InputDecoration toInputDecoration() => const InputDecoration();
}
