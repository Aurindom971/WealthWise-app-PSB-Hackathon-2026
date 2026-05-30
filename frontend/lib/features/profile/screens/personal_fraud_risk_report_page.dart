import 'package:flutter/material.dart';
import 'package:wealthwise/features/home/widgets/home_navigation_widgets.dart';
import 'package:wealthwise/features/home/screens/notifications_screen.dart';

class PersonalFraudRiskReportPage extends StatefulWidget {
  const PersonalFraudRiskReportPage({super.key});

  @override
  State<PersonalFraudRiskReportPage> createState() => _PersonalFraudRiskReportPageState();
}

class _PersonalFraudRiskReportPageState extends State<PersonalFraudRiskReportPage> {
  int _selectedTab = 0; // 0 for Fraud Signals, 1 for Activity Timeline

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
                onHomeTap: () => Navigator.popUntil(context, (route) => route.isFirst),
                onLogoutTap: () => Navigator.popUntil(context, (route) => route.isFirst),
                onNotificationTap: () => showNotifications(context),
              ),
            ),
            
            // Header Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: kCream,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back, color: kForest, size: 20),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Personal Fraud Risk Report',
                        style: TextStyle(
                          color: kForest,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: kForest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.shield_outlined, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    // Summary Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Circular Score
                              SizedBox(
                                width: 100,
                                height: 100,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    const CircularProgressIndicator(
                                      value: 1.0,
                                      strokeWidth: 10,
                                      color: kLightGreenBg,
                                    ),
                                    const CircularProgressIndicator(
                                      value: 0.28,
                                      strokeWidth: 10,
                                      color: kForest,
                                      strokeCap: StrokeCap.round,
                                    ),
                                    Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            '28',
                                            style: TextStyle(
                                              color: kForest,
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                              height: 1.0,
                                            ),
                                          ),
                                          Text(
                                            '/100',
                                            style: TextStyle(
                                              color: kSub.withOpacity(0.7),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'FRAUD RISK SCORE',
                                      style: TextStyle(
                                        color: kSub,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: kLightGreenBg,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(Icons.circle, color: kForest, size: 8),
                                          SizedBox(width: 6),
                                          Text(
                                            'LOW RISK',
                                            style: TextStyle(
                                              color: kForest,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Your account activity appears normal. No critical fraud indicators detected.',
                                      style: TextStyle(
                                        color: kForest,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Divider(color: Color(0xFFEAF1ED)),
                          const SizedBox(height: 16),
                          const Text(
                            'MONTHLY SECURITY SUMMARY',
                            style: TextStyle(
                              color: kSub,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Grid of small cards
                          // Grid of small cards in 3-2 layout
                          Row(
                            children: [
                              Expanded(child: _buildStatCard('2', 'Login Attempts', const Color(0xFFFBE4C6), const Color(0xFFE58728))),
                              const SizedBox(width: 10),
                              Expanded(child: _buildStatCard('1', 'New Devices', const Color(0xFFFBE4C6), const Color(0xFFE58728))),
                              const SizedBox(width: 10),
                              Expanded(child: _buildStatCard('1', 'New Locations', const Color(0xFFFBE4C6), const Color(0xFFE58728))),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(child: _buildStatCard('0', 'High Velocity', kLightGreenBg, kForest)),
                              const SizedBox(width: 10),
                              Expanded(child: _buildStatCard('0', 'Flagged Transactions', kLightGreenBg, kForest)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Custom Segmented Tabs (Image 4 & 5)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF1ED),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedTab = 0),
                              child: Container(
                                height: 42,
                                decoration: BoxDecoration(
                                  color: _selectedTab == 0 ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: _selectedTab == 0
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.06),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Fraud Signals',
                                  style: TextStyle(
                                    color: _selectedTab == 0 ? kForest : kSub,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedTab = 1),
                              child: Container(
                                height: 42,
                                decoration: BoxDecoration(
                                  color: _selectedTab == 1 ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: _selectedTab == 1
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.06),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Activity Timeline',
                                  style: TextStyle(
                                    color: _selectedTab == 1 ? kForest : kSub,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Inline Tab Content (allows page to scroll naturally)
                    _selectedTab == 0 ? _buildFraudSignalsTab() : _buildActivityTimelineTab(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            BottomNav(
              currentIndex: -1,
              onTap: (i) => Navigator.popUntil(context, (route) => route.isFirst),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color bgColor, Color textColor) {
    return Container(
      height: 75,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: kForest,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFraudSignalsTab() {
    return Column(
      children: [
        _buildSignalCard(
          icon: Icons.show_chart_rounded,
          title: 'Transaction Amount',
          badgeText: 'Unusual',
          badgeColor: const Color(0xFFFBE4C6),
          badgeTextColor: const Color(0xFFE58728),
          description: 'One transaction was 3.2x higher than your average spending.',
        ),
        _buildSignalCard(
          icon: Icons.access_time_rounded,
          title: 'Login & Time Analysis',
          badgeText: 'Warning',
          badgeColor: const Color(0xFFFBE4C6),
          badgeTextColor: const Color(0xFFE58728),
          description: '2 transactions occurred outside your usual banking hours (11 PM - midnight).',
        ),
        _buildSignalCard(
          icon: Icons.phone_iphone_rounded,
          title: 'Device Trust',
          badgeText: 'New Device',
          badgeColor: const Color(0xFFFBE4C6),
          badgeTextColor: const Color(0xFFE58728),
          description: '1 new device detected this month. Trusted devices: 2.',
        ),
        _buildSignalCard(
          icon: Icons.location_on_outlined,
          title: 'Location Analysis',
          badgeText: 'Unfamiliar',
          badgeColor: const Color(0xFFFBE4C6),
          badgeTextColor: const Color(0xFFE58728),
          description: 'Transaction detected from an unfamiliar location (Bengaluru, IN). Familiar: 3 locations.',
        ),
        _buildSignalCard(
          icon: Icons.insights_rounded,
          title: 'Transaction Frequency',
          badgeText: 'Normal',
          badgeColor: kLightGreenBg,
          badgeTextColor: kMid,
          description: "Today's transaction count is within your normal pattern (4 of 8 avg).",
        ),
      ],
    );
  }

  Widget _buildSignalCard({
    required IconData icon,
    required String title,
    required String badgeText,
    required Color badgeColor,
    required Color badgeTextColor,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: badgeTextColor == kMid ? kLightGreenBg : const Color(0xFFFBE4C6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: badgeTextColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: kForest,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          color: badgeTextColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    color: kSub,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTimelineTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fraud Detection Timeline',
            style: TextStyle(
              color: kForest,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildTimelineItem(
            icon: Icons.phone_iphone_rounded,
            title: 'New device detected',
            time: 'Today, 9:14 AM',
            badgeText: 'Alert',
            badgeColor: const Color(0xFFFBE4C6),
            badgeTextColor: const Color(0xFFE58728),
            isLast: false,
          ),
          _buildTimelineItem(
            icon: Icons.show_chart_rounded,
            title: 'High-value transaction detected',
            time: 'Today, 9:22 AM',
            badgeText: 'Flagged',
            badgeColor: const Color(0xFFFFEBEE),
            badgeTextColor: const Color(0xFFE53935),
            isLast: false,
          ),
          _buildTimelineItem(
            icon: Icons.access_time_rounded,
            title: 'Unusual transaction time',
            time: 'Yesterday, 11:47 PM',
            badgeText: 'Warning',
            badgeColor: const Color(0xFFFBE4C6),
            badgeTextColor: const Color(0xFFE58728),
            isLast: false,
          ),
          _buildTimelineItem(
            icon: Icons.location_on_outlined,
            title: 'New location identified',
            time: 'Yesterday, 11:47 PM',
            badgeText: 'Alert',
            badgeColor: const Color(0xFFFBE4C6),
            badgeTextColor: const Color(0xFFE58728),
            isLast: false,
          ),
          _buildTimelineItem(
            icon: Icons.flash_on_rounded,
            title: 'Velocity monitoring alert',
            time: 'May 27, 3:05 PM',
            badgeText: 'Alert',
            badgeColor: const Color(0xFFFBE4C6),
            badgeTextColor: const Color(0xFFE58728),
            isLast: false,
          ),
          _buildTimelineItem(
            icon: Icons.sync_rounded,
            title: 'Re-authentication triggered',
            time: 'May 27, 3:06 PM',
            badgeText: 'Resolved',
            badgeColor: kLightGreenBg,
            badgeTextColor: kMid,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required String title,
    required String time,
    required String badgeText,
    required Color badgeColor,
    required Color badgeTextColor,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: badgeTextColor, size: 16),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1,
                    color: Colors.grey.withOpacity(0.3),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: kForest,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            color: badgeTextColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: const TextStyle(
                      color: kSub,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 60,
                    height: 2.5,
                    color: badgeTextColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
