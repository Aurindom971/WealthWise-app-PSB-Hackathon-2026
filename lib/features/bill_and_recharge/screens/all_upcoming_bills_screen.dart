import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:securewealth_twin/features/home/widgets/home_navigation_widgets.dart';
import '../models/bill_models.dart';

class AllUpcomingBillsScreen extends StatelessWidget {
  final VoidCallback onBack;
  final Function(Bill) onPayBill;

  const AllUpcomingBillsScreen({
    super.key,
    required this.onBack,
    required this.onPayBill,
  });

  @override
  Widget build(BuildContext context) {
    final List<Bill> bills = [
      Bill(
          id: '1',
          providerName: 'Electricity',
          consumerId: '4821',
          amount: 2340,
          dueDate: DateTime.now().add(const Duration(days: 3)),
          type: UtilityType.electricity),
      Bill(
          id: '2',
          providerName: 'Broadband',
          consumerId: '9876',
          amount: 999,
          dueDate: DateTime.now().add(const Duration(days: 5)),
          type: UtilityType.broadband),
      Bill(
          id: '3',
          providerName: 'Water',
          consumerId: '1234',
          amount: 450,
          dueDate: DateTime.now().add(const Duration(days: 7)),
          type: UtilityType.water),
      Bill(
          id: '4',
          providerName: 'Gas',
          consumerId: 'G-7781',
          amount: 1120,
          dueDate: DateTime.now().add(const Duration(days: 12)),
          type: UtilityType.gas),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onBack,
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
                        )
                      ],
                    ),
                    child: const Icon(Icons.arrow_back_rounded, color: kForest, size: 20),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Upcoming Bills',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: kForest,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: bills.length,
              itemBuilder: (context, index) {
                final bill = bills[index];
                return _FullBillTile(bill: bill, onPay: () => onPayBill(bill));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FullBillTile extends StatelessWidget {
  final Bill bill;
  final VoidCallback onPay;

  const _FullBillTile({required this.bill, required this.onPay});

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
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: bill.iconColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  bill.typeIcon,
                  color: bill.iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bill.providerName,
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: kForest),
                    ),
                    Text(
                      'Consumer ID: ${bill.consumerId}',
                      style: GoogleFonts.inter(fontSize: 12, color: kSub),
                    ),
                  ],
                ),
              ),
              Text(
                '₹${NumberFormat('#,##0').format(bill.amount)}',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18, color: kForest),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_month_rounded, size: 16, color: kSub),
                  const SizedBox(width: 8),
                  Text(
                    bill.dueDescription,
                    style: GoogleFonts.inter(fontSize: 13, color: kSub, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: onPay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Pay Now', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

