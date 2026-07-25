import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/action_button.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/forex_modal.dart';
import '../widgets/settings_modal.dart';
import '../widgets/statement_modal.dart';
import '../widgets/animated_card_stack.dart';
import '../widgets/payment_cards.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../services/security_service.dart';
import '../../../providers/auth_provider.dart';
import 'package:intl/intl.dart';

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
  bool _isLoading = true;
  bool _isNightLocked = false;
  List<Map<String, dynamic>> _cards = [];
  List<Map<String, dynamic>> _cardTransactions = [];

  @override
  void initState() {
    super.initState();
    _fetchCards();
    _checkNightLock();
  }

  Future<void> _checkNightLock() async {
    final canTransact = await SecurityService.canPerformTransaction();
    if (mounted) {
      setState(() => _isNightLocked = !canTransact);
    }
  }

  Future<void> _fetchCards() async {
    try {
      final supabase = Supabase.instance.client;
      final userEmail = AuthProvider.instance.currentUser?['email'] ?? supabase.auth.currentUser?.email;
      if (userEmail == null || userEmail.toString().isEmpty) return;

      final response = await supabase.rpc('get_cards_data', params: {
        'user_email': userEmail,
      });

      if (response != null && response['cards'] != null) {
        setState(() {
          _cards = List<Map<String, dynamic>>.from(response['cards']);
          _isLoading = false;
        });

        if (_cards.isNotEmpty) {
          _fetchTransactions(
            _cards[_activeCardIndex]['card_id'],
            _cards[_activeCardIndex]['cus_id'] ?? '',
          );
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error fetching cards: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchTransactions(dynamic cardId, String cusId) async {
    try {
      final supabase = Supabase.instance.client;
      
      final response = await supabase.rpc('get_card_transactions', params: {
        'p_cus_id': cusId,
        'p_card_id': cardId,
      });

      if (response != null) {
        final txs = response is Map ? response['transactions'] : response;
        if (txs != null && txs is List) {
          setState(() {
            _cardTransactions = List<Map<String, dynamic>>.from(txs);
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
    }
  }

  Future<void> _toggleFreezeStatus(dynamic cardId, bool currentStatus) async {
    // SECURITY CHECK: Global Lock / Night Lock
    if (!await SecurityService.canPerformTransaction()) {
      _showSecurityLockToast();
      return;
    }

    try {
      final supabase = Supabase.instance.client;
      await supabase.rpc('toggle_freeze_card', params: {
        'p_card_id': cardId,
        'p_freeze_status': !currentStatus,
      });
      // Refresh cards list to update UI
      await _fetchCards();
    } catch (e) {
      debugPrint('Error toggling freeze: $e');
    }
  }

  String _formatCurrency(dynamic amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );
    return formatter.format(amount ?? 0);
  }

  String _formatTransactionAmount(dynamic amount, bool isPositive) {
    final absAmount = (amount is num) ? amount.abs() : 0;
    return '${isPositive ? '+' : '-'}${_formatCurrency(absAmount)}';
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      return DateFormat('dd MMM').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  void _toggleObscure() {
    setState(() => _obscureBalances = !_obscureBalances);
  }

  void _showFreezeWarning() {
    if (_cards.isEmpty) return;
    final currentCard = _cards[_activeCardIndex];
    final bool isFrozen = currentCard['is_frozen'] ?? false;
    final String cardType = currentCard['card_type'].toString().toUpperCase();
    final String last4 = currentCard['masked_number'].split(' ').last;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(isFrozen ? Icons.info_outline : Icons.warning_amber_rounded, 
                 color: isFrozen ? const Color(0xFF2E7D5B) : Colors.red, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${isFrozen ? 'Unfreeze' : 'Freeze'} $cardType',
                style: GoogleFonts.inter(
                  color: isFrozen ? const Color(0xFF2E7D5B) : Colors.red, 
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            isFrozen 
              ? 'Are you sure you want to unfreeze your card ending in $last4? This will re-enable all domestic and international transactions.'
              : 'Are you sure you want to freeze your card ending in $last4? This will disable all domestic and international transactions for this account.',
            style: GoogleFonts.inter(color: Colors.grey.shade700, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _toggleFreezeStatus(currentCard['card_id'], isFrozen);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isFrozen ? const Color(0xFF2E7D5B) : Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(isFrozen ? 'Unfreeze Now' : 'Freeze Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define Debit and Credit cards
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D5B)));
    }

    if (_cards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.credit_card_off_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('No active cards found', style: GoogleFonts.inter(color: Colors.grey)),
          ],
        ),
      );
    }

    final List<Widget> myCards = _cards.asMap().entries.map((entry) {
      final idx = entry.key;
      final card = entry.value;
      final isCredit = card['card_type'] == 'credit';
      
      return PaymentCard(
        type: card['card_type'].toString().toUpperCase(),
        number: card['masked_number'],
        balance: _formatCurrency(card['balance']),
        holder: 'RAJESH KUMAR',
        gradient: isCredit 
            ? [const Color(0xFF1F5D3A), const Color(0xFF2E7D5B)]
            : [const Color(0xFF1E3A5F), const Color(0xFF3B5998)],
        obscured: _obscureBalances,
        onToggle: _toggleObscure,
        index: idx,
        total: _cards.length,
        network: card['card_network'] ?? 'VISA',
        balanceLabel: isCredit ? 'CREDIT LIMIT' : 'AVAILABLE BALANCE',
        isFrozen: (card['is_frozen'] ?? false) || _isNightLocked,
      );
    }).toList();

    final currentCard = _cards[_activeCardIndex];
    final bool isFrozen = (currentCard['is_frozen'] ?? false) || _isNightLocked;
    final List<Map<String, dynamic>> displayTransactions = _showAllTransactions 
        ? _cardTransactions 
        : _cardTransactions.take(3).toList();

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
                onCardChanged: (index) {
                  setState(() => _activeCardIndex = index);
                  _fetchTransactions(
                    _cards[index]['card_id'],
                    _cards[index]['cus_id'] ?? '',
                  );
                },
              ),
              
              const SizedBox(height: 32),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.showFreezeCard)
                    FeatureActionButton(
                      icon: isFrozen ? Icons.lock_open_rounded : Icons.ac_unit_rounded,
                      label: isFrozen ? 'Unfreeze' : 'Freeze Card',
                      backgroundColor: isFrozen ? const Color(0xFFE3F2FD) : const Color(0xFFDCF0E5),
                      iconColor: isFrozen ? Colors.blue.shade700 : const Color(0xFF1F5D3A),
                      onTap: _showFreezeWarning,
                      isHighlighted: widget.highlightAction == 'Block',
                    ),
                  FeatureActionButton(
                    icon: Icons.description_outlined,
                    label: 'Statement',
                    onTap: () {
                      if (_cards.isNotEmpty) {
                        final card = _cards[_activeCardIndex];
                        _showModal(
                          context, 
                          StatementModal(
                            cardId: card['card_id'],
                            accountId: card['account_id'],
                            cusId: card['cus_id'] ?? '',
                            last4: card['masked_number'].split(' ').last,
                            cardType: card['card_type'],
                          ),
                        );
                      }
                    },
                    isHighlighted: widget.highlightAction == 'Statement',
                  ),
                  FeatureActionButton(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    onTap: () async {
                      if (!await SecurityService.canPerformTransaction()) {
                        _showSecurityLockToast();
                        return;
                      }
                      if (_cards.isNotEmpty) {
                        final card = _cards[_activeCardIndex];
                        _showModal(
                          context, 
                          SettingsModal(
                            cardId: card['card_id'],
                            last4: card['masked_number'].split(' ').last,
                            initialDomestic: !(card['international_enabled'] ?? false),
                            initialDomesticEnabled: card['domestic_enabled'] ?? true,
                            initialInternationalEnabled: card['international_enabled'] ?? false,
                            initialAtm: (card['atm_limit'] ?? 25000).toDouble() / 100000.0,
                            initialMerchant: (card['merchant_limit'] ?? 100000).toDouble() / 500000.0,
                            initialTap: (card['contactless_limit'] ?? 5000).toDouble() / 15000.0,
                            initialOnline: (card['online_limit'] ?? 200000).toDouble() / 500000.0,
                            onSaved: _fetchCards,
                          ), 
                          isScrollControlled: true
                        );
                      }
                    },
                    isHighlighted: widget.highlightAction == 'Limits',
                  ),
                  FeatureActionButton(
                    icon: Icons.swap_horiz_rounded,
                    label: 'Forex',
                    onTap: () async {
                      if (!await SecurityService.canPerformTransaction()) {
                        _showSecurityLockToast();
                        return;
                      }
                      _showModal(context, const ForexModal());
                    },
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
                        color: const Color(0xFF2E7D5B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              if (isFrozen)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.lock_rounded, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'This card is frozen',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Transactions are temporarily disabled. Unfreeze the card to see latest activity.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...displayTransactions.map((tx) {
                  final amount = double.tryParse(tx['amount'].toString()) ?? 0.0;
                  final isPositive = amount > 0;
                  return TransactionTile(
                    icon: isPositive ? Icons.arrow_forward_rounded : Icons.shopping_bag_outlined,
                    title: tx['counterparty_name'] ?? 'Transfer',
                    subtitle: '${tx['category'] ?? 'General'} · ${_formatDate(tx['created_at'])}',
                    amount: _formatTransactionAmount(amount, isPositive),
                    isCompleted: true,
                    isPositive: isPositive,
                  );
                }),
              
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
  void _showSecurityLockToast() {
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
