import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/custom_textfield.dart';
import 'package:securewealth_twin/services/auth_service.dart';

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
        _showError("IDENTITY: Customer ID not found.");
        return;
      }

      final List<dynamic> resultList = res as List<dynamic>;
      if (resultList.isEmpty) {
        _showError("IDENTITY: Customer ID not found.");
        return;
      }

      final Map<String, dynamic> userData = resultList.first;

      final email = userData['email']?.toString() ?? '';
      final authPassword = userData['auth_password']?.toString() ?? '';
      final storedPin = userData['pin_hash']?.toString() ?? '';

      if (enteredSecret != (isPassword ? authPassword : storedPin)) {
        _showError("SECURITY: Incorrect credentials.");
        return;
      }

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: authPassword,
      );

      if (response.user == null) {
        _showError("AUTHENTICATION FAILED");
        return;
      }

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      _showError("ERROR: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Login UI here")),
    );
  }
}