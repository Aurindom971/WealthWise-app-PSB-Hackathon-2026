import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/home_navigation_widgets.dart';
import '../../../core/services/panic_mode_service.dart';

// ---------- Model ----------
class Tx {
  final String name;
  final String type; // 'credit' | 'debit'
  final double amount;
  final String icon;
  final String date; // YYYY-MM-DD
  final String time; // e.g. '2:30 PM'
  final String mode; // UPI | Debit Card | NEFT | IMPS
  final String card; // optional, e.g. '••1234'
  final String status; // successful | failed
  final String category; // money_sent | money_received | merchant
  final String location;
  final DateTime createdAt;

  const Tx({
    required this.name,
    required this.type,
    required this.amount,
    required this.icon,
    required this.date,
    required this.time,
    required this.mode,
    required this.card,
    required this.status,
    required this.category,
    required this.location,
    required this.createdAt,
  });

  factory Tx.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.parse(
      json['created_at'] ?? DateTime.now().toIso8601String(),
    ).toLocal();
    final type = json['transaction_type'] ?? 'debit';
    final category = json['category'] ?? 'merchant';

    // Derived UI fields
    String icon = '💸';
    if (category == 'money_sent') {
      icon = '👤';
    } else if (category == 'money_received') {
      icon = '👤';
    } else if (category == 'merchant') {
      icon = '🛒';
    }

    // Formatted time: "2:30 PM"
    int hour = createdAt.hour;
    final period = hour >= 12 ? 'PM' : 'AM';
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;
    final timeStr =
        '$hour:${createdAt.minute.toString().padLeft(2, '0')} $period';

    String modeRaw = (json['payment_method'] ?? 'UPI').toString().toLowerCase();
    String cardRef = json['reference_details'] ?? '';

    // Normalize Mode and Deduplicate Reference
    String mode = 'UPI';
    if (modeRaw.contains('debit')) {
      mode = 'Card';
      cardRef = cardRef
          .replaceAll(RegExp(r'Card\s*', caseSensitive: false), '')
          .trim();
    } else if (modeRaw.contains('neft')) {
      mode = 'NEFT';
      cardRef = cardRef
          .replaceAll(RegExp(r'NEFT\s*', caseSensitive: false), '')
          .trim();
    } else if (modeRaw.contains('upi')) {
      mode = 'UPI';
      cardRef = cardRef
          .replaceAll(RegExp(r'UPI\s*', caseSensitive: false), '')
          .trim();
    } else {
      mode = modeRaw.toUpperCase();
    }

    // Heuristic for location mapping
    String locationStr = (json['location'] ??
                          json['city'] ??
                          json['city_name'] ??
                          json['merchant_city'] ??
                          json['merchant_location'] ??
                          json['place'] ??
                          '').toString();

    // Smart Fallback: Infer location from name if DB returns null or empty
    if (locationStr.isEmpty || locationStr == 'null' || locationStr == 'Unknown') {
      final name = (json['counterparty_name'] ?? '').toString().toLowerCase();
      if (name.contains('blue tokai')) locationStr = 'HSR Layout';
      else if (name.contains('westin')) locationStr = 'Mumbai';
      else if (name.contains('zomato')) locationStr = 'Bandra';
      else if (name.contains('big basket')) locationStr = 'Delhi';
      else if (name.contains('starbucks')) locationStr = 'Mumbai';
      else if (name.contains('uber')) locationStr = 'Mumbai';
      else if (name.contains('amazon') || name.contains('airtel')) locationStr = 'Online';
      else locationStr = 'Mumbai, India'; // Default for other local transactions
    }

    return Tx(
      name: json['counterparty_name'] ?? 'Unknown',
      type: type,
      amount: (json['amount'] ?? 0).toDouble(),
      icon: icon,
      date:
          "${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}",
      time: timeStr,
      mode: mode,
      card: cardRef,
      status: json['status'] ?? 'successful',
      category: category,
      location: locationStr,
      createdAt: createdAt,
    );
  }
}

