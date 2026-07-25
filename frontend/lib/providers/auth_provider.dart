import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/token_service.dart';
import '../services/api_service.dart';
import '../core/services/security_service.dart';

class AuthProvider extends ChangeNotifier {
  // Singleton pattern for global access (e.g. from interceptor)
  static final AuthProvider instance = AuthProvider._internal();
  
  bool _isLoggedIn = false;
  Map<String, dynamic>? _currentUser;
  bool _sessionTokenAvailable = false;

  AuthProvider._internal();

  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get currentUser => _currentUser;
  /// Clears stored session tokens on app startup to enforce fresh login.
  Future<void> clearSession() async {
    _isLoggedIn = false;
    _currentUser = null;
    _sessionTokenAvailable = false;
    await TokenService.instance.deleteToken();
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (_) {}
  }

  /// Restores session from secure storage on startup.
  Future<bool> tryAutoLogin() async {
    final hasToken = await TokenService.instance.hasToken();
    if (hasToken) {
      final token = await TokenService.instance.getToken();
      final savedUser = await TokenService.instance.getUserData();
      _isLoggedIn = true;
      _sessionTokenAvailable = true;
      if (savedUser != null) {
        _currentUser = savedUser;
      } else {
        _currentUser = {
          'cus_id': 'CUST1',
          'email': 'user5@mail.com',
        };
      }
      
      // Log Session Restored (Task 9)
      final preview = (token != null && token.length > 8) ? token.substring(0, 8) : (token ?? '');
      print("[DEBUG] Session Restored | Token Preview: $preview...");
      
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Authenticates credentials with backend and secures session token.
  Future<String?> login(String emailOrCusId, String password) async {
    try {
      final payload = {
        'email': emailOrCusId.contains('@') ? emailOrCusId : null,
        'cus_id': !emailOrCusId.contains('@') ? emailOrCusId : null,
        'password': password,
      };

      // Call Node.js backend POST /login
      final response = await ApiService.instance.post('/login', body: payload);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final rawToken = data['session_token'] as String;
          _currentUser = data['user'] as Map<String, dynamic>;
          _isLoggedIn = true;
          _sessionTokenAvailable = true;

          // Store raw token and user data securely (Task 2)
          await TokenService.instance.saveToken(rawToken);
          if (_currentUser != null) {
            await TokenService.instance.saveUserData(_currentUser!);
          }
          
          // Logs for debugging (Task 9)
          final preview = rawToken.length > 8 ? rawToken.substring(0, 8) : rawToken;
          print("[DEBUG] Login Success | Token Stored | Token Preview: $preview...");
          
          notifyListeners();
          return null; // Success
        } else {
          return data['message'] ?? 'Login failed.';
        }
      } else {
        final data = jsonDecode(response.body);
        return data['message'] ?? 'Authentication failed.';
      }
    } catch (e) {
      print("[DEBUG] Login error: $e");
      return 'Connection error. Please try again.';
    }
  }

  /// Logs out user, deletes token, and redirects to login screen.
  Future<void> logout() async {
    try {
      await ApiService.instance.post('/logout');
    } catch (e) {
      print("[DEBUG] Backend logout call error (bypassed): $e");
    }

    _isLoggedIn = false;
    _currentUser = null;
    _sessionTokenAvailable = false;

    // Delete token from secure storage (Task 6)
    await TokenService.instance.deleteToken();
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (_) {}
    print("[DEBUG] Token Deleted | User Logged Out");

    notifyListeners();

    // Redirect to Login Screen
    _redirectToLogin();
  }

  /// Handles expired session (401 response).
  void handleSessionExpired() {
    if (!_isLoggedIn) return; // Already logged out

    _isLoggedIn = false;
    _currentUser = null;
    _sessionTokenAvailable = false;

    // Log Unauthorized Response (Task 9)
    print("[DEBUG] Unauthorized Response | Session Expired");

    notifyListeners();

    // Show expiration warning SnackBar
    final context = SecurityService.instance.navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Your session has expired. Please log in again.",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
        ),
      );
    }

    try {
      Supabase.instance.client.auth.signOut();
    } catch (_) {}

    // Redirect to Login Screen
    _redirectToLogin();
  }

  void _redirectToLogin() {
    final navState = SecurityService.instance.navigatorKey.currentState;
    if (navState != null) {
      navState.pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }
}
