import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../home/widgets/home_navigation_widgets.dart';
import '../../home/screens/notifications_screen.dart';
import '../widgets/loan_header.dart';
import '../widgets/active_loan_card.dart';

class ActiveLoansScreen extends StatefulWidget {
  final VoidCallback onBack;
  final Function(String, String) onViewStatement;
  const ActiveLoansScreen({
    super.key,
    required this.onBack,
    required this.onViewStatement,
  });

  @override
  State<ActiveLoansScreen> createState() => _ActiveLoansScreenState();
}

class _ActiveLoansScreenState extends State<ActiveLoansScreen> {
  List<dynamic> _activeLoans = [];
  bool _isLoading = true;
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _fetchActiveLoans();
  }

  Future<void> _fetchActiveLoans() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Step 1: Lookup Customer ID from Email
      // Fetch active loans using User Email directly
      final response = await _supabase.rpc(
        'get_user_loans_dashboard',
        params: {'p_email': user.email},
      );

      if (response != null) {
        setState(() {
          _activeLoans = response['active_loans'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching active loans: $e");
      setState(() => _isLoading = false);
    }
  }

  String _formatCurrency(dynamic value) {
    final format = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return format.format(value ?? 0);
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('d MMM yyyy').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LoanHeader(
          title: 'Active Loans',
          subtitle: 'Review your status',
          icon: Icons.track_changes_rounded,
          onBack: widget.onBack,
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: kMid))
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: kMid.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: kMid.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: kMid,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'You have ${_activeLoans.length} ${_activeLoans.length == 1 ? 'loan' : 'loans'} currently active and being tracked.',
                                  style: TextStyle(
                                    color: kInk.withValues(alpha: 0.8),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Loans List
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Column(
                          children: [
                            if (_activeLoans.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: Center(
                                  child: Text(
                                    'No active loans found',
                                    style: TextStyle(color: kSub),
                                  ),
                                ),
                              )
                            else
                              ..._activeLoans.map((loan) {
                                final rawType =
                                    loan['loan_type']?.toString() ?? 'loan';
                                final type = rawType.isNotEmpty
                                    ? "${rawType[0].toUpperCase()}${rawType.substring(1)} Loan"
                                    : "Loan";
                                final paid = loan['emis_paid'] ?? 0;
                                final total = loan['total_emis'] ?? 1;
                                final progress = (paid / total).toDouble();

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: ActiveLoanCard(
                                    type: type,
                                    loanId: loan['loan_id'] ?? 'N/A',
                                    principal: _formatCurrency(
                                      loan['principal_amount'],
                                    ),
                                    outstanding: _formatCurrency(
                                      loan['outstanding_amount'],
                                    ),
                                    emi: _formatCurrency(loan['emi_amount']),
                                    nextDue: _formatDate(
                                      loan['next_due_date'] ?? '',
                                    ),
                                    paidText: '$paid of $total EMIs paid',
                                    progress: progress,
                                    onViewStatement: () =>
                                        widget.onViewStatement(
                                          type,
                                          loan['loan_id'] ?? '',
                                        ),
                                  ),
                                );
                              }),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
