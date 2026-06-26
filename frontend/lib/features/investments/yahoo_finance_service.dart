import 'dart:convert';
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────

class IndexQuote {
  final String name;
  final double price;
  final double change;
  final double changePercent;
  final double high;
  final double low;
  final double open;
  final double prevClose;

  IndexQuote({
    required this.name,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.high,
    required this.low,
    required this.open,
    required this.prevClose,
  });
}

class StockQuote {
  final String symbol;
  final String name;
  final double price;
  final double change;
  final double changePercent;
  final double high;
  final double low;
  final double open;
  final double prevClose;

  StockQuote({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.high,
    required this.low,
    required this.open,
    required this.prevClose,
  });

  bool get isPositive => change >= 0;
}

class MutualFundNAV {
  final String name;
  final String schemeCode;
  final double nav;
  final String date;
  final String category;
  final double? returns3y;

  MutualFundNAV({
    required this.name,
    required this.schemeCode,
    required this.nav,
    required this.date,
    required this.category,
    this.returns3y,
  });
}

class CandlePoint {
  final DateTime time;
  final double close;
  CandlePoint({required this.time, required this.close});
}

class FnoData {
  final double futuresPrice;
  final double futuresChange;
  final double futuresChangePercent;
  final double callOiPercent;
  final double putOiPercent;

  FnoData({
    required this.futuresPrice,
    required this.futuresChange,
    required this.futuresChangePercent,
    required this.callOiPercent,
    required this.putOiPercent,
  });
}

// ─────────────────────────────────────────────
// SERVICE
// ─────────────────────────────────────────────

class YahooFinanceService {
  static const String _baseUrl = 'https://query1.finance.yahoo.com';

  static Map<String, String> get _headers => {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'Accept': 'application/json',
        'Accept-Language': 'en-US,en;q=0.9',
      };

  Future<List<IndexQuote>> getMarketIndices() async {
    final symbols = {
      'NIFTY 50': '%5ENSEI',
      'SENSEX': '%5EBSESN',
    };
    final List<IndexQuote> indices = [];
    for (final entry in symbols.entries) {
      try {
        final res = await http
            .get(Uri.parse('$_baseUrl/v8/finance/chart/${entry.value}'),
                headers: _headers)
            .timeout(const Duration(seconds: 10));
        final data = jsonDecode(res.body);
        final meta = data['chart']['result'][0]['meta'];
        final price = (meta['regularMarketPrice'] as num).toDouble();
        final prevClose = (meta['chartPreviousClose'] as num).toDouble();
        final change = price - prevClose;
        indices.add(IndexQuote(
          name: entry.key,
          price: price,
          change: change,
          changePercent: prevClose != 0 ? (change / prevClose * 100) : 0,
          high: (meta['regularMarketDayHigh'] as num).toDouble(),
          low: (meta['regularMarketDayLow'] as num).toDouble(),
          open: (meta['regularMarketOpen'] as num).toDouble(),
          prevClose: prevClose,
        ));
      } catch (_) {}
    }
    return indices;
  }

  Future<List<StockQuote>> getStockQuotes(List<String> nseSymbols) async {
    final nameMap = {
      'INFY': 'Infosys Ltd',
      'TCS': 'Tata Consultancy',
      'RELIANCE': 'Reliance Industries',
      'HDFCBANK': 'HDFC Bank Ltd',
      'WIPRO': 'Wipro Ltd',
      'SBIN': 'State Bank of India',
      'ICICIBANK': 'ICICI Bank Ltd',
      'BHARTIARTL': 'Bharti Airtel Ltd',
    };
    final List<StockQuote> quotes = [];
    for (final symbol in nseSymbols) {
      try {
        final res = await http
            .get(
                Uri.parse('$_baseUrl/v8/finance/chart/$symbol.NS'),
                headers: _headers)
            .timeout(const Duration(seconds: 10));
        final data = jsonDecode(res.body);
        final meta = data['chart']['result'][0]['meta'];
        final price = (meta['regularMarketPrice'] as num).toDouble();
        final prevClose = (meta['chartPreviousClose'] as num).toDouble();
        final change = price - prevClose;
        quotes.add(StockQuote(
          symbol: symbol,
          name: nameMap[symbol] ?? symbol,
          price: price,
          change: change,
          changePercent: prevClose != 0 ? (change / prevClose * 100) : 0,
          high: (meta['regularMarketDayHigh'] as num).toDouble(),
          low: (meta['regularMarketDayLow'] as num).toDouble(),
          open: (meta['regularMarketOpen'] as num).toDouble(),
          prevClose: prevClose,
        ));
      } catch (_) {}
    }
    return quotes;
  }

