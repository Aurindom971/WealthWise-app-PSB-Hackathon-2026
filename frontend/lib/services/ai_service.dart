import 'dart:convert';
import '../core/services/panic_mode_service.dart';
import 'api_service.dart';

class AIService {
  /// Calls the general AI chat endpoint (New Implementation)
  static Future<String> getChatReply({
    required String message,
    required String cusId,
    bool guestMode = false,
  }) async {
    if (PanicModeService.instance.isPanicMode) {
      return PanicModeService.instance.getMockAIChatReply(message);
    }
    final payload = {
      "message": message,
      "cus_id": cusId,
      "guestMode": guestMode,
    };
    try {
      print("[SAGE REQUEST]");
      print("message=$message");
      print("cus_id=$cusId");
      print("guestMode=$guestMode");

      print("[AI Service Request] Payload: $payload");
      final response = await ApiService.instance
          .post(
            "/ai-chat",
            body: payload,
          );

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
    final payload = {"cus_id": cusId, "txn": txn};
    try {
      print("[AI Service Request] Payload: $payload");
      final response = await ApiService.instance
          .post(
            "/fraud-check",
            body: payload,
          );

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
