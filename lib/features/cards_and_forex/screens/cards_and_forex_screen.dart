import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/action_button.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/forex_modal.dart';
import '../widgets/settings_modal.dart';
import '../widgets/statement_modal.dart';
import '../widgets/animated_card_stack.dart';
import '../widgets/payment_cards.dart';

class CardsAndForexScreen extends StatefulWidget {
  final bool showFreezeCard;
  final VoidCallback? onBack;

  const CardsAndForexScreen({
    super.key,
    this.showFreezeCard = true,
    this.onBack,
    this.highlightAction,
  });

  final String? highlightAction;

  @override
  State<CardsAndForexScreen> createState() => _CardsAndForexScreenState();
}

class _CardsAndForexScreenState extends State<CardsAndForexScreen> {
  bool _obscureBalances = true;
  int _activeCardIndex = 0;
  bool _showAllTransactions = false;

  final List<Map<String, dynamic>> _creditTransactions = [
    {'title': 'Grocery Store', 'amount': '-₹1,240.20', 'positive': false, 'sub': 'Shopping · 10 Apr'},
    {'title': 'Netflix Subscription', 'amount': '-₹499.00', 'positive': false, 'sub': 'Entertainment · 09 Apr'},
    {'title': 'Interest Credit', 'amount': '+₹42.50', 'positive': true, 'sub': 'Credit · 08 Apr'},
    {'title': 'Apple Store', 'amount': '-₹15,000.00', 'positive': false, 'sub': 'Gadgets · 05 Apr'},
  ];

  final List<Map<String, dynamic>> _debitTransactions = [
    {'title': 'ATM Withdrawal', 'amount': '-₹5,000.00', 'positive': false, 'sub': 'Cash · 10 Apr'},
    {'title': 'Zomato Order', 'amount': '-₹840.50', 'positive': false, 'sub': 'Food · 09 Apr'},
    {'title': 'Salary Credit', 'amount': '+₹85,000.00', 'positive': true, 'sub': 'Income · 01 Apr'},
    {'title': 'Electricity Bill', 'amount': '-₹2,400.00', 'positive': false, 'sub': 'Utilities · 28 Mar'},
  ];

  void _toggleObscure() {
    setState(() => _obscureBalances = !_obscureBalances);
  }

  void _showFreezeWarning() {
    String cardType = _activeCardIndex == 0 ? 'CREDIT CARD' : 'DEBIT CARD';
    String last4 = _activeCardIndex == 0 ? '4821' : '1234';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Freeze $cardType',
                style: GoogleFonts.inter(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            'Are you sure you want to freeze your card ending in $last4? This will disable all domestic and international transactions for this account.',
            style: GoogleFonts.inter(color: Colors.grey.shade700, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Freeze Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define Debit and Credit cards
    final List<Widget> myCards = [
      PaymentCard(
        type: 'CREDIT CARD',
        number: '•••• •••• •••• 4821',
        balance: '₹2,45,580.00',
        holder: 'ALEX MORGAN',
        gradient: const [Color(0xFF38B27C), Color(0xFF2D8B61)],
        obscured: _obscureBalances,
        onToggle: _toggleObscure,
        index: 0,
        total: 2,
      ),
      PaymentCard(
        type: 'DEBIT CARD',
        number: '•••• •••• •••• 1234',
        balance: '₹48,200.00',
        holder: 'ALEX MORGAN',
        gradient: const [Color(0xFF1E3A5F), Color(0xFF3B5998)],
        obscured: _obscureBalances,
        onToggle: _toggleObscure,
        index: 1,
        total: 2,
      ),
    ];

    final List<Map<String, dynamic>> currentTransactions = _activeCardIndex == 0 ? _creditTransactions : _debitTransactions;
    final List<Map<String, dynamic>> displayTransactions = _showAllTransactions ? currentTransactions : currentTransactions.take(3).toList();

    return CustomScrollView(
      physics: const ClampingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 24.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 10),
              
              // Animated Card Stack
              AnimatedCardStack(
                cards: myCards,
                maxCardHeight: 210.0,
                onCardChanged: (index) => setState(() => _activeCardIndex = index),
              ),
              
              const SizedBox(height: 32),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.showFreezeCard)
                    FeatureActionButton(
                      icon: Icons.ac_unit_rounded,
                      label: 'Freeze Card',
                      onTap: _showFreezeWarning,
                      isHighlighted: widget.highlightAction == 'Block',
                    ),
                  FeatureActionButton(
                    icon: Icons.description_outlined,
                    label: 'Statement',
                    onTap: () => _showModal(context, const StatementModal()),
                    isHighlighted: widget.highlightAction == 'Statement',
                  ),
                  FeatureActionButton(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    onTap: () => _showModal(context, const SettingsModal(), isScrollControlled: true),
                    isHighlighted: widget.highlightAction == 'Limits',
                  ),
                  FeatureActionButton(
                    icon: Icons.swap_horiz_rounded,
                    label: 'Forex',
                    onTap: () => _showModal(context, const ForexModal()),
                    isHighlighted: widget.highlightAction == 'Forex',
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Latest Transactions',
                    style: GoogleFonts.inter(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _showAllTransactions = !_showAllTransactions),
                    child: Text(
                      _showAllTransactions ? 'Show Less' : 'See All',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF2ECC71),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              ...displayTransactions.map((tx) => TransactionTile(
                icon: tx['positive'] ? Icons.arrow_forward_rounded : Icons.shopping_bag_outlined,
                title: tx['title'],
                subtitle: tx['sub'],
                amount: tx['amount'],
                isCompleted: true,
                isPositive: tx['positive'],
              )),
              const SizedBox(height: 40),
            ]),
          ),
        ),
      ],
    );
  }

  void _showModal(BuildContext context, Widget modal, {bool isScrollControlled = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      builder: (context) => modal,
    );
  }
}