  Future<List<CandlePoint>> getChartData({
    required String symbol,
    String interval = '1d',
    String range = '1mo',
    bool isIndex = false,
  }) async {
    final yahooSymbol = isIndex ? symbol : '$symbol.NS';
    try {
      final res = await http
          .get(
              Uri.parse(
                  '$_baseUrl/v8/finance/chart/$yahooSymbol?interval=$interval&range=$range'),
              headers: _headers)
          .timeout(const Duration(seconds: 10));
      final data = jsonDecode(res.body);
      final result = data['chart']['result'][0];
      final timestamps = result['timestamp'] as List;
      final closes = result['indicators']['quote'][0]['close'] as List;
      final List<CandlePoint> points = [];
      for (int i = 0; i < timestamps.length; i++) {
        if (closes[i] == null) continue;
        points.add(CandlePoint(
          time: DateTime.fromMillisecondsSinceEpoch(timestamps[i] * 1000),
          close: (closes[i] as num).toDouble(),
        ));
      }
      return points;
    } catch (_) {
      return [];
    }
  }

  Future<FnoData> getFnoData() async {
    double futuresPrice = 0;
    double futuresChange = 0;
    double futuresChangePct = 0;
    double callOiPercent = 58;
    double putOiPercent = 42;

    try {
      final res = await http
          .get(Uri.parse('$_baseUrl/v8/finance/chart/%5ENSEI'),
              headers: _headers)
          .timeout(const Duration(seconds: 10));
      final data = jsonDecode(res.body);
      final meta = data['chart']['result'][0]['meta'];
      final price = (meta['regularMarketPrice'] as num).toDouble();
      final prevClose = (meta['chartPreviousClose'] as num).toDouble();
      futuresPrice = price;
      futuresChange = price - prevClose;
      futuresChangePct = prevClose != 0 ? (futuresChange / prevClose * 100) : 0;
    } catch (_) {}

    try {
      final nseRes = await http
          .get(
              Uri.parse(
                  'https://www.nseindia.com/api/option-chain-indices?symbol=NIFTY'),
              headers: {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
                'Accept': '*/*',
                'Referer': 'https://www.nseindia.com/',
              })
          .timeout(const Duration(seconds: 10));
      final nseData = jsonDecode(nseRes.body);
      final filtered = nseData['filtered'];
      final totalCE = (filtered['CE']['totOI'] as num).toDouble();
      final totalPE = (filtered['PE']['totOI'] as num).toDouble();
      final total = totalCE + totalPE;
      if (total > 0) {
        callOiPercent = (totalCE / total * 100);
        putOiPercent = (totalPE / total * 100);
      }
    } catch (_) {}

    return FnoData(
      futuresPrice: futuresPrice,
      futuresChange: futuresChange,
      futuresChangePercent: futuresChangePct,
      callOiPercent: callOiPercent,
      putOiPercent: putOiPercent,
    );
  }

  Future<List<MutualFundNAV>> getTopMutualFunds() async {
    final funds = [
      {'name': 'Quant Small Cap Fund', 'code': '120503', 'category': 'Equity • Small Cap', 'returns3y': 45.2},
      {'name': 'Nippon India Small Cap', 'code': '118778', 'category': 'Equity • Small Cap', 'returns3y': 41.8},
      {'name': 'HDFC Mid-Cap Opportunities', 'code': '118989', 'category': 'Equity • Mid Cap', 'returns3y': 34.2},
      {'name': 'Parag Parikh Flexi Cap', 'code': '122639', 'category': 'Equity • Flexi Cap', 'returns3y': 28.5},
    ];
    final List<MutualFundNAV> result = [];
    for (final fund in funds) {
      try {
        final res = await http
            .get(Uri.parse('https://api.mfapi.in/mf/${fund['code']}'))
            .timeout(const Duration(seconds: 10));
        final data = jsonDecode(res.body);
        final latestNav = data['data'][0];
        result.add(MutualFundNAV(
          name: fund['name'] as String,
          schemeCode: fund['code'] as String,
          nav: double.tryParse(latestNav['nav']) ?? 0,
          date: latestNav['date'] as String,
          category: fund['category'] as String,
          returns3y: fund['returns3y'] as double?,
        ));
      } catch (_) {}
    }
    return result;
  }
}
