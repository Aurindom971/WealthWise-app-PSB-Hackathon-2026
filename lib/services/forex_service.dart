import 'dart:convert';
import 'package:http/http.dart' as http;

class ForexService {
  static const String _baseUrl = 'https://open.er-api.com/v6/latest';
  
  // Cache to store rates and avoid frequent API calls
  static Map<String, dynamic>? _cachedData;
  static DateTime? _lastFetch;
  static const Duration _cacheDuration = Duration(minutes: 30);

  Future<Map<String, dynamic>> getLatestRates(String baseCurrency) async {
    // Check if we have valid cache
    if (_cachedData != null && _lastFetch != null) {
      if (DateTime.now().difference(_lastFetch!) < _cacheDuration && _cachedData!['base_code'] == baseCurrency) {
        return _cachedData!;
      }
    }

    try {
      final response = await http.get(Uri.parse('$_baseUrl/$baseCurrency'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _cachedData = data;
        _lastFetch = DateTime.now();
        return data;
      } else {
        throw Exception('Failed to load exchange rates');
      }
    } catch (e) {
      // If network fails and we have cache (even old), return it
      if (_cachedData != null) return _cachedData!;
      rethrow;
    }
  }

  double convert(double amount, String from, String to, Map<String, dynamic> rates) {
    if (from == to) return amount;
    
    final Map<String, dynamic> rateMap = rates['rates'];
    final double fromRate = (rateMap[from] ?? 1.0).toDouble();
    final double toRate = (rateMap[to] ?? 1.0).toDouble();
    
    // amount in base / fromRate * toRate
    return (amount / fromRate) * toRate;
  }
}
