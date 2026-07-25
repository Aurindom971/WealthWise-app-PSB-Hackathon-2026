import 'dart:convert';
import 'package:http/http.dart' as http;
import '../interceptors/auth_interceptor.dart';

class ApiService {
  static final ApiService instance = ApiService._internal();
  late final http.Client client;
  
  // Base URL for the Node.js backend (10.0.2.2 maps to host localhost in Android emulator)
  static const String baseUrl = String.fromEnvironment(
    'BACKEND_URL', 
    defaultValue: 'http://10.0.2.2:3000'
  );

  ApiService._internal() {
    // Wrap standard http.Client with AuthInterceptor
    client = AuthInterceptor(http.Client());
  }

  /// Sends a GET request to the backend with automatic session headers.
  Future<http.Response> get(String path) async {
    return await client.get(Uri.parse('$baseUrl$path'));
  }

  /// Sends a POST request to the backend with automatic session headers.
  Future<http.Response> post(String path, {Map<String, String>? headers, Object? body}) async {
    final Map<String, String> finalHeaders = {
      'Content-Type': 'application/json',
      ...?headers,
    };
    return await client.post(
      Uri.parse('$baseUrl$path'),
      headers: finalHeaders,
      body: body != null ? jsonEncode(body) : null,
    );
  }
}
