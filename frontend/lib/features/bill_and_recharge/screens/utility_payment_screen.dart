import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:wealthwise/features/home/widgets/home_navigation_widgets.dart';
import '../models/bill_models.dart';
import '../../../services/security_service.dart';

class UtilityPaymentScreen extends StatefulWidget {
  final UtilityProvider provider;
  final VoidCallback onBack;
  final Function(Bill)? onBillFetched;
  final Function(Bill) onProceedToPay;

  const UtilityPaymentScreen({
    super.key,
    required this.provider,
    required this.onBack,
    this.onBillFetched,
    required this.onProceedToPay,
  });

  @override
  State<UtilityPaymentScreen> createState() => _UtilityPaymentScreenState();
}

class _UtilityPaymentScreenState extends State<UtilityPaymentScreen> {
  final TextEditingController _idController = TextEditingController();
  bool _isFetching = false;
  Bill? _fetchedBill;

  void _fetchBill() async {
    if (_idController.text.isEmpty) return;

    setState(() {
      _isFetching = true;
      _fetchedBill = null;
    });

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    final bill = Bill(
      id: '999',
      providerName: widget.provider.name,
      consumerId: _idController.text,
      amount: 2340.0, // Mock amount
      dueDate: DateTime.now().add(const Duration(days: 4)),
      type: widget.provider.type,
    );

    setState(() {
      _isFetching = false;
      _fetchedBill = bill;
    });

    if (widget.onBillFetched != null) {
      widget.onBillFetched!(bill);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = widget.provider.type == UtilityType.mobile;
    final label = isMobile ? 'Mobile Number' : 'Consumer Number';
    final hint = isMobile ? 'Enter mobile number' : 'Enter consumer number';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
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
                      )
                    ],
                  ),
                  child: const Icon(Icons.arrow_back_rounded, color: kForest, size: 20),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                widget.provider.name,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: kForest,
                ),
              ),
            ],
          ),
            const SizedBox(height: 20),
            // Provider Info
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: widget.provider.bgColor,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Icon(widget.provider.icon, color: widget.provider.color, size: 64),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Pay your ${widget.provider.name.toLowerCase()} bill quickly',
                    style: GoogleFonts.inter(color: kSub, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Input Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isMobile) ...[
                    Text(
                      'Select Operator',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: kForest),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: kCream.withValues(alpha: 0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      hint: Text('Select Operator', style: TextStyle(color: kSub.withValues(alpha: 0.5))),
                      items: ['Airtel', 'Jio', 'Vi', 'BSNL']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) {},
                    ),
                    const SizedBox(height: 20),
                  ],
                  Text(
                    label,
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: kForest),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _idController,
                          keyboardType: isMobile ? TextInputType.phone : TextInputType.text,
                          decoration: InputDecoration(
                            hintText: hint,
                            hintStyle: TextStyle(color: kSub.withValues(alpha: 0.5)),
                            filled: true,
                            fillColor: kCream.withValues(alpha: 0.5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: _isFetching ? null : _fetchBill,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: kAccent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: _isFetching
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Icon(Icons.search_rounded, color: Colors.white, size: 24),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Bill Details
            if (_fetchedBill != null)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: kCard,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: kAccent.withValues(alpha: 0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bill Details',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: kForest),
                    ),
                    const SizedBox(height: 20),
                    _detailRow('Consumer ID', _fetchedBill!.consumerId),
                    const SizedBox(height: 12),
                    _detailRow('Bill Period', DateFormat('MMM yyyy').format(_fetchedBill!.dueDate)),
                    const SizedBox(height: 12),
                    _detailRow('Due Date', DateFormat('d MMM yyyy').format(_fetchedBill!.dueDate)),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Divider(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Amount',
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: kForest),
                        ),
                        Text(
                          '₹${NumberFormat('#,##0').format(_fetchedBill!.amount)}',
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18, color: kAccent),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!await SecurityService.canPerformTransaction()) {
                            _showSecurityLockToast(context);
                            return;
                          }
                          widget.onProceedToPay(_fetchedBill!);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: Text(
                          'Pay ₹${NumberFormat('#,##0').format(_fetchedBill!.amount)}',
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(color: kSub, fontSize: 14)),
        Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: kForest, fontSize: 14)),
      ],
    );
  }

  void _showSecurityLockToast(BuildContext context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Account Locked: Night Lock or Global Freeze is active.'),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

