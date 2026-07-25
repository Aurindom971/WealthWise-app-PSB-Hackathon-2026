import 'package:http/http.dart' as http;
import '../services/token_service.dart';
import '../providers/auth_provider.dart';

class AuthInterceptor extends http.BaseClient {
  final http.Client _inner;

  AuthInterceptor(this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // 1. Retrieve the token securely from flutter_secure_storage
    final token = await TokenService.instance.getToken();
    
    // 2. Automatically attach the Authorization Bearer token header
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
      
      // Log only the first 8 characters for debugging (Task 9)
      final preview = token.length > 8 ? token.substring(0, 8) : token;
      print("[DEBUG] Request authorization header set. Token preview: $preview...");
    }
    
    // 3. Send request
    final response = await _inner.send(request);
    
    // 4. Handle HTTP 401 Unauthorized Responses for protected routes
    if (response.statusCode == 401 && !request.url.path.endsWith('/login')) {
      print("[DEBUG] Unauthorized Response (401). Invalidating session.");
      
      // Delete stored token
      await TokenService.instance.deleteToken();
      print("[DEBUG] Token Deleted due to 401 response.");
      
      // Notify AuthProvider to clean session and navigate to login
      AuthProvider.instance.handleSessionExpired();
    }
    
    return response;
  }
}
