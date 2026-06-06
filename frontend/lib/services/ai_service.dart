import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  // Use http://10.0.2.2:3000 for Android Emulator
  // Use http://localhost:3000 for iOS Simulator, Web, or Desktop
  static const String baseUrl = "http://10.0.2.2:3000";

  /// Calls the general AI chat endpoint (New Implementation)
  static Future<String> getChatReply({
    required String message,
    required String cusId,
  }) async {
    final url = "$baseUrl/ai-chat";
    final payload = jsonEncode({"message": message, "cus_id": cusId});
    try {
      print("[SAGE REQUEST]");
      print("message=$message");
      print("cus_id=$cusId");

      print("[AI Service Request] URL: $url | Payload: $payload");
      final response = await http
          .post(
            Uri.parse(url),
            headers: {"Content-Type": "application/json"},
            body: payload,
          )
          .timeout(const Duration(seconds: 30));

      print("[AI Service Response] Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['reply'] ?? "No response from AI";
        } else {
          throw Exception(data['error'] ?? "AI chat failed");
        }
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      print("[AI Service Error] Message: $e");
      return "Error connecting to AI. Please ensure backend is running.";
    }
  }

  /// Keep legacy functions if needed by other parts of the app (optional)
  static Future<Map<String, dynamic>> getFraudResult({
    required String cusId,
    required Map<String, dynamic> txn,
  }) async {
    final url = "$baseUrl/fraud-check";
    final payload = jsonEncode({"cus_id": cusId, "txn": txn});
    try {
      print("[AI Service Request] URL: $url | Payload: $payload");
      final response = await http
          .post(
            Uri.parse(url),
            headers: {"Content-Type": "application/json"},
            body: payload,
          )
          .timeout(const Duration(seconds: 20));

      print("[AI Service Response] Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      }
      throw Exception("Server error: ${response.statusCode}");
    } catch (e) {
      print("[AI Service Error] Message: $e");
      rethrow;
    }
  }
}