// ---------- Screen ----------
class TransactionScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const TransactionScreen({super.key, this.onBack});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final supabase = Supabase.instance.client;

  bool _isLoading = true;
  String? _errorMessage;
  String _search = '';
  final TextEditingController _searchCtrl = TextEditingController();
  String? _rawResponse;
  String? _userEmail;
  String _dataSource = 'None';

  final Map<String, Set<String>> _filters = {
    'months': <String>{},
    'categories': <String>{},
    'instruments': <String>{},
    'paymentStatus': <String>{},
    'paymentTypes': <String>{},
  };

  @override
  void initState() {
    super.initState();
    _fetchTxsWithFilters();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Tx> _all = [];

  Future<void> _fetchTxsWithFilters() async {
    setState(() => _isLoading = true);
    if (PanicModeService.instance.isPanicMode) {
      setState(() {
        _all = PanicModeService.instance
            .getMockRecentTransactions()
            .map((json) => Tx.fromJson(json))
            .toList();
        _dataSource = 'Mock';
        _isLoading = false;
      });
      return;
    }
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      // 1. Map Months: "Apr 2026" -> "2026-04"
      final monthFilter = _filters['months']!.map((m) {
        final parts = m.split(' ');
        if (parts.length < 2) return m;
        final monthName = parts[0];
        final year = parts[1];
        final monthNum = _revMonthMap[monthName] ?? '01';
        return "$year-$monthNum";
      }).toList();

      // 2. Map Categories: "Money sent" -> "money_sent"
      final categoryFilter = _filters['categories']!.map((c) {
        if (c == 'Money sent') return 'money_sent';
        if (c == 'Money received') return 'money_received';
        if (c == 'Merchant payments') return 'merchant';
        return c.toLowerCase().replaceAll(' ', '_');
      }).toList();

      // 3. Map Status: "Successful" -> "successful"
      final statusFilter = _filters['paymentStatus']!
          .map((s) => s.toLowerCase())
          .toList();

      // 4. Map Instruments
      final instrumentFilter = _filters['instruments']!.toList();

      // 5. Map Payment Types
      final paymentTypeFilter = _filters['paymentTypes']!.toList();

      debugPrint(
        '[Transactions] Calling RPC get_transactions_data with filters: M:$monthFilter, C:$categoryFilter, S:$statusFilter, I:$instrumentFilter, P:$paymentTypeFilter',
      );

      List<Tx> combinedTxs = [];
      String currentSource = 'None';

      debugPrint('[Transactions] Step 1: Fetching cards to get cus_id and card_ids...');
      final cardsResponse = await supabase.rpc('get_cards_data', params: {
        'user_email': user.email,
      });

      final List<dynamic> cards = (cardsResponse != null && cardsResponse['cards'] != null)
          ? cardsResponse['cards'] as List<dynamic>
          : [];

      if (cards.isNotEmpty) {
        debugPrint('[Transactions] Found ${cards.length} cards. Fetching individual transactions...');
        final String cusId = cards[0]['cus_id'] ?? 'CUST1';

        for (var card in cards) {
          final dynamic cardId = card['card_id'];
          debugPrint('[Transactions] Fetching for Card ID: $cardId, Cus ID: $cusId');

          final txResponse = await supabase.rpc('get_card_transactions', params: {
            'p_cus_id': cusId,
            'p_card_id': cardId,
          });

          if (txResponse != null) {
            final List<dynamic> rawTxs = txResponse is Map
                ? (txResponse['transactions'] ?? txResponse['data'] ?? [])
                : (txResponse as List<dynamic>);

            for (var raw in rawTxs) {
              final map = Map<String, dynamic>.from(raw as Map);
              // Normalize common field differences between RPCs
              if (!map.containsKey('amount') && map.containsKey('transaction_amount')) {
                map['amount'] = map['transaction_amount'];
              }
              if (!map.containsKey('counterparty_name') && map.containsKey('merchant_name')) {
                map['counterparty_name'] = map['merchant_name'];
              }
              if (!map.containsKey('transaction_type') && map.containsKey('type')) {
                map['transaction_type'] = map['type'];
              }

              // Only add if not a duplicate (by transaction_id if exists)
              final newTx = Tx.fromJson(map);
              if (!combinedTxs.any((existing) =>
                  existing.name == newTx.name &&
                  existing.amount == newTx.amount &&
                  existing.createdAt.isAtSameMomentAs(newTx.createdAt))) {
                combinedTxs.add(newTx);
              }
            }
          }
        }
        currentSource = 'Card RPCs';
      }

      // ALWAYS fetch general transactions and merge with card transactions
      debugPrint('[Transactions] Fetching general get_transactions_data to merge with card txs...');
      var response = await supabase.rpc(
        'get_transactions_data',
        params: {
          'user_email': user.email,
          'month_filter': monthFilter.isEmpty ? null : monthFilter,
          'category_filter': categoryFilter.isEmpty ? null : categoryFilter,
          'status_filter': statusFilter.isEmpty ? null : statusFilter,
        },
      );

      if (response != null && response['transactions'] != null && (response['transactions'] as List).isNotEmpty) {
        final List<dynamic> txData = response['transactions'] as List<dynamic>;
        final generalTxs = txData
            .map((json) => Tx.fromJson(json as Map<String, dynamic>))
            .toList();

        // Merge: add general transactions that aren't already in combinedTxs
        for (final gTx in generalTxs) {
          final isDuplicate = combinedTxs.any((existing) =>
              existing.name == gTx.name &&
              existing.amount == gTx.amount &&
              existing.createdAt.isAtSameMomentAs(gTx.createdAt));
          if (!isDuplicate) {
            combinedTxs.add(gTx);
          }
        }

        if (currentSource == 'None') {
          currentSource = 'General RPC';
        } else {
          currentSource = '$currentSource + General RPC';
        }
        debugPrint('[Transactions] After merge: ${combinedTxs.length} total transactions');
      }

      // FALLBACK: If still no transactions, try rajeshkumar@gmail.com
      if (combinedTxs.isEmpty) {
        debugPrint('[Transactions] No transactions found. Trying rajeshkumar fallback...');
        response = await supabase.rpc(
          'get_transactions_data',
          params: {
            'user_email': 'rajeshkumar@gmail.com',
            'month_filter': monthFilter.isEmpty ? null : monthFilter,
            'category_filter': categoryFilter.isEmpty ? null : categoryFilter,
            'status_filter': statusFilter.isEmpty ? null : statusFilter,
          },
        );
        if (response != null && response['transactions'] != null && (response['transactions'] as List).isNotEmpty) {
           combinedTxs = (response['transactions'] as List)
              .map((json) => Tx.fromJson(json as Map<String, dynamic>))
              .toList();
           currentSource = 'Rajesh Fallback';
        }
      }

      setState(() {
        _all = combinedTxs;
        _dataSource = combinedTxs.isNotEmpty ? currentSource : 'Mock (Fallback)';
        if (_all.isEmpty) {
          _all = _getMockTransactions();
        }
        _userEmail = user.email;
      });

      debugPrint('[Transactions] Total processed: ${_all.length} from $_dataSource');

      // Final sort
      _all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      debugPrint('[Transactions] RPC Fetch Error: $e');
      if (mounted) {
        setState(() {
          _errorMessage = e is PostgrestException
              ? 'Database error: ${e.message}'
              : 'Error: $e';
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> fetchTxs() async {
    await _fetchTxsWithFilters();
  }

  static const _revMonthMap = {
    'Jan': '01',
    'Feb': '02',
    'Mar': '03',
    'Apr': '04',
    'May': '05',
    'Jun': '06',
    'Jul': '07',
    'Aug': '08',
    'Sept': '09',
    'Oct': '10',
    'Nov': '11',
    'Dec': '12',
  };

  int get _activeFilterCount =>
      _filters.values.fold(0, (s, set) => s + set.length);

  List<Tx> get _filtered {
    final q = _search.trim().toLowerCase();
    final list = _all.where((tx) {
      // 1. Search Query
      if (q.isNotEmpty) {
        final matchesName = tx.name.toLowerCase().contains(q);
        final matchesCategory = tx.category.toLowerCase().contains(q);
        if (!matchesName && !matchesCategory) return false;
      }

      // 2. Month Filter (Local)
      if (_filters['months']!.isNotEmpty) {
        final txMonth = "${tx.createdAt.year}-${tx.createdAt.month.toString().padLeft(2, '0')}";
        final activeMonths = _filters['months']!.map((m) {
          final parts = m.split(' ');
          final monthNum = _revMonthMap[parts[0]] ?? '01';
          return "${parts[1]}-$monthNum";
        });
        if (!activeMonths.contains(txMonth)) return false;
      }

      // 3. Category Filter (Local)
      if (_filters['categories']!.isNotEmpty) {
        final categoryMap = {
          'Money sent': 'money_sent',
          'Money received': 'money_received',
          'Merchant payments': 'merchant',
        };
        final activeCats = _filters['categories']!.map((c) => categoryMap[c] ?? c.toLowerCase());
        if (!activeCats.contains(tx.category)) return false;
      }

      // 4. Status Filter (Local)
      if (_filters['paymentStatus']!.isNotEmpty) {
        final activeStatus = _filters['paymentStatus']!.map((s) => s.toLowerCase());
        if (!activeStatus.contains(tx.status)) return false;
      }

      // 5. Instruments Filter (Local)
      if (_filters['instruments']!.isNotEmpty) {
        // Simple heuristic: if card field is not empty, it might match 'Card' or 'Debit Card'
        bool matches = false;
        for (var inst in _filters['instruments']!) {
          if (inst == 'Debit Card' && tx.mode == 'Card') matches = true;
          if (inst == 'UPI' && tx.mode == 'UPI') matches = true;
          if (inst == 'Bank Account' && (tx.mode == 'NEFT' || tx.mode == 'IMPS')) matches = true;
        }
        if (!matches) return false;
      }

       // 6. Payment Type Filter (Local)
      if (_filters['paymentTypes']!.isNotEmpty) {
        final activeTypes = _filters['paymentTypes']!.map((t) => t.toLowerCase());
        if (!activeTypes.contains(tx.type)) return false;
      }

      return true;
    }).toList();

    list.sort((a, b) {
      final dc = b.date.compareTo(a.date);
      if (dc != 0) return dc;
      return b.time.compareTo(a.time);
    });
    return list;
  }

  List<MapEntry<String, List<Tx>>> _groupByDate(List<Tx> txs) {
    final result = <MapEntry<String, List<Tx>>>[];
    for (final tx in txs) {
      if (result.isNotEmpty && result.last.key == tx.date) {
        result.last.value.add(tx);
      } else {
        result.add(MapEntry(tx.date, [tx]));
      }
    }
    return result;
  }

  String _formatDateHeader(String dateStr) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime.parse(dateStr).toLocal();

    final dClean = DateTime(d.year, d.month, d.day);
    if (dClean == today) return 'TODAY';
    if (dClean == yesterday) return 'YESTERDAY';

    const days = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return '${days[d.weekday % 7]}, ${d.day} ${months[d.month - 1]}';
  }

  String _formatAmount(double amt) {
    // Ensure we work with positive integer for comma logic
    final s = amt.abs().toInt().toString();
    final buf = StringBuffer();
    final reversed = s.split('').reversed.toList();
    for (var i = 0; i < reversed.length; i++) {
      // Indian numbering system: comma after 3 digits, then every 2 digits
      if (i == 3 || (i > 3 && (i - 3) % 2 == 0)) {
        buf.write(',');
      }
      buf.write(reversed[i]);
    }
    return buf.toString().split('').reversed.join();
  }

  Future<void> _openFilters() async {
    final result = await Navigator.of(context).push<Map<String, Set<String>>>(
      PageRouteBuilder(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, anim, __) => _FiltersPage(
          initial: {
            for (final e in _filters.entries) e.key: {...e.value},
          },
        ),
        transitionsBuilder: (_, anim, __, child) {
          final tween = Tween(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOut));
          return SlideTransition(position: anim.drive(tween), child: child);
        },
      ),
    );
    if (result != null) {
      setState(() {
        for (final k in _filters.keys) {
          _filters[k] = result[k] ?? {};
        }
      });
      _fetchTxsWithFilters();
    }
  }

  void _removeFilter(String value) {
    setState(() {
      for (final k in _filters.keys) {
        _filters[k]!.remove(value);
      }
    });
    _fetchTxsWithFilters();
  }

  void _clearAll() {
    setState(() {
      for (final k in _filters.keys) {
        _filters[k]!.clear();
      }
    });
    _fetchTxsWithFilters();
  }

  // ---------- Fraud / Help & Support sheet ----------
  void _openTransactionSupport(Tx tx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TransactionSupportSheet(
        tx: tx,
        formatAmount: _formatAmount,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final groups = _groupByDate(filtered);

    return Scaffold(
      backgroundColor: kCream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF1B5E20)),
                    onPressed: () {
                      if (widget.onBack != null) {
                        widget.onBack!();
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'Transactions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEEEAF3)),
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (v) => setState(() => _search = v),
                        decoration: const InputDecoration(
                          hintText: 'Search by name, category...',
                          hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                          prefixIcon: Icon(Icons.search, size: 18, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 11),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _openFilters,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _activeFilterCount > 0
                            ? const Color(0xFF1B5E20)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEEEAF3)),
                      ),
                      child: Icon(
                        Icons.tune_outlined,
                        size: 20,
                        color: _activeFilterCount > 0 ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (_activeFilterCount > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    for (final entry in _filters.entries)
                      for (final v in entry.value)
                        InputChip(
                          label: Text(v, style: const TextStyle(fontSize: 11)),
                          onDeleted: () => _removeFilter(v),
                          backgroundColor: const Color(0xFF1B5E20).withValues(alpha: 0.1),
                          labelStyle: const TextStyle(color: Color(0xFF1B5E20)),
                          deleteIconColor: const Color(0xFF1B5E20),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          side: BorderSide.none,
                        ),
                    TextButton(
                      onPressed: _clearAll,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        minimumSize: Size.zero,
                      ),
                      child: const Text(
                        'Clear',
                        style: TextStyle(
                          fontSize: 11,
                          decoration: TextDecoration.underline,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: _buildMainContent(filtered, groups),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(List<Tx> filtered, List<MapEntry<String, List<Tx>>> groups) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1B5E20)),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No transactions found',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 10),
            const Text(
              'Pull down to refresh or check filters',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchTxs,
      color: const Color(0xFF1B5E20),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        itemCount: groups.length,
        itemBuilder: (_, gi) {
          final group = groups[gi];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 4),
                child: Row(
                  children: [
                    Text(
                      _formatDateHeader(group.key),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Divider(height: 1, color: Color(0xFFEEEAF3)),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEEEAF3)),
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < group.value.length; i++)
                      _buildTxRow(
                        group.value[i],
                        isLast: i == group.value.length - 1,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],
          );
        },
      ),
    );
  }


  Widget _buildTxRow(Tx tx, {required bool isLast}) {
    final isFailed = tx.status == 'failed';
    final isDebit = tx.type == 'debit';

    // --- 🎨 DYNAMIC ICON & COLOR MAPPING ---
    final details = _getTxDetails(tx);
    final primaryColor = details.color;

    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFF1F1F1), width: 1),
              ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          // Styled Icon Container
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withValues(alpha: 0.15),
                  primaryColor.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              details.icon,
              color: isFailed ? Colors.grey : primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isFailed ? Colors.black45 : Colors.black87,
                    decoration: isFailed ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${tx.mode}${tx.card.isNotEmpty ? ' ${tx.card}' : ''} • ${tx.time}',
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 10,
                      color: Colors.black38,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      tx.location,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black45,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isDebit ? '-' : '+'} ₹${_formatAmount(tx.amount)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isFailed
                      ? Colors.black45
                      : (isDebit
                            ? const Color(0xFFB91C1C)
                            : const Color(0xFF15803D)),
                  decoration: isFailed ? TextDecoration.lineThrough : null,
                ),
              ),
              if (isFailed)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'FAILED',
                    style: TextStyle(
                      fontSize: 8,
                      color: Colors.red,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
          // --- Info / Help & Support button ---
          IconButton(
            icon: const Icon(Icons.info_outline, size: 18, color: Colors.black38),
            padding: const EdgeInsets.only(left: 4),
            constraints: const BoxConstraints(),
            splashRadius: 18,
            onPressed: () => _openTransactionSupport(tx),
            tooltip: 'Help & support for this transaction',
          ),
        ],
      ),
    );
  }

  // Helper to determine Icon and Color based on Keywords
  _TxUIDetails _getTxDetails(Tx tx) {
    final name = tx.name.toLowerCase();
    final cat = tx.category.toLowerCase();

    if (name.contains('coffee') ||
        name.contains('starbucks') ||
        name.contains('tokai')) {
      return _TxUIDetails(Icons.coffee_rounded, Colors.orange.shade800);
    }
    if (name.contains('grocery') ||
        name.contains('basket') ||
        name.contains('market') ||
        name.contains('blinkit') ||
        name.contains('zepto')) {
      return _TxUIDetails(Icons.shopping_basket_rounded, Colors.green.shade700);
    }
    if (name.contains('zomato') ||
        name.contains('swiggy') ||
        name.contains('lunch') ||
        name.contains('food') ||
        name.contains('restaurant') ||
        name.contains('pizza')) {
      return _TxUIDetails(Icons.restaurant_rounded, Colors.red.shade600);
    }
    if (name.contains('atm') ||
        name.contains('cash') ||
        name.contains('withdrawal')) {
      return _TxUIDetails(Icons.atm_rounded, Colors.indigo.shade700);
    }
    if (name.contains('hotel') ||
        name.contains('stay') ||
        name.contains('resort') ||
        name.contains('westin')) {
      return _TxUIDetails(Icons.hotel_rounded, Colors.purple.shade700);
    }
    if (name.contains('netflix') ||
        name.contains('spotify') ||
        name.contains('subscription') ||
        name.contains('prime') ||
        name.contains('youtube')) {
      return _TxUIDetails(Icons.subscriptions_rounded, Colors.red.shade900);
    }
    if (name.contains('jio') ||
        name.contains('airtel') ||
        name.contains('recharge') ||
        name.contains('mobile')) {
      return _TxUIDetails(Icons.phone_android_outlined, Colors.blue.shade700);
    }
    if (name.contains('bolt') ||
        name.contains('bill') ||
        name.contains('electricity') ||
        name.contains('water')) {
      return _TxUIDetails(Icons.bolt_rounded, Colors.amber.shade900);
    }
    if (name.contains('salary') || cat.contains('received')) {
      return _TxUIDetails(
        Icons.account_balance_wallet_rounded,
        Colors.teal.shade700,
      );
    }
    if (cat.contains('sent')) {
      return _TxUIDetails(Icons.person_rounded, Colors.blueGrey.shade700);
    }

    // Default Fallback
    return _TxUIDetails(Icons.store_rounded, Colors.blueGrey.shade600);
  }

  List<Tx> _getMockTransactions() {
    final now = DateTime.now();
    return [
      Tx(
        name: 'Starbucks Coffee',
        type: 'debit',
        amount: 450.0,
        icon: '☕',
        date: '2026-04-21',
        time: '10:30 AM',
        mode: 'UPI',
        card: '',
        status: 'successful',
        category: 'merchant',
        location: 'Mumbai, India',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      Tx(
        name: 'Salary Credited',
        type: 'credit',
        amount: 85000.0,
        icon: '💰',
        date: '2026-04-01',
        time: '09:00 AM',
        mode: 'NEFT',
        card: 'A/c XX9876',
        status: 'successful',
        category: 'money_received',
        location: 'Bengaluru, India',
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      Tx(
        name: 'Zomato Order',
        type: 'debit',
        amount: 1240.0,
        icon: '🍕',
        date: '2026-04-20',
        time: '08:15 PM',
        mode: 'Card',
        card: '••4321',
        status: 'successful',
        category: 'merchant',
        location: 'Delhi, India',
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
      ),
      Tx(
        name: 'Airtel Recharge',
        type: 'debit',
        amount: 799.0,
        icon: '📱',
        date: '2026-04-19',
        time: '11:45 AM',
        mode: 'UPI',
        card: '',
        status: 'failed',
        category: 'merchant',
        location: 'Online',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Tx(
        name: 'Rent Payment',
        type: 'debit',
        amount: 25000.0,
        icon: '🏠',
        date: '2026-04-02',
        time: '10:00 AM',
        mode: 'IMPS',
        card: 'A/c XX1234',
        status: 'successful',
        category: 'money_sent',
        location: 'Mumbai, India',
        createdAt: now.subtract(const Duration(days: 19)),
      ),
      Tx(
        name: 'Amazon Purchase',
        type: 'debit',
        amount: 3200.0,
        icon: '📦',
        date: '2026-03-25',
        time: '04:30 PM',
        mode: 'Card',
        card: '••4321',
        status: 'successful',
        category: 'merchant',
        location: 'Online',
        createdAt: now.subtract(const Duration(days: 27)),
      ),
      Tx(
        name: 'Netflix Subscription',
        type: 'debit',
        amount: 649.0,
        icon: '🎬',
        date: '2026-04-15',
        time: '12:00 AM',
        mode: 'Card',
        card: '••4321',
        status: 'successful',
        category: 'merchant',
        location: 'Digital',
        createdAt: now.subtract(const Duration(days: 6)),
      ),
    ];
  }
}

class _TxUIDetails {
  final IconData icon;
  final Color color;
  _TxUIDetails(this.icon, this.color);
}

// ---------- Transaction Help & Support / Fraud Sheet ----------
class _TransactionSupportSheet extends StatelessWidget {
  final Tx tx;
  final String Function(double) formatAmount;

  const _TransactionSupportSheet({
    required this.tx,
    required this.formatAmount,
  });

  static const _fraudGreen = Color(0xFF1B5E20);
  static const _fraudRed = Color(0xFFB91C1C);

  Future<void> _call(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    await launchUrl(uri);
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _emailSupport(String subject, String body) async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'care@psb.co.in',
      query: 'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );
    await launchUrl(uri);
  }

  String _buildEvidenceText() {
    return '''
TRANSACTION EVIDENCE REPORT
----------------------------------
Name/Merchant : ${tx.name}
Amount        : ${tx.type == 'debit' ? '-' : '+'} ₹${formatAmount(tx.amount)}
Type          : ${tx.type.toUpperCase()}
Category      : ${tx.category}
Date          : ${tx.date}
Time          : ${tx.time}
Payment Mode  : ${tx.mode}${tx.card.isNotEmpty ? ' (${tx.card})' : ''}
Status        : ${tx.status.toUpperCase()}
Location      : ${tx.location}
----------------------------------
Generated for cyber fraud reporting purposes.
Report at: cybercrime.gov.in | Helpline: 1930
''';
  }

  Future<void> _downloadEvidence() async {
    final text = _buildEvidenceText();
    await Share.share(text, subject: 'Transaction Evidence - ${tx.name}');
  }

  @override
  Widget build(BuildContext context) {
    final isDebit = tx.type == 'debit';
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                'Help & Support',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _fraudGreen),
              ),
              const SizedBox(height: 14),

              // --- Transaction summary card ---
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tx.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                          const SizedBox(height: 4),
                          Text(
                            '${tx.mode}${tx.card.isNotEmpty ? ' ${tx.card}' : ''} • ${tx.date} • ${tx.time}',
                            style: const TextStyle(fontSize: 11, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${isDebit ? '-' : '+'} ₹${formatAmount(tx.amount)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: isDebit ? _fraudRed : const Color(0xFF15803D),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- Fraud reporting section ---
              Text(
                'Think this is fraud?',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _fraudRed.withValues(alpha: 0.9)),
              ),
              const SizedBox(height: 4),
              const Text(
                'If you did not authorize this transaction, act fast — report it immediately.',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 12),

              _ActionTile(
                icon: Icons.call_rounded,
                iconColor: _fraudRed,
                title: 'Call Fraud Helpline — 1930',
                subtitle: 'National Cyber Crime Helpline (toll-free)',
                onTap: () => _call('1930'),
              ),
              const SizedBox(height: 10),
              _ActionTile(
                icon: Icons.open_in_new_rounded,
                iconColor: _fraudRed,
                title: 'Report on I4C Portal',
                subtitle: 'cybercrime.gov.in',
                onTap: () => _openLink('https://cybercrime.gov.in'),
              ),
              const SizedBox(height: 10),
              _ActionTile(
                icon: Icons.download_rounded,
                iconColor: _fraudGreen,
                title: 'Download Evidence Pack',
                subtitle: 'Share/export full transaction details for your report',
                onTap: _downloadEvidence,
              ),

              const SizedBox(height: 24),
              const Divider(height: 1, color: Color(0xFFEEEAF3)),
              const SizedBox(height: 20),

              // --- General help & support ---
              const Text(
                'Need other help?',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              _ActionTile(
                icon: Icons.support_agent_rounded,
                iconColor: _fraudGreen,
                title: 'Call Us',
                subtitle: 'Speak to customer support',
                onTap: () => _call('18004198300'),
              ),
              const SizedBox(height: 10),
              _ActionTile(
                icon: Icons.confirmation_number_outlined,
                iconColor: _fraudGreen,
                title: 'Raise a Ticket',
                subtitle: 'Get help via email for this transaction',
                onTap: () => _emailSupport(
                  'Query regarding transaction - ${tx.name}',
                  _buildEvidenceText(),
                ),
              ),
              const SizedBox(height: 10),
              _ActionTile(
                icon: Icons.chat_bubble_outline_rounded,
                iconColor: _fraudGreen,
                title: 'Chat with Us',
                subtitle: 'Talk to our support chatbot',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: hook this up to your in-app chat/support screen
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEEEAF3)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 19),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}

class _FiltersPage extends StatefulWidget {
  final Map<String, Set<String>> initial;
  const _FiltersPage({required this.initial});
  @override
  State<_FiltersPage> createState() => _FiltersPageState();
}

class _FiltersPageState extends State<_FiltersPage> {
  static const _tabs = ['Months', 'Categories', 'Instruments', 'Payment status', 'Payment types'];
  static const Map<String, String> _tabKey = {
    'Months': 'months',
    'Categories': 'categories',
    'Instruments': 'instruments',
    'Payment status': 'paymentStatus',
    'Payment types': 'paymentTypes',
  };

  static List<String> _generateMonths() {
    final now = DateTime.now();
    final List<String> months = [];
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec'];

    for (int i = 0; i < 6; i++) {
       final d = DateTime(now.year, now.month - i, 1);
       months.add("${monthNames[d.month - 1]} ${d.year}");
    }
    return months;
  }

  static final Map<String, List<String>> _options = {
    'Months': _generateMonths(),
    'Categories': ['Money sent', 'Money received', 'Merchant payments'],
    'Instruments': ['Debit Card', 'UPI', 'Bank Account'],
    'Payment status': ['Failed', 'Successful'],
    'Payment types': ['Debit', 'Credit'],
  };
  late Map<String, Set<String>> _local;
  String _activeTab = 'Months';

  @override
  void initState() {
    super.initState();
    _local = {
      for (final e in widget.initial.entries) e.key: {...e.value},
    };
  }

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
                searchText: 'Search...',
                onHomeTap: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                onLogoutTap: () => Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (route) => false),
                onNotificationTap: () {},
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Filters',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  TextButton(
                    onPressed: () => setState(() {
                      for (var k in _local.keys) {
                        _local[k]!.clear();
                      }
                    }),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF1B5E20),
                    ),
                    child: const Text('Reset'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 120,
                    color: const Color(0xFFF7F7F7),
                    child: ListView.builder(
                      itemCount: _tabs.length,
                      itemBuilder: (_, i) {
                        final isSel = _activeTab == _tabs[i];
                        return GestureDetector(
                          onTap: () => setState(() => _activeTab = _tabs[i]),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            color: isSel ? Colors.white : Colors.transparent,
                            child: Text(
                              _tabs[i],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSel
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isSel
                                    ? const Color(0xFF1B5E20)
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _options[_activeTab]!.length,
                      itemBuilder: (_, i) {
                        final opt = _options[_activeTab]![i];
                        final k = _tabKey[_activeTab]!;
                        final isSel = _local[k]!.contains(opt);
                        return CheckboxListTile(
                          value: isSel,
                          title: Text(
                            opt,
                            style: const TextStyle(fontSize: 13),
                          ),
                          onChanged: (_) => setState(
                            () => isSel
                                ? _local[k]!.remove(opt)
                                : _local[k]!.add(opt),
                          ),
                          activeColor: const Color(0xFF1B5E20),
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, _local),
                  child: const Text('Apply Filters'),
                ),
              ),
            ),
            BottomNav(
              currentIndex: 1,
              onTap: (index) {
                if (index == 1) {
                  Navigator.pop(context);
                  return;
                }
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/home',
                  (route) => false,
                  arguments: {'index': index},
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}