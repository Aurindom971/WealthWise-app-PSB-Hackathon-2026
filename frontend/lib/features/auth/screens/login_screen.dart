import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../widgets/custom_textfield.dart';
import '../../../core/utils/location_helper.dart';
import '../../../core/utils/security_util.dart';
import '../../../core/services/security_service.dart';
import '../../../core/services/panic_mode_service.dart';
import '../../../core/utils/security_validator.dart';
import '../screens/helpdesk_screen.dart';
import '../screens/safety_screen.dart';
import '../screens/findatm_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;

  final TextEditingController _cusIdController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    PanicModeService.instance.exitPanicMode();
  }

  @override
  void dispose() {
    _cusIdController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    // 1. Sanitize and Validate
    final rawCusId = _cusIdController.text;
    final rawSecret = _pinController.text;

    final cusId = SecurityValidator.sanitize(rawCusId);
    final enteredSecret = SecurityValidator.sanitize(rawSecret);

    if (cusId.isEmpty || enteredSecret.isEmpty) {
      _showError(
        "REQUIRED: Please enter both Customer ID and Password to proceed.",
      );
      return;
    }

    // 2. Size/Payload Validation
    if (cusId.length > 20 || enteredSecret.length > 100) {
      _showError("SECURITY: Invalid input length detected.");
      return;
    }

    // --- 🛡️ LOCKOUT CHECK ---
    final lockoutMsg = SecurityService.instance.checkLockout(cusId);
    if (lockoutMsg != null) {
      _showError("SECURITY: $lockoutMsg");
      return;
    }

    setState(() => isLoading = true);

    try {
      final isPanic = PanicModeService.instance.isPanicPassword(enteredSecret);
      Map<String, dynamic>? userData;
      String email = 'rajeshkumar@gmail.com';

      if (!isPanic) {
        final res = await _supabase.rpc(
          'get_login_data',
          params: {'input_cus_id': cusId},
        );

        if (res == null) {
          SecurityService.instance.recordFailedAttempt(cusId);
          _showError(
            "IDENTITY: Customer ID not found in our records. Please verify and try again.",
          );
          return;
        }

        final List<dynamic> resultList = res as List<dynamic>;

        if (resultList.isEmpty) {
          SecurityService.instance.recordFailedAttempt(cusId);
          _showError(
            "IDENTITY: Customer ID not found in our records. Please verify and try again.",
          );
          return;
        }

        userData = resultList.first as Map<String, dynamic>;

        email = userData['email']?.toString() ?? '';
        final storedAuthPassword = userData['auth_password']?.toString() ?? '';
        final storedPin = userData['pin_hash']?.toString() ?? '';

        if (email.isEmpty) {
          _showError("MAINTENANCE: Email not found for this Customer ID.");
          return;
        }

        // --- 🛡️ SECURE CREDENTIAL VERIFICATION & AUTO-MIGRATION ---
        
        bool isSuccess = false;
        bool needsPasswordMigration = false;

        // PASSWORD LOGIN
        // Check if the stored password was already hashed
        if (SecurityUtil.isHash(storedAuthPassword)) {
          // If hashed in public table, we don't manually compare.
          // We rely entirely on Supabase Auth below.
          isSuccess = true;
        } else {
          // Verify plain-text (Legacy comparison)
          isSuccess = (enteredSecret == storedAuthPassword);
          if (isSuccess) needsPasswordMigration = true;
        }

        if (!isSuccess) {
          SecurityService.instance.recordFailedAttempt(cusId);
          _showError("SECURITY: The Password entered is incorrect.");
          return;
        }

        // Perform Supabase Auth
        final String supabasePassword = enteredSecret;

        final response = await _supabase.auth.signInWithPassword(
          email: email,
          password: supabasePassword,
        );

        if (response.user == null) {
          SecurityService.instance.recordFailedAttempt(cusId);
          _showError("AUTHENTICATION: Secure login could not be established. Check credentials.");
          return;
        }

        // Login Successful! Reset attempts
        SecurityService.instance.resetAttempts(cusId);
        SecurityService.instance.resetInactivityTimer();

        // --- 🚀 AUTO-MIGRATION (POST-SUCCESS) ---
        if (needsPasswordMigration) {
          try {
            final String newAuthHash = SecurityUtil.hashValue(enteredSecret);
            
            debugPrint('Triggering migration for auth password');
            
            await _supabase.rpc('migrate_user_credentials', params: {
              'p_cus_id': cusId,
              'p_new_auth_hash': newAuthHash,
            });
            debugPrint('Password migrated to secure hash successfully for $cusId');
          } catch (e) {
            debugPrint('Migration Error (Bypassed): $e');
          }
        }
      } else {
        // --- Panic Mode Flow ---
        PanicModeService.instance.isPanicMode = true;

        // Reset attempts
        SecurityService.instance.resetAttempts(cusId);
        SecurityService.instance.resetInactivityTimer();

        // Query real user details if they exist in DB to make email/fullname look legit
        try {
          final res = await _supabase.rpc(
            'get_login_data',
            params: {'input_cus_id': cusId},
          );
          if (res != null && (res as List).isNotEmpty) {
            userData = res.first as Map<String, dynamic>;
            email = userData['email']?.toString() ?? 'rajeshkumar@gmail.com';
          }
        } catch (_) {}
      }

      // --- 🌍 MANDATORY LOCATION LOGGING ---
      final locResult = await LocationHelper.getMandatoryLocation();
      if (!locResult.isSuccess) {
        if (!isPanic) {
          await _supabase.auth.signOut();
        } else {
          PanicModeService.instance.exitPanicMode();
        }
        _showError("SECURITY: ${locResult.error}");
        return;
      }

      // --- 🌍 ROBUST PUBLIC IP FETCHING ---
      String publicIp = 'unknown';
      try {
        // Try multiple services in case one is blocked/slow
        final List<String> services = [
          'https://api.ipify.org',
          'https://icanhazip.com',
          'https://checkip.amazonaws.com',
        ];

        for (var service in services) {
          try {
            final res = await http
                .get(Uri.parse(service))
                .timeout(const Duration(seconds: 2));
            if (res.statusCode == 200 && res.body.trim().isNotEmpty) {
              publicIp = res.body.trim();
              break;
            }
          } catch (_) {
            continue; // Try next service
          }
        }
      } catch (e) {
        debugPrint('IP Fetching Failed: $e');
      }

      if (isPanic) {
        await PanicModeService.instance.triggerPanicEvent(cusId);
      } else {
        // Log to location_history via RPC (Bypasses RLS issues)
        try {
          await _supabase.rpc(
            'log_login_location',
            params: {
              'p_cus_id': cusId,
              'p_lat': locResult.position?.latitude,
              'p_lng': locResult.position?.longitude,
              'p_city': locResult.city ?? 'Unknown',
              'p_state': locResult.state ?? 'Unknown',
              'p_country': locResult.country ?? 'Unknown',
              'p_device_info':
                  '${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
              'p_ip_address': publicIp,
            },
          );
          debugPrint('Location and IP Logged Successfully: $publicIp');
        } catch (logError) {
          debugPrint('Location Logging Error: $logError');
        }
      }

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }

    } on PostgrestException catch (e) {
      _showError("CONNECTION: ${e.message}");
    } on AuthException catch (e) {
      SecurityService.instance.recordFailedAttempt(cusId);
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
    } else if (message.startsWith("NETWORK:") ||
        message.startsWith("CONNECTION:")) {
      icon = Icons.wifi_off_rounded;
      color = Colors.blue.shade900;
    } else if (message.startsWith("REQUIRED:")) {
      icon = Icons.warning_amber_rounded;
      color = Colors.orange.shade900;
    } else if (message.startsWith("IDENTITY:")) {
      icon = Icons.person_search_rounded;
      color = Colors.indigo.shade800;
    } else if (message.startsWith("DATABASE:")) {
      icon = Icons.storage_rounded;
      color = Colors.blueGrey.shade900;
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
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/bank_logo_v2.png',
                          width: 32,
                          height: 32,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            "Welcome Back",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Sign in to your account securely",
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
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
                    const Text(
                      "CUSTOMER ID",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.black54,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      hintText: "Enter Customer ID",
                      prefixIcon: Icons.person_outline,
                      controller: _cusIdController,
                      maxLength: 10,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "ACCOUNT PASSWORD",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.black54,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: _pinController,
                      hintText: "Enter account password",
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: true,
                      maxLength: 100, // Safe upper limit for hashed comparisons
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
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                "Sign in Securely",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
  child: GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HelpDeskScreen(),
        ),
      );
    },
    child: const Text(
      "Forgot details? Contact Bank",
      style: TextStyle(
        fontSize: 12,
        color: Colors.black54,
        fontWeight: FontWeight.w500,
      ),
    ),
  ),
),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.grey.shade300,
                            thickness: 1,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            "SUPPORT",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.grey,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.grey.shade300,
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // 🔥 AI BUTTON
                    Center(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1F5D3A),
                          side: const BorderSide(
                            color: Color(0xFF1F5D3A),
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClipOval(
                              child: Image.asset(
                                'assets/images/ai_logo.png',
                                width: 20,
                                height: 20,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "Talk to SAGE",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
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
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
  _BottomAction(
  icon: Icons.map_outlined,
  label: "Find ATM",
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const FindAtmScreen(),
      ),
    );
  },
),

  _BottomAction(
    icon: Icons.headset_mic_outlined,
    label: "Help Desk",
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HelpDeskScreen(),
        ),
      );
    },
  ),

  _BottomAction(
    icon: Icons.security_outlined,
    label: "Safety",
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>SafetyScreen(),
        ),
      );
    },
  ),
],
        ),
      ),
    );
  }
}

class _BottomAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BottomAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: const Color(0xFF1F5D3A).withValues(alpha: 0.7),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
