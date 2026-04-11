import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ─── Data Model ───
class Transaction {
  final String name, icon, mode, card, status, category, type;
  final int amount;
  final DateTime date;
  final String time;

  Transaction({
    required this.name, required this.icon, required this.mode,
    this.card = '', required this.status, required this.category,
    required this.type, required this.amount, required this.date,
    required this.time,
  });
}

// ─── Main Screen ───
class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});
  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  static const Color primaryGreen = Color(0xFF1B5E20);
  static const Color bgColor = Color(0xFFF5F5F0);
  final supabase = Supabase.instance.client;
  @override
void initState() {
  super.initState();
  fetchTransactions(); //  THIS LINE IS REQUIRED
}

  List<Transaction> _allTransactions = [];
  
  Future<void> fetchTransactions() async {
  try {
    final response = await supabase
        .from('transactions')
        .select()
        .order('transaction_id', ascending: false);

    print("RAW DATA: $response");

    setState(() {
      _allTransactions = (response as List)
          .map((data) {
            final createdAt = data['created_at'];

            return Transaction(
              name: data['name'] ?? '',
              amount: (data['amount'] ?? 0).toInt(), // ✅ FIXED
              type: data['transaction_type'] == 'debit'
                  ? 'sent'
                  : 'received',
              icon: '💸',

              // ✅ FIXED DATE
              date: createdAt != null
                  ? DateTime.parse(createdAt)
                  : DateTime.now(),

              time: createdAt != null
                  ? DateFormat('hh:mm a').format(DateTime.parse(createdAt))
                  : 'Now',

              mode: data['mode'] ?? '',
              status: data['status'] ?? '',
              category: data['category'] ?? '',
            );
          })
          .toList();
    });
  } catch (e) {
    print("ERROR FETCHING: $e");
  }
}


  bool _showSearch = false;
  String _search = '';
  Map<String, List<String>> _filters = {
    'months': [], 'categories': [], 'instruments': [],
    'paymentStatus': [], 'paymentTypes': [],

  };

  int get _activeFilterCount =>
      _filters.values.fold(0, (s, a) => s + a.length);

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(d.year, d.month, d.day);
    if (dateOnly == today) return 'Today';
    if (dateOnly == yesterday) return 'Yesterday';
    return DateFormat('d MMM').format(d);
  }

  String _monthLabel(DateTime d) => DateFormat('MMM yyyy').format(d);

  List<Transaction> get _filtered {
    return _allTransactions.where((tx) {
      if (_search.isNotEmpty &&
          !tx.name.toLowerCase().contains(_search.toLowerCase())) {
        return false;
      }
      if (_filters['months']!.isNotEmpty &&
          !_filters['months']!.contains(_monthLabel(tx.date))) {
        return false;
      }
      if (_filters['categories']!.isNotEmpty &&
          !_filters['categories']!.contains(tx.category)) {
        return false;
      }
      if (_filters['paymentStatus']!.isNotEmpty &&
          !_filters['paymentStatus']!.contains(tx.status)) {
        return false;
      }
      return true;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  void _removeFilter(String value) {
    setState(() {
      for (final key in _filters.keys) {
        _filters[key] = _filters[key]!.where((v) => v != value).toList();
      }
    });
  }

  void _openFilters() {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (_, _, _) => _FilterPage(
        filters: Map.from(_filters.map((k, v) => MapEntry(k, List<String>.from(v)))),
        onApply: (f) {
          setState(() => _filters = f);
          Navigator.of(context).pop();
        },
      ),
      transitionsBuilder: (_, anim, _, child) =>
          SlideTransition(position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(anim), child: child),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final txns = _filtered;
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            

            // ── Title + Actions ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  const Text('Transaction History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() { _showSearch = !_showSearch; if (!_showSearch) _search = ''; }),
                    child: const Padding(padding: EdgeInsets.all(6), child: Icon(Icons.search, size: 20)),
                  ),
                  GestureDetector(
                    onTap: _openFilters,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Padding(padding: EdgeInsets.all(6), child: Icon(Icons.tune, size: 20)),
                        if (_activeFilterCount > 0)
                          Positioned(
                            right: 0, top: 0,
                            child: Container(
                              width: 16, height: 16,
                              decoration: const BoxDecoration(color: primaryGreen, shape: BoxShape.circle),
                              child: Center(child: Text('$_activeFilterCount', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Search Bar ──
            if (_showSearch)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  autofocus: true,
                  onChanged: (v) => setState(() => _search = v),
                  decoration: InputDecoration(
                    hintText: 'Search transactions...',
                    prefixIcon: const Icon(Icons.search, size: 18),
                    suffixIcon: _search.isNotEmpty
                        ? GestureDetector(onTap: () => setState(() => _search = ''), child: const Icon(Icons.close, size: 16))
                        : null,
                    filled: true, fillColor: Colors.grey.shade200,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ),

            // ── Filter Chips ──
            if (_activeFilterCount > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Wrap(
                  spacing: 6, runSpacing: 4,
                  children: [
                    ..._filters.values.expand((v) => v).map((v) => Chip(
                      label: Text(v, style: const TextStyle(fontSize: 11, color: primaryGreen)),
                      deleteIcon: const Icon(Icons.close, size: 12),
                      onDeleted: () => _removeFilter(v),
                      backgroundColor: primaryGreen.withOpacity(0.1),
                      side: BorderSide.none,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    )),
                    GestureDetector(
                      onTap: () => setState(() => _filters = { 'months': [], 'categories': [], 'instruments': [], 'paymentStatus': [], 'paymentTypes': [] }),
                      child: const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text('Clear', style: TextStyle(fontSize: 11, color: Colors.grey, decoration: TextDecoration.underline)),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 8),

            // ── Transaction List ──
            Expanded(
              child: txns.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('No transactions found', style: TextStyle(color: Colors.grey, fontSize: 14)),
                          if (_activeFilterCount > 0)
                            TextButton(
                              onPressed: () => setState(() => _filters = { 'months': [], 'categories': [], 'instruments': [], 'paymentStatus': [], 'paymentTypes': [] }),
                              child: const Text('Clear filters', style: TextStyle(fontSize: 12)),
                            ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: 1,
                      itemBuilder: (_, _) => Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                        ),
                        child: Column(
                          children: List.generate(txns.length, (i) {
                            final tx = txns[i];
                            final isFailed = tx.status == 'Failed';
                            final modeIcon = tx.mode == 'Debit Card' ? Icons.credit_card : tx.mode == 'UPI' ? Icons.smartphone : Icons.account_balance;
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 36, height: 36,
                                        decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                                        child: Center(child: Text(tx.icon, style: const TextStyle(fontSize: 16))),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              tx.name,
                                              style: TextStyle(
                                                fontSize: 13, fontWeight: FontWeight.w500,
                                                color: isFailed ? Colors.grey : Colors.black87,
                                                decoration: isFailed ? TextDecoration.lineThrough : null,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                Icon(modeIcon, size: 11, color: Colors.grey),
                                                const SizedBox(width: 4),
                                                Flexible(
                                                  child: Text(
                                                    '${tx.mode}${tx.card.isNotEmpty ? ' ${tx.card}' : ''} • ${tx.time} • ${_formatDate(tx.date)}',
                                                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                if (isFailed) ...[
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: const Text('Failed', style: TextStyle(fontSize: 9, color: Colors.red, fontWeight: FontWeight.w500)),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (isFailed) const Icon(Icons.error_outline, size: 14, color: Colors.red),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${tx.type == 'sent' ? '- ' : '+ '}₹${NumberFormat('#,##,###').format(tx.amount)}',
                                            style: TextStyle(
                                              fontSize: 13, fontWeight: FontWeight.w600,
                                              color: isFailed ? Colors.grey : tx.type == 'sent' ? Colors.red : const Color(0xFF2E7D32),
                                              decoration: isFailed ? TextDecoration.lineThrough : null,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                if (i < txns.length - 1) Divider(height: 1, indent: 58, color: Colors.grey.shade200),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Filter Page ───
class _FilterPage extends StatefulWidget {
  final Map<String, List<String>> filters;
  final Function(Map<String, List<String>>) onApply;

  const _FilterPage({required this.filters, required this.onApply});
  @override
  State<_FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<_FilterPage> {
  static const Color primaryGreen = Color(0xFF1B5E20);

  late Map<String, List<String>> _local;
  String _activeTab = 'Months';

  static const Map<String, String> _tabKeyMap = {
    'Months': 'months', 'Categories': 'categories', 'Instruments': 'instruments',
    'Payment status': 'paymentStatus', 'Payment types': 'paymentTypes',
  };

  static const Map<String, List<String>> _options = {
    'Months': ['Apr 2026','Mar 2026','Feb 2026','Jan 2026','Dec 2025','Nov 2025','Oct 2025','Sep 2025','Aug 2025','Jul 2025','Jun 2025','May 2025','Apr 2025','Mar 2025'],
    'Categories': ['Money sent','Money received','Merchant payments','UPI Lite add money & closure'],
    'Instruments': ['UPI/Bank account','UPI Lite'],
    'Payment status': ['Failed','Successful'],
    'Payment types': ['IPO & external autoPay'],
  };

  @override
  void initState() {
    super.initState();
    _local = Map.from(widget.filters.map((k, v) => MapEntry(k, List<String>.from(v))));
  }

  String get _key => _tabKeyMap[_activeTab]!;
  List<String> get _selected => _local[_key]!;
  int get _totalSelected => _local.values.fold(0, (s, a) => s + a.length);

  void _toggle(String value) {
    setState(() {
      if (_selected.contains(value)) {
        _local[_key] = _selected.where((v) => v != value).toList();
      } else {
        _local[_key] = [..._selected, value];
      }
    });
  }

  void _clearAll() {
    setState(() {
      _local = { 'months': [], 'categories': [], 'instruments': [], 'paymentStatus': [], 'paymentTypes': [] };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade300))),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back, size: 22), onPressed: () => Navigator.pop(context)),
                  const Text('Filters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  TextButton(onPressed: _clearAll, child: const Text('Clear all', style: TextStyle(fontSize: 13, color: Colors.grey))),
                ],
              ),
            ),

            // Body
            Expanded(
              child: Row(
                children: [
                  // Left tabs
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.38,
                    child: Container(
                      color: Colors.grey.shade100,
                      child: ListView(
                        children: _tabKeyMap.keys.map((tab) {
                          final count = _local[_tabKeyMap[tab]!]!.length;
                          final isActive = _activeTab == tab;
                          return GestureDetector(
                            onTap: () => setState(() => _activeTab = tab),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(
                                color: isActive ? Colors.white : Colors.transparent,
                                border: isActive ? const Border(left: BorderSide(color: primaryGreen, width: 2)) : null,
                              ),
                              child: Row(
                                children: [
                                  Flexible(child: Text(tab, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isActive ? Colors.black87 : Colors.grey))),
                                  if (count > 0) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      width: 16, height: 16,
                                      decoration: const BoxDecoration(color: primaryGreen, shape: BoxShape.circle),
                                      child: Center(child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  // Right options
                  Expanded(
                    child: ListView(
                      children: _options[_activeTab]!.map((option) {
                        final checked = _selected.contains(option);
                        return GestureDetector(
                          onTap: () => _toggle(option),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
                            child: Row(
                              children: [
                                Expanded(child: Text(option, style: const TextStyle(fontSize: 13))),
                                Container(
                                  width: 20, height: 20,
                                  decoration: BoxDecoration(
                                    color: checked ? primaryGreen : Colors.transparent,
                                    border: Border.all(color: checked ? primaryGreen : Colors.grey.shade400, width: 2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: checked ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // Apply button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade300))),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => widget.onApply(_local),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  child: Text('Apply${_totalSelected > 0 ? ' ($_totalSelected)' : ''}'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
