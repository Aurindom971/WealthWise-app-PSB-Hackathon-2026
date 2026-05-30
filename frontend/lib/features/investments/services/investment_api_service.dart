import 'dart:async';

class InvestmentApiService {
  // Simulate network latency (e.g., 200ms) for realistic API simulation
  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  /// Fetches a list of 20 Suggested Stocks for the Market section
  Future<List<Map<String, dynamic>>> fetchSuggestedStocks() async {
    await _simulateNetworkDelay();
    return [
      {
        'symbol': 'INFY',
        'name': 'Infosys Ltd',
        'price': '1,316',
        'change': '+0.82',
        'isUp': true,
        'history': [1305.0, 1318.0, 1310.0, 1322.0, 1316.0],
      },
      {
        'symbol': 'TCS',
        'name': 'Tata Consultancy',
        'price': '2,573',
        'change': '+0.71',
        'isUp': true,
        'history': [2554.0, 2580.0, 2570.0, 2590.0, 2573.0],
      },
      {
        'symbol': 'RELIANCE',
        'name': 'Reliance Industries',
        'price': '1,345',
        'change': '+0.13',
        'isUp': true,
        'history': [1344.0, 1350.0, 1340.0, 1348.0, 1345.0],
      },
      {
        'symbol': 'HDFCBANK',
        'name': 'HDFC Bank Ltd',
        'price': '794',
        'change': '-1.96',
        'isUp': false,
        'history': [810.0, 805.0, 812.0, 798.0, 794.0],
      },
      {
        'symbol': 'WIPRO',
        'name': 'Wipro Ltd',
        'price': '210',
        'change': '+0.19',
        'isUp': true,
        'history': [209.0, 211.0, 210.0, 212.0, 210.0],
      },
      {
        'symbol': 'SBIN',
        'name': 'State Bank of India',
        'price': '620',
        'change': '+1.25',
        'isUp': true,
        'history': [608.0, 615.0, 610.0, 622.0, 620.0],
      },
      {
        'symbol': 'ICICIBANK',
        'name': 'ICICI Bank Ltd',
        'price': '980',
        'change': '+0.85',
        'isUp': true,
        'history': [968.0, 975.0, 970.0, 982.0, 980.0],
      },
      {
        'symbol': 'BHARTIARTL',
        'name': 'Bharti Airtel Ltd',
        'price': '1,120',
        'change': '-0.45',
        'isUp': false,
        'history': [1132.0, 1125.0, 1130.0, 1118.0, 1120.0],
      },
      {
        'symbol': 'AXISBANK',
        'name': 'Axis Bank Ltd',
        'price': '1,040',
        'change': '+1.10',
        'isUp': true,
        'history': [1025.0, 1038.0, 1030.0, 1042.0, 1040.0],
      },
      {
        'symbol': 'ITC',
        'name': 'ITC Ltd',
        'price': '410',
        'change': '-0.75',
        'isUp': false,
        'history': [415.0, 412.0, 416.0, 408.0, 410.0],
      },
      {
        'symbol': 'LT',
        'name': 'Larsen & Toubro Ltd',
        'price': '3,450',
        'change': '+2.10',
        'isUp': true,
        'history': [3380.0, 3420.0, 3400.0, 3460.0, 3450.0],
      },
      {
        'symbol': 'HINDUNILVR',
        'name': 'Hindustan Unilever Ltd',
        'price': '2,280',
        'change': '-1.20',
        'isUp': false,
        'history': [2310.0, 2300.0, 2305.0, 2270.0, 2280.0],
      },
      {
        'symbol': 'BAJFINANCE',
        'name': 'Bajaj Finance Ltd',
        'price': '6,890',
        'change': '+0.95',
        'isUp': true,
        'history': [6820.0, 6860.0, 6840.0, 6910.0, 6890.0],
      },
      {
        'symbol': 'MARUTI',
        'name': 'Maruti Suzuki India Ltd',
        'price': '10,250',
        'change': '+1.45',
        'isUp': true,
        'history': [10100.0, 10200.0, 10150.0, 10280.0, 10250.0],
      },
      {
        'symbol': 'ASIANPAINT',
        'name': 'Asian Paints Ltd',
        'price': '2,850',
        'change': '-0.60',
        'isUp': false,
        'history': [2870.0, 2860.0, 2868.0, 2842.0, 2850.0],
      },
      {
        'symbol': 'HCLTECH',
        'name': 'HCL Technologies Ltd',
        'price': '1,420',
        'change': '+0.50',
        'isUp': true,
        'history': [1410.0, 1425.0, 1415.0, 1422.0, 1420.0],
      },
      {
        'symbol': 'SUNPHARMA',
        'name': 'Sun Pharmaceutical Industries',
        'price': '1,540',
        'change': '+1.30',
        'isUp': true,
        'history': [1520.0, 1535.0, 1530.0, 1545.0, 1540.0],
      },
      {
        'symbol': 'ADANIENT',
        'name': 'Adani Enterprises Ltd',
        'price': '3,120',
        'change': '+3.40',
        'isUp': true,
        'history': [3010.0, 3080.0, 3050.0, 3140.0, 3120.0],
      },
      {
        'symbol': 'TATAMOTORS',
        'name': 'Tata Motors Ltd',
        'price': '950',
        'change': '+2.85',
        'isUp': true,
        'history': [920.0, 940.0, 930.0, 955.0, 950.0],
      },
      {
        'symbol': 'COALINDIA',
        'name': 'Coal India Ltd',
        'price': '430',
        'change': '+0.40',
        'isUp': true,
        'history': [425.0, 432.0, 428.0, 431.0, 430.0],
      },
    ];
  }

