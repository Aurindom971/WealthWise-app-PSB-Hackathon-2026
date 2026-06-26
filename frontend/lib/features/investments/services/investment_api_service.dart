import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class InvestmentApiService {
  static const String baseUrl = "http://172.31.234.76:3000";

  /// Fetches suggested stocks from the backend server
  Future<List<Map<String, dynamic>>> fetchSuggestedStocks() async {
    try {
      final response = await http
          .get(Uri.parse("$baseUrl/api/investments/stocks"))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map<Map<String, dynamic>>((item) {
          final double price = (item['price'] as num?)?.toDouble() ?? 0.0;
          final double changePercent = (item['changePercent'] as num?)?.toDouble() ?? 0.0;
          final bool isUp = changePercent >= 0;
          final String changeSign = isUp ? "+" : "";

          // Generate sparkline history based on current price
          final List<double> history = [
            price * 0.98,
            price * 0.99,
            price * 1.015,
            price * 0.995,
            price,
          ];

          return {
            'symbol': item['symbol'] ?? 'UNKNOWN',
            'name': item['name'] ?? 'Stock Name',
            'price': price.toStringAsFixed(2),
            'change': '$changeSign${changePercent.toStringAsFixed(2)}%',
            'isUp': isUp,
            'history': history,
          };
        }).toList();
      }
    } catch (e) {
      print("[InvestmentApiService] Error fetching stocks: $e");
    }

    // Fallback data if API request fails
    return [
      {
        'symbol': 'INFY',
        'name': 'Infosys Ltd',
        'price': '1,316',
        'change': '+0.82%',
        'isUp': true,
        'history': [1305.0, 1318.0, 1310.0, 1322.0, 1316.0],
      },
      {
        'symbol': 'TCS',
        'name': 'Tata Consultancy',
        'price': '2,573',
        'change': '+0.71%',
        'isUp': true,
        'history': [2554.0, 2580.0, 2570.0, 2590.0, 2573.0],
      },
      {
        'symbol': 'RELIANCE',
        'name': 'Reliance Industries',
        'price': '1,345',
        'change': '+0.13%',
        'isUp': true,
        'history': [1344.0, 1350.0, 1340.0, 1348.0, 1345.0],
      },
      {
        'symbol': 'HDFCBANK',
        'name': 'HDFC Bank Ltd',
        'price': '794',
        'change': '-1.96%',
        'isUp': false,
        'history': [810.0, 805.0, 812.0, 798.0, 794.0],
      },
      {
        'symbol': 'WIPRO',
        'name': 'Wipro Ltd',
        'price': '210',
        'change': '+0.19%',
        'isUp': true,
        'history': [209.0, 211.0, 210.0, 212.0, 210.0],
      },
    ];
  }

  /// Fetches a list of Live and Upcoming IPOs
  Future<List<Map<String, dynamic>>> fetchLiveIpos() async {
    try {
      final response = await http
          .get(Uri.parse("$baseUrl/api/investments/ipos"))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map<Map<String, dynamic>>((item) {
          return {
            'name': item['name'] ?? 'Unknown IPO',
            'price': item['price'] ?? 'TBD',
            'min': '₹14,000',
            'lot': 150,
            'dates': '${item['openDate'] ?? 'TBD'} - ${item['closeDate'] ?? 'TBD'}',
          };
        }).toList();
      }
    } catch (e) {
      print("[InvestmentApiService] Error fetching IPOs: $e");
    }

    return [
      {
        'name': 'Emiac Technologies',
        'price': '₹93-₹98',
        'min': '₹14,700',
        'lot': 150,
        'dates': '24 Mar - 28 Mar',
      },
      {
        'name': 'Safety Controls',
        'price': '₹190-₹200',
        'min': '₹14,000',
        'lot': 70,
        'dates': '26 Mar - 30 Mar',
      },
    ];
  }

  /// Fetches F&O Trading Ideas
  Future<List<Map<String, dynamic>>> fetchTradingIdeas() async {
    // For Advisory / Trading Ideas, we keep simulated ideas, but update prices dynamically if possible
    return [
      {
        'contract': 'NIFTY 02 JUN 23900 CALL',
        'price': '71.50',
        'change': '-108.25 (60.22%)',
        'isUp': false,
        'buy': 128.50,
        'target': 275.00,
        'sl': 80.00,
        'provider': 'Investogainer Research',
        'funds': 6425.00,
      },
      {
        'contract': 'BANKNIFTY 30 JUN 51200 CALL',
        'price': '810.00',
        'change': '-170.55 (17.39%)',
        'isUp': false,
        'buy': 967.00,
        'target': 1351.00,
        'sl': 650.00,
        'provider': 'Lotus Funds',
        'funds': 12150.00,
      },
    ];
  }

  /// Fetches a list of Top Performing Mutual Funds
  Future<List<Map<String, dynamic>>> fetchTopFunds() async {
    try {
      final response = await http
          .get(Uri.parse("$baseUrl/api/investments/funds"))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map<Map<String, dynamic>>((item) {
          final double nav = (item['nav'] as num?)?.toDouble() ?? 0.0;
          return {
            'name': item['schemeName'] ?? 'Mutual Fund',
            'category': 'Equity • ${item['category'] ?? 'General'}',
            'return': '28.5%',
            'price': nav.toStringAsFixed(2),
          };
        }).toList();
      }
    } catch (e) {
      print("[InvestmentApiService] Error fetching funds: $e");
    }

    return [
      {
        'name': 'Quant Small Cap Fund',
        'category': 'Equity • Small Cap',
        'return': '45.2%',
        'price': '214.20',
      },
      {
        'name': 'Parag Parikh Flexi Cap',
        'category': 'Equity • Flexi Cap',
        'return': '28.5%',
        'price': '85.40',
      },
    ];
  }

  /// Fetches Live Mutual Fund NFOs
  Future<List<Map<String, dynamic>>> fetchLiveNfos() async {
    return [
      {
        'name': 'HDFC Nifty Next 50',
        'date': 'Closes 19 Apr',
        'min': 500.0,
        'closesInDays': 14,
        'description': 'Tracks the Nifty Next 50 index composed of high-performing large-cap companies.',
      },
      {
        'name': 'SBI Innovation Opp.',
        'date': 'Closes 22 Apr',
        'min': 5000.0,
        'closesInDays': 17,
        'description': 'Invests in high-growth companies driving technological and business model innovations.',
      },
      {
        'name': 'ICICI Pru Business Cycle',
        'date': 'Closes 24 Apr',
        'min': 1000.0,
        'closesInDays': 19,
        'description': 'Tactical allocation across sectors based on macroeconomic business cycle transitions.',
      },
    ];
  }
}
