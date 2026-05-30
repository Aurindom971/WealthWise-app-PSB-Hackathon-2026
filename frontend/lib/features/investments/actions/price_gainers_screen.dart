import 'package:flutter/material.dart';
import 'stock_detail_view_screen.dart';

class PriceGainersScreen extends StatefulWidget {
  const PriceGainersScreen({super.key});

  @override
  State<PriceGainersScreen> createState() => _PriceGainersScreenState();
}

class _PriceGainersScreenState extends State<PriceGainersScreen> {
  final Color kForest = const Color(0xFF1F5D3A);
  final Color kCream = const Color(0xFFF2F0EB);

  final List<Map<String, dynamic>> _gainers = [
    {
      'contract': 'ADANIENT 30 JUN 3000 CALL',
      'ltp': '120.00',
      'change': '+15.50 (12.92%)',
      'isUp': true,
      'expiryDate': '30 Jun 2026',
      'underlying': 'Nifty 50 Index',
      'underlyingVal': '22,450.20',
      'underlyingChg': '+101.40 (+0.45%)',
    },
    {
      'contract': 'WIPRO 30 JUN 450 CALL',
      'ltp': '18.20',
      'change': '+2.10 (13.04%)',
      'isUp': true,
      'expiryDate': '30 Jun 2026',
      'underlying': 'Nifty IT Index',
      'underlyingVal': '34,910.15',
      'underlyingChg': '+413.20 (+1.20%)',
    },
    {
      'contract': 'TITAN 30 JUN 3400 CALL',
      'ltp': '95.00',
      'change': '+9.80 (11.50%)',
      'isUp': true,
      'expiryDate': '30 Jun 2026',
      'underlying': 'Nifty 50 Index',
      'underlyingVal': '22,450.20',
      'underlyingChg': '+101.40 (+0.45%)',
    },
    {
      'contract': 'AXISBANK 30 JUN 1100 CALL',
      'ltp': '32.40',
      'change': '+3.80 (13.29%)',
      'isUp': true,
      'expiryDate': '30 Jun 2026',
      'underlying': 'Nifty Bank Index',
      'underlyingVal': '48,115.30',
      'underlyingChg': '-120.10 (-0.25%)',
    },
    {
      'contract': 'LT 30 JUN 3600 CALL',
      'ltp': '115.50',
      'change': '+12.45 (12.08%)',
      'isUp': true,
      'expiryDate': '30 Jun 2026',
      'underlying': 'Nifty 50 Index',
      'underlyingVal': '22,450.20',
      'underlyingChg': '+101.40 (+0.45%)',
    },
    {
      'contract': 'M&M 30 JUN 2000 CALL',
      'ltp': '78.00',
      'change': '+8.10 (11.59%)',
      'isUp': true,
      'expiryDate': '30 Jun 2026',
      'underlying': 'Nifty 50 Index',
      'underlyingVal': '22,450.20',
      'underlyingChg': '+101.40 (+0.45%)',
    },
    {
      'contract': 'RELIANCE 30 JUN 2900 CALL',
      'ltp': '88.50',
      'change': '+9.20 (11.60%)',
      'isUp': true,
      'expiryDate': '30 Jun 2026',
      'underlying': 'Nifty 50 Index',
      'underlyingVal': '22,450.20',
      'underlyingChg': '+101.40 (+0.45%)',
    },
    {
      'contract': 'HDFCBANK 30 JUN 1600 CALL',
      'ltp': '42.15',
      'change': '+4.30 (11.36%)',
      'isUp': true,
      'expiryDate': '30 Jun 2026',
      'underlying': 'Nifty Bank Index',
      'underlyingVal': '48,115.30',
      'underlyingChg': '-120.10 (-0.25%)',
    },
    {
      'contract': 'TCS 30 JUN 4000 CALL',
      'ltp': '110.00',
      'change': '+11.20 (11.34%)',
      'isUp': true,
      'expiryDate': '30 Jun 2026',
      'underlying': 'Nifty IT Index',
      'underlyingVal': '34,910.15',
      'underlyingChg': '+413.20 (+1.20%)',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: kForest, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price Gainers',
              style: TextStyle(color: kForest, fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const Text(
              'Updated real-time \u2022 F&O Segment',
              style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      body: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Options Contract',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                Text(
                  'LTP',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: _gainers.length,
                separatorBuilder: (context, index) => Divider(color: Colors.grey.shade100, height: 24),
                itemBuilder: (context, index) {
                  final gainer = _gainers[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StockDetailViewScreen(
                            title: gainer['contract'],
                            price: gainer['ltp'],
                            change: gainer['change'],
                            isUp: gainer['isUp'],
                            expiryDate: gainer['expiryDate'],
                            underlyingIndexName: gainer['underlying'],
                            underlyingIndexValue: gainer['underlyingVal'],
                            underlyingIndexChange: gainer['underlyingChg'],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      color: Colors.transparent, // Ensures the entire row area is clickable
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                gainer['contract'],
                                style: TextStyle(
                                  color: kForest,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'NSE \u2022 Volume Booster',
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                gainer['ltp'],
                                style: TextStyle(
                                  color: kForest,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                gainer['change'],
                                style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
