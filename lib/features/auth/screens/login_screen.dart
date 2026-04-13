import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isPassword = true;
  bool isLoading = false;

  final TextEditingController _cusIdController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  final _supabase = Supabase.instance.client;

  @override
  void dispose() {
    _cusIdController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    final cusId = _cusIdController.text.trim();
    final enteredSecret = _pinController.text.trim();

    if (cusId.isEmpty || enteredSecret.isEmpty) {
      _showError("REQUIRED: Please enter both Customer ID and ${isPassword ? 'Password' : 'PIN'} to proceed.");
      return;
    }

    setState(() => isLoading = true);

    try {
      final res = await _supabase.rpc(
        'get_login_data',
        params: {'input_cus_id': cusId},
      );

      if (res == null) {
        _showError("IDENTITY: Customer ID not found in our records. Please verify and try again.");
        return;
      }
      
      final List<dynamic> resultList = res as List<dynamic>;

      if (resultList.isEmpty) {
        _showError("IDENTITY: Customer ID not found in our records. Please verify and try again.");
        return;
      }

      final Map<String, dynamic> userData = resultList.first;

      final email = userData['email']?.toString() ?? '';
      final authPassword = userData['auth_password']?.toString() ?? '';
      final storedPin = userData['pin_hash']?.toString() ?? '';

      if (email.isEmpty) {
         _showError("MAINTENANCE: Email not found for this Customer ID.");
         return;
      }

      if (isPassword && authPassword.isEmpty) {
         _showError("SECURITY: This account does not have a password set. Please use PIN.");
         return;
      }

      if (!isPassword && storedPin.isEmpty) {
         _showError("SECURITY: This account does not have a PIN set. Please use Password.");
         return;
      }

      if (!isPassword) {
        if (storedPin.isEmpty || storedPin == 'null') {
          _showError("SECURITY: No PIN set for this account. Please use Password login.");
          return;
        }
        
        if (enteredSecret != storedPin) {
          _showError("SECURITY: The PIN entered is incorrect.");
          return;
        }
      } else {
        if (enteredSecret != authPassword) {
          _showError("SECURITY: The password entered is incorrect.");
          return;
        }
      }

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: authPassword,
      );

      if (response.user == null) {
        _showError("AUTHENTICATION: Secure login could not be established.");
        return;
      }

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on PostgrestException catch (e) {
      _showError("CONNECTION: ${e.message}");
    } on AuthException catch (e) {
      _showError("SECURITY: ${e.message}");
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        _showError("NETWORK: No internet connection detected.");
      } else {
        _showError("MAINTENANCE: $e");
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    
    IconData icon = Icons.info_outline;
    Color color = Colors.orange.shade800;
    
    if (message.startsWith("SECURITY:")) {
      icon = Icons.security_rounded;
      color = Colors.red.shade800;
    } else if (message.startsWith("NETWORK:") || message.startsWith("CONNECTION:")) {
      icon = Icons.wifi_off_rounded;
      color = Colors.blue.shade900;
    } else if (message.startsWith("REQUIRED:")) {
      icon = Icons.warning_amber_rounded;
      color = Colors.orange.shade900;
    } else if (message.startsWith("IDENTITY:")) {
      icon = Icons.person_search_rounded;
      color = Colors.indigo.shade800;
    }

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 🔥 HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1F5D3A), Color(0xFF2E7D5B)],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(26),
                    bottomRight: Radius.circular(26),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Row(
                      children: [
                        Icon(Icons.account_balance,
                            color: Colors.white70, size: 14),
                        SizedBox(width: 6),
                        Text("Punjab & Sind Bank",
                            style: TextStyle(
                                color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text("Welcome Back",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w600)),
                    SizedBox(height: 2),
                    Text("Sign in to your account securely",
                        style: TextStyle(
                            color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // 🔥 MAIN CONTENT
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("CUSTOMER ID",
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black54, letterSpacing: 0.5)),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: _cusIdController,
                      hintText: "Enter Customer ID (e.g. CUST1)",
                      prefixIcon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 20),
                    const Text("SELECT AUTH METHOD",
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black54, letterSpacing: 0.5)),
                    const SizedBox(height: 10),
                    // 🔥 TOGGLE BUTTONS
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => isPassword = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isPassword ? const Color(0xFF1F5D3A) : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isPassword ? Colors.transparent : Colors.grey.shade300),
                              ),
                              alignment: Alignment.center,
                              child: Text("Password",
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isPassword ? FontWeight.w700 : FontWeight.w500,
                                      color: isPassword ? Colors.white : Colors.black54)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => isPassword = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !isPassword ? const Color(0xFF1F5D3A) : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: !isPassword ? Colors.transparent : Colors.grey.shade300),
                              ),
                              alignment: Alignment.center,
                              child: Text("PIN",
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: !isPassword ? FontWeight.w700 : FontWeight.w500,
                                      color: !isPassword ? Colors.white : Colors.black54)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(isPassword ? "ACCOUNT PASSWORD" : "SECURE PIN",
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black54, letterSpacing: 0.5)),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: _pinController,
                      hintText: isPassword ? "Enter account password" : "Enter 4-digit PIN",
                      prefixIcon: isPassword ? Icons.lock_outline_rounded : Icons.dialpad_rounded,
                      obscureText: true,
                    ),
                    const SizedBox(height: 32),
                    // 🔥 SIGN IN BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleSignIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F5D3A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : const Text("Sign in Securely",
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 0.2)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Center(
                      child: Text("Forgot details? Contact Bank",
                          style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500)),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14),
                          child: Text("SUPPORT", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1.0)),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // 🔥 AI BUTTON
                    Center(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.support_agent_rounded, size: 18),
                        label: const Text(
                          "Talk to WealthBot",
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1F5D3A),
                          side: const BorderSide(color: Color(0xFF1F5D3A), width: 1.5),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, -5))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            _BottomAction(icon: Icons.map_outlined, label: "Find ATM"),
            _BottomAction(icon: Icons.headset_mic_outlined, label: "Help Desk"),
            _BottomAction(icon: Icons.security_outlined, label: "Safety"),
          ],
        ),
      ),
    );
  }
}

class _BottomAction extends StatelessWidget {
  final IconData icon;
  final String label;
  const _BottomAction({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 22, color: const Color(0xFF1F5D3A).withValues(alpha: 0.7)),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black54)),
      ],
    );
  }
}