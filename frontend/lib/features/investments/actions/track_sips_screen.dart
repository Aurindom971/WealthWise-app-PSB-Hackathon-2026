import 'package:flutter/material.dart';
import '../../home/widgets/home_navigation_widgets.dart';

class TrackSIPsScreen extends StatefulWidget {
  const TrackSIPsScreen({super.key});

  @override
  State<TrackSIPsScreen> createState() => _TrackSIPsScreenState();
}

class _TrackSIPsScreenState extends State<TrackSIPsScreen> {
  final List<Map<String, dynamic>> _activeSIPs = [
    {
      'fund': 'HDFC Index Fund',
      'amount': '5,000',
      'nextDate': '15 May',
      'daysLeft': 28,
      'status': 'Active',
      'color': Colors.green,
    },
    {
      'fund': 'Quant Small Cap',
      'amount': '2,500',
      'nextDate': '22 May',
      'daysLeft': 35,
      'status': 'Active',
      'color': Colors.green,
    },
    {
      'fund': 'SBI Bluechip Fund',
      'amount': '3,000',
      'nextDate': '10 May',
      'daysLeft': 23,
      'status': 'Paused',
      'color': Colors.orange,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: TopBar(
                searchText: 'Search in SIPs',
                onHomeTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
                onLogoutTap: () => Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false),
                onNotificationTap: () {},
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: const Icon(Icons.arrow_back, color: kForest, size: 20),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Track My SIPs',
                          style: TextStyle(color: kForest, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSummaryCard(),
                    _buildSectionTitle('Active Direct Mandates'),
                    _buildSIPList(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: 4,
        onTap: (index) {
          if (index == 4) return;
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/home',
            (route) => false,
            arguments: {'index': index},
          );
        },
        onLogoutTap: () => Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false),
        onNotificationTap: () {},
      ),
    );
  }


  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kForest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: kForest.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOTAL MONTHLY SIP',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          const Text(
            '₹ 10,500',
            style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildMiniStat('3 Mandates', Icons.check_circle_outline),
              const SizedBox(width: 16),
              _buildMiniStat('Next: 10 May', Icons.calendar_today_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 14),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Text(
        title,
        style: const TextStyle(color: kForest, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSIPList() {
    return Column(
      children: _activeSIPs.map((sip) => _buildSIPCard(sip)).toList(),
    );
  }

  Widget _buildSIPCard(Map<String, dynamic> sip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(color: kCream, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.receipt_long, color: kForest),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(sip['fund'], style: const TextStyle(color: kForest, fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text('Next: ${sip['nextDate']}', style: const TextStyle(color: kSub, fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('₹ ${sip['amount']}', style: const TextStyle(color: kForest, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: sip['color'].withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        '${sip['daysLeft']} Days Left',
                        style: TextStyle(color: sip['color'], fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionLink(Icons.history, 'History'),
                Row(
                  children: [
                    _buildActionButton('Pause', Colors.orange),
                    const SizedBox(width: 12),
                    _buildActionButton('Edit', Colors.blue),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionLink(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: kSub, size: 16),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: kSub, fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildActionButton(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
