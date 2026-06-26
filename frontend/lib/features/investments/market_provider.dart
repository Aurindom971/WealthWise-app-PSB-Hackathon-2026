import 'package:flutter/foundation.dart';
import 'yahoo_finance_service.dart';
import 'nse_service.dart';

class MarketProvider extends ChangeNotifier {
  final YahooFinanceService _yahooService = YahooFinanceService();
  final NseService _nseService = NseService();

  // Yahoo Finance data
  List<IndexQuote> indices = [];
  List<StockQuote> stocks = [];
  FnoData? fnoData;
  List<MutualFundNAV> topFunds = [];

  // NSE data
  List<IPOData> liveIpos = [];
  List<NFOData> liveNfos = [];
  List<IntradayPoint> niftyIntraday = [];
  List<IntradayPoint> niftyHistorical = [];
  FiiDiiData? fiiDiiData;
  List<OptionChainRow> optionChain = [];
  String selectedOptionSymbol = 'NIFTY';

  // State
  bool isLoading = false;
  bool isOptionChainLoading = false;
  String? error;

  Future<void> initialize() async {
    await refreshAll();
  }

  Future<void> refreshAll() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // Run all in parallel
      await Future.wait([
        _loadStockData(),
        _loadNseData(),
      ]);
    } catch (e) {
      error = 'Failed to load some data.';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> _loadStockData() async {
    try {
      final results = await Future.wait([
        _yahooService.getMarketIndices(),
        _yahooService.getStockQuotes([
          'INFY', 'TCS', 'RELIANCE', 'HDFCBANK',
          'WIPRO', 'SBIN', 'ICICIBANK', 'BHARTIARTL',
        ]),
        _yahooService.getFnoData(),
        _yahooService.getTopMutualFunds(),
      ]);

      indices  = results[0] as List<IndexQuote>;
      stocks   = results[1] as List<StockQuote>;
      fnoData  = results[2] as FnoData;
      topFunds = results[3] as List<MutualFundNAV>;
    } catch (_) {}
  }

  Future<void> _loadNseData() async {
    try {
      final results = await Future.wait([
        _nseService.getLiveIPOs(),
        _nseService.getLiveNFOs(),
        _nseService.getNiftyIntraday(),
        _nseService.getFiiDiiData(),
        _nseService.getNiftyHistorical(interval: '1d', range: '3mo'),
      ]);

      liveIpos        = results[0] as List<IPOData>;
      liveNfos        = results[1] as List<NFOData>;
      niftyIntraday   = results[2] as List<IntradayPoint>;
      fiiDiiData      = results[3] as FiiDiiData;
      niftyHistorical = results[4] as List<IntradayPoint>;
    } catch (_) {}
  }

  // Load option chain for selected symbol
  Future<void> loadOptionChain(String symbol) async {
    selectedOptionSymbol = symbol;
    isOptionChainLoading = true;
    notifyListeners();

    optionChain = await _nseService.getOptionChain(symbol);

    isOptionChainLoading = false;
    notifyListeners();
  }

  // Convenience getters
  IndexQuote? get nifty50 =>
      indices.where((i) => i.name == 'NIFTY 50').firstOrNull;

  IndexQuote? get sensex =>
      indices.where((i) => i.name == 'SENSEX').firstOrNull;

  StockQuote? getStock(String symbol) =>
      stocks.where((s) => s.symbol == symbol).firstOrNull;

  // Get intraday as FlSpot-compatible list
  List<Map<String, double>> get niftyIntradaySpots {
    if (niftyIntraday.isEmpty) return [];
    return niftyIntraday.asMap().entries.map((e) =>
      {"x": e.key.toDouble(), "y": e.value.price}
    ).toList();
  }

  // ATM strike for option chain display
  double get atmStrike {
    if (optionChain.isEmpty) return 0;
    final spotPrice = nifty50?.price ?? 22500;
    return optionChain
        .map((r) => r.strikePrice)
        .reduce((a, b) =>
            (a - spotPrice).abs() < (b - spotPrice).abs() ? a : b);
  }
}