  /// Fetches a list of Live and Upcoming IPOs
  Future<List<Map<String, dynamic>>> fetchLiveIpos() async {
    await _simulateNetworkDelay();
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
      {
        'name': 'Global Logistics Ltd',
        'price': '₹310-₹325',
        'min': '₹14,880',
        'lot': 48,
        'dates': '28 Mar - 01 Apr',
      },
      {
        'name': 'Zenith Biotech',
        'price': '₹140-₹152',
        'min': '₹14,000',
        'lot': 100,
        'dates': '30 Mar - 03 Apr',
      },
      {
        'name': 'Matrix Semiconductors',
        'price': '₹450-₹475',
        'min': '₹13,500',
        'lot': 30,
        'dates': '02 Apr - 06 Apr',
      },
      {
        'name': 'Apex Consumer Goods',
        'price': '₹80-₹85',
        'min': '₹14,400',
        'lot': 180,
        'dates': '04 Apr - 08 Apr',
      },
      {
        'name': 'Quantum Energy Systems',
        'price': '₹270-₹285',
        'min': '₹13,500',
        'lot': 50,
        'dates': '06 Apr - 10 Apr',
      },
      {
        'name': 'Stellar Agro Foods',
        'price': '₹115-₹120',
        'min': '₹13,800',
        'lot': 120,
        'dates': '08 Apr - 12 Apr',
      },
      {
        'name': 'Infinity Cyber Security',
        'price': '₹590-₹620',
        'min': '₹14,160',
        'lot': 24,
        'dates': '10 Apr - 14 Apr',
      },
      {
        'name': 'Blue Horizon Aviation',
        'price': '₹710-₹750',
        'min': '₹14,200',
        'lot': 20,
        'dates': '12 Apr - 16 Apr',
      },
    ];
  }

  /// Fetches a list of F&O Trading Ideas
  Future<List<Map<String, dynamic>>> fetchTradingIdeas() async {
    await _simulateNetworkDelay();
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
      {
        'contract': 'RELIANCE 30 JUN 2900 CALL',
        'price': '88.50',
        'change': '+12.40 (16.29%)',
        'isUp': true,
        'buy': 75.00,
        'target': 150.00,
        'sl': 50.00,
        'provider': 'Investogainer Research',
        'funds': 4425.00,
      },
      {
        'contract': 'TCS 30 JUN 4000 CALL',
        'price': '110.00',
        'change': '-15.55 (12.39%)',
        'isUp': false,
        'buy': 125.00,
        'target': 220.00,
        'sl': 80.00,
        'provider': 'Lotus Funds',
        'funds': 5500.00,
      },
      {
        'contract': 'INFY 30 JUN 1500 CALL',
        'price': '42.15',
        'change': '+4.80 (12.85%)',
        'isUp': true,
        'buy': 35.00,
        'target': 75.00,
        'sl': 20.00,
        'provider': 'Investogainer Research',
        'funds': 2107.50,
      },
      {
        'contract': 'BDL 30 JUN 1200 CALL',
        'price': '30.55',
        'change': '-71.27 (71.27%)',
        'isUp': false,
        'buy': 29.05,
        'target': 60.00,
        'sl': 15.00,
        'provider': 'Investogainer Research',
        'funds': 10192.42,
      },
      {
        'contract': 'ICICIBANK 30 JUN 1100 CALL',
        'price': '35.40',
        'change': '+3.80 (12.02%)',
        'isUp': true,
        'buy': 28.00,
        'target': 55.00,
        'sl': 18.00,
        'provider': 'Lotus Funds',
        'funds': 1770.00,
      },
      {
        'contract': 'SBIN 30 JUN 800 PUT',
        'price': '22.15',
        'change': '-2.10 (8.66%)',
        'isUp': false,
        'buy': 25.00,
        'target': 45.00,
        'sl': 15.00,
        'provider': 'Investogainer Research',
        'funds': 1107.50,
      },
    ];
  }

  /// Fetches a list of Top Performing Mutual Funds
  Future<List<Map<String, dynamic>>> fetchTopFunds() async {
    await _simulateNetworkDelay();
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
      {
        'name': 'Nippon India Small Cap',
        'category': 'Equity • Small Cap',
        'return': '41.8%',
        'price': '135.10',
      },
      {
        'name': 'HDFC Mid-Cap Opportunities',
        'category': 'Equity • Mid Cap',
        'return': '34.2%',
        'price': '160.50',
      },
      {
        'name': 'SBI Bluechip Fund',
        'category': 'Equity • Large Cap',
        'return': '22.4%',
        'price': '92.30',
      },
      {
        'name': 'ICICI Prudential Bluechip',
        'category': 'Equity • Large Cap',
        'return': '24.1%',
        'price': '105.80',
      },
      {
        'name': 'Mirae Asset Large & Midcap',
        'category': 'Equity • Large & Midcap',
        'return': '29.6%',
        'price': '142.70',
      },
      {
        'name': 'Axis Small Cap Fund',
        'category': 'Equity • Small Cap',
        'return': '36.8%',
        'price': '98.20',
      },
      {
        'name': 'Tata Digital India Fund',
        'category': 'Equity • Sectoral/Thematic',
        'return': '31.5%',
        'price': '54.60',
      },
      {
        'name': 'Kotak Emerging Equity',
        'category': 'Equity • Mid Cap',
        'return': '32.9%',
        'price': '122.40',
      },
      {
        'name': 'DSP Micro Cap Fund',
        'category': 'Equity • Small Cap',
        'return': '39.4%',
        'price': '170.80',
      },
      {
        'name': 'Motilal Oswal Midcap Fund',
        'category': 'Equity • Mid Cap',
        'return': '38.2%',
        'price': '88.90',
      },
      {
        'name': 'Edelweiss Balanced Advantage',
        'category': 'Hybrid • Dynamic Allocation',
        'return': '18.5%',
        'price': '42.10',
      },
      {
        'name': 'SBI Contra Fund',
        'category': 'Equity • Contra',
        'return': '33.8%',
        'price': '112.50',
      },
      {
        'name': 'Invesco India Growth Fund',
        'category': 'Equity • Large Cap',
        'return': '20.7%',
        'price': '96.40',
      },
    ];
  }

  /// Fetches a list of Live Mutual Fund NFOs
  Future<List<Map<String, dynamic>>> fetchLiveNfos() async {
    await _simulateNetworkDelay();
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
      {
        'name': 'Quant Tech Fund',
        'date': 'Closes 28 Apr',
        'min': 5000.0,
        'closesInDays': 23,
        'description': 'Focused portfolio targeting cutting-edge technology, AI, software, and semiconductor leaders.',
      },
      {
        'name': 'Nippon India Power & Infra',
        'date': 'Closes 02 May',
        'min': 1000.0,
        'closesInDays': 27,
        'description': 'Participates in India\'s massive infrastructure, power generation, and green energy initiatives.',
      },
      {
        'name': 'Mirae Asset Balanced Advantage',
        'date': 'Closes 05 May',
        'min': 500.0,
        'closesInDays': 30,
        'description': 'Dynamic asset allocation utilizing proprietary models to balance equity and debt structures.',
      },
      {
        'name': 'Axis Consumption Fund',
        'date': 'Closes 10 May',
        'min': 1000.0,
        'closesInDays': 35,
        'description': 'Captures the massive growth potential of domestic middle-class consumer demand.',
      },
      {
        'name': 'Kotak Multi Asset Allocator',
        'date': 'Closes 15 May',
        'min': 5000.0,
        'closesInDays': 40,
        'description': 'Diversified allocation across equity, debt, gold, and international ETFs.',
      },
      {
        'name': 'Tata Green Energy Fund',
        'date': 'Closes 20 May',
        'min': 1000.0,
        'closesInDays': 45,
        'description': 'Focused thematic exposure targeting sustainable wind, solar, and EV infrastructure.',
      },
      {
        'name': 'DSP Healthcare Fund',
        'date': 'Closes 25 May',
        'min': 500.0,
        'closesInDays': 50,
        'description': 'Thematic exposure to hospitals, pharma manufacturers, and advanced biotech research.',
      },
    ];
  }
}
