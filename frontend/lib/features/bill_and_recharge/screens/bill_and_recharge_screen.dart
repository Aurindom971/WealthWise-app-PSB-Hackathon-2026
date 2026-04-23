import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:securewealth_twin/features/home/widgets/home_navigation_widgets.dart';
import '../models/bill_models.dart';

class BillAndRechargeScreen extends StatefulWidget {
  final VoidCallback onBack;
  final Function(UtilityProvider) onSelectUtility;
  final VoidCallback onViewAllUpcoming;
  final Function(Bill) onPayBill;

  const BillAndRechargeScreen({
    super.key,
    required this.onBack,
    required this.onSelectUtility,
    required this.onViewAllUpcoming,
    required this.onPayBill,
  });

  @override
  State<BillAndRechargeScreen> createState() => _BillAndRechargeScreenState();
}

class _BillAndRechargeScreenState extends State<BillAndRechargeScreen> {
  final List<UtilityProvider> _utilities = [
    const UtilityProvider(
      type: UtilityType.electricity,
      name: 'Electricity',
      icon: Icons.bolt_rounded,
      color: Color(0xFFF79E1B),
      bgColor: Color(0xFFFFF7E6),
    ),
    const UtilityProvider(
      type: UtilityType.water,
      name: 'Water',
      icon: Icons.water_drop_rounded,
      color: Color(0xFF2962FF),
      bgColor: Color(0xFFE3F2FD),
    ),
    const UtilityProvider(
      type: UtilityType.broadband,
      name: 'Broadband',
      icon: Icons.wifi_rounded,
      color: Color(0xFF7B1FA2),
      bgColor: Color(0xFFF3E5F5),
    ),
    const UtilityProvider(
      type: UtilityType.fastag,
      name: 'Fastag',
      icon: Icons.directions_car_rounded,
      color: Color(0xFFD84315),
      bgColor: Color(0xFFFBE9E7),
    ),
    const UtilityProvider(
      type: UtilityType.gas,
      name: 'Gas',
      icon: Icons.local_fire_department_rounded,
      color: Color(0xFFC2185B),
      bgColor: Color(0xFFFCE4EC),
    ),
    const UtilityProvider(
      type: UtilityType.mobile,
      name: 'Mobile',
      icon: Icons.smartphone_rounded,
      color: Color(0xFF2E7D32),
      bgColor: Color(0xFFE8F5E9),
    ),
  ];

  final List<Bill> _upcomingBills = [
    Bill(
      id: '1',
      providerName: 'Electricity',
      consumerId: '4821',
      amount: 2340,
      dueDate: DateTime.now().add(const Duration(days: 3)),
      type: UtilityType.electricity,
    ),
    Bill(
      id: '2',
      providerName: 'Broadband',
      consumerId: '9876',
      amount: 999,
      dueDate: DateTime.now().add(const Duration(days: 5)),
      type: UtilityType.broadband,
    ),
    Bill(
      id: '3',
      providerName: 'Water',
      consumerId: '1234',
      amount: 450,
      dueDate: DateTime.now().add(const Duration(days: 7)),
      type: UtilityType.water,
    ),
  ];

  final List<RecentPayment> _recentPayments = [
    RecentPayment(
      id: '101',
      title: 'Mobile Recharge',
      subtitle: '9876543210',
      amount: 599,
      date: DateTime.now().subtract(const Duration(days: 1)),
      type: UtilityType.mobile,
    ),
    RecentPayment(
      id: '102',
      title: 'Electricity Bill',
      subtitle: 'Consumer #4821',
      amount: 2120,
      date: DateTime.parse('2026-10-12'), // Mock date
      type: UtilityType.electricity,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Inherit from HomeScreen
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: widget.onBack,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: kCard,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: kForest,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Pay Bills',
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: kForest,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Utilities',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kForest,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Utilities Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.95,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = _utilities[index];
                return _UtilityCard(
                  provider: item,
                  onTap: () => widget.onSelectUtility(item),
                );
              }, childCount: _utilities.length),
            ),
          ),

          // Upcoming Bills Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Upcoming Bills',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kForest,
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onViewAllUpcoming,
                    child: Text(
                      'View All',
                      style: GoogleFonts.inter(
                        color: kAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _BillTile(
                  bill: _upcomingBills[index],
                  onPay: () => widget.onPayBill(_upcomingBills[index]),
                ),
                childCount: _upcomingBills.length,
              ),
            ),
          ),

          // Recent Payments Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Payments',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kForest,
                    ),
                  ),
                  TextButton(
                    onPressed: () {}, // TODO: See All
                    child: Text(
                      'See All',
                      style: GoogleFonts.inter(
                        color: kAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    _RecentPaymentTile(payment: _recentPayments[index]),
                childCount: _recentPayments.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

class _UtilityCard extends StatelessWidget {
  final UtilityProvider provider;
  final VoidCallback onTap;

  const _UtilityCard({required this.provider, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: provider.bgColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: provider.color.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(provider.icon, color: provider.color, size: 30),
            const SizedBox(height: 10),
            Text(
              provider.name,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kForest,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BillTile extends StatelessWidget {
  final Bill bill;
  final VoidCallback onPay;

  const _BillTile({required this.bill, required this.onPay});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bill.iconColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(bill.typeIcon, color: bill.iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bill.providerName,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: kForest,
                  ),
                ),
                Text(
                  bill.dueDescription,
                  style: GoogleFonts.inter(fontSize: 12, color: kSub),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${NumberFormat('#,##0').format(bill.amount)}',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: kForest,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1F5D3A), Color(0xFF2E7D5B)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ElevatedButton(
                  onPressed: onPay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Pay Now', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentPaymentTile extends StatelessWidget {
  final RecentPayment payment;

  const _RecentPaymentTile({required this.payment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kForest.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              payment.type == UtilityType.mobile
                  ? Icons.phone_android_rounded
                  : (payment.type == UtilityType.electricity
                        ? Icons.bolt_rounded
                        : Icons.receipt_long_rounded),
              color: kForest,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: kForest,
                  ),
                ),
                Text(
                  payment.subtitle,
                  style: GoogleFonts.inter(fontSize: 12, color: kSub),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${NumberFormat('#,##0').format(payment.amount)}',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: kForest,
                ),
              ),
              Text(
                payment.date.year == DateTime.now().year &&
                        payment.date.month == DateTime.now().month &&
                        payment.date.day ==
                            DateTime.now().subtract(const Duration(days: 1)).day
                    ? 'Yesterday'
                    : DateFormat('d MMM').format(payment.date),
                style: GoogleFonts.inter(fontSize: 11, color: kSub),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
