// transaction_screen.dart
// Single-file Flutter implementation of the Transaction History screen.
// Includes: search, multi-tab filters (Months, Categories, Instruments,
// Payment status, Payment types), date-grouped list, location indicator,
// active filter chips, and a working Apply button above a bottom nav.
//
// Drop into your project and run: `flutter run`
// Requires: flutter sdk (no third-party packages needed).

import 'package:flutter/material.dart';

void main() => runApp(const TransactionApp());

class TransactionApp extends StatelessWidget {
  const TransactionApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Theme tokens roughly mirroring the web design system.
    const seed = Color(0xFF16A34A); // green (matches your inspo)
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF8F7FB),
      fontFamily: 'Roboto',
    );
    return MaterialApp(
      title: 'Transaction History',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const TransactionScreen(),
    );
  }
}

// ---------- Model ----------
class Tx {
  final String name;
  final String type; // 'sent' | 'received'
  final int amount;
  final String icon;
  final String date; // YYYY-MM-DD
  final String time; // e.g. '2:30 PM'
  final String mode; // UPI | Debit Card | NEFT | IMPS
  final String card; // optional, e.g. '••1234'
  final String status; // Successful | Failed
  final String category; // Money sent | Money received | Merchant payments | ...
  final String location;

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
  });
}

// ---------- Screen ----------
class TransactionScreen extends StatefulWidget {
  final VoidCallback? onBack;   // 👈 ADD THIS

  const TransactionScreen({super.key, this.onBack});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  // Filter state (mirrors the web FiltersState).
  final Map<String, Set<String>> _filters = {
    'months': <String>{},
    'categories': <String>{},
    'instruments': <String>{},
    'paymentStatus': <String>{},
    'paymentTypes': <String>{},
  };

  String _search = '';
  bool _showSearch = false;
  final TextEditingController _searchCtrl = TextEditingController();
  int _bottomIndex = 1; // History tab selected.

  // ----- Data -----
  static const _monthMap = {
    '01': 'Jan', '02': 'Feb', '03': 'Mar', '04': 'Apr',
    '05': 'May', '06': 'Jun', '07': 'Jul', '08': 'Aug',
    '09': 'Sept', '10': 'Oct', '11': 'Nov', '12': 'Dec',
  };

  final List<Tx> _all = const [
    Tx(name: 'Karan Sharma', type: 'sent', amount: 2000, icon: '👤', date: '2026-04-02', time: '2:30 PM', mode: 'UPI', card: '', status: 'Successful', category: 'Money sent', location: 'Connaught Place, Delhi'),
    Tx(name: 'Electricity Bill', type: 'sent', amount: 1200, icon: '⚡', date: '2026-04-02', time: '11:00 AM', mode: 'Debit Card', card: '••1234', status: 'Successful', category: 'Merchant payments', location: 'Online'),
    Tx(name: 'Salary Credit', type: 'received', amount: 45000, icon: '🏢', date: '2026-04-01', time: '9:00 AM', mode: 'NEFT', card: '', status: 'Successful', category: 'Money received', location: 'Gurugram, HR'),
    Tx(name: 'Zomato', type: 'sent', amount: 850, icon: '🍔', date: '2026-04-01', time: '8:15 PM', mode: 'Debit Card', card: '••1234', status: 'Successful', category: 'Merchant payments', location: 'Saket, Delhi'),
    Tx(name: 'Priya Singh', type: 'received', amount: 1500, icon: '👤', date: '2026-03-31', time: '4:00 PM', mode: 'UPI', card: '', status: 'Successful', category: 'Money received', location: 'Noida, UP'),
    Tx(name: 'Amazon Shopping', type: 'sent', amount: 3200, icon: '🛒', date: '2026-03-31', time: '1:20 PM', mode: 'Debit Card', card: '••5678', status: 'Failed', category: 'Merchant payments', location: 'Online'),
    Tx(name: 'Rajesh Kumar', type: 'received', amount: 800, icon: '👤', date: '2026-03-30', time: '6:45 PM', mode: 'UPI', card: '', status: 'Successful', category: 'Money received', location: 'Lucknow, UP'),
    Tx(name: 'Netflix', type: 'sent', amount: 649, icon: '🎬', date: '2026-03-28', time: '12:00 PM', mode: 'UPI', card: '', status: 'Successful', category: 'Merchant payments', location: 'Online'),
    Tx(name: 'Flipkart', type: 'sent', amount: 4500, icon: '📦', date: '2026-03-25', time: '3:45 PM', mode: 'Debit Card', card: '••1234', status: 'Successful', category: 'Merchant payments', location: 'Online'),
    Tx(name: 'Ankit Verma', type: 'received', amount: 2200, icon: '👤', date: '2026-03-20', time: '10:30 AM', mode: 'IMPS', card: '', status: 'Successful', category: 'Money received', location: 'Jaipur, RJ'),
    Tx(name: 'Gym Membership', type: 'sent', amount: 1800, icon: '💪', date: '2026-02-15', time: '9:00 AM', mode: 'UPI', card: '', status: 'Successful', category: 'Merchant payments', location: 'Vasant Kunj, Delhi'),
    Tx(name: 'Freelance Payment', type: 'received', amount: 15000, icon: '💼', date: '2026-01-10', time: '11:00 AM', mode: 'NEFT', card: '', status: 'Successful', category: 'Money received', location: 'Mumbai, MH'),
  ];

  // ----- Helpers -----
  String _instrumentForMode(String mode) => 'UPI/Bank account';

  int get _activeFilterCount =>
      _filters.values.fold(0, (s, set) => s + set.length);

  List<Tx> get _filtered {
    final q = _search.trim().toLowerCase();
    final list = _all.where((tx) {
      if (q.isNotEmpty && !tx.name.toLowerCase().contains(q)) return false;
      final months = _filters['months']!;
      if (months.isNotEmpty) {
        final parts = tx.date.split('-');
        final label = '${_monthMap[parts[1]]} ${parts[0]}';
        if (!months.contains(label)) return false;
      }
      if (_filters['categories']!.isNotEmpty &&
          !_filters['categories']!.contains(tx.category)) return false;
      if (_filters['instruments']!.isNotEmpty &&
          !_filters['instruments']!.contains(_instrumentForMode(tx.mode))) {
        return false;
      }
      if (_filters['paymentStatus']!.isNotEmpty &&
          !_filters['paymentStatus']!.contains(tx.status)) return false;
      return true;
    }).toList();

    list.sort((a, b) {
      final dc = b.date.compareTo(a.date);
      if (dc != 0) return dc;
      return b.time.compareTo(a.time);
    });
    return list;
  }

  String _formatDateHeader(String dateStr) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime.parse(dateStr);
    if (d == today) return 'TODAY';
    if (d == yesterday) return 'YESTERDAY';
    const days = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    const months = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'];
    // DateTime.weekday: Mon=1..Sun=7
    final dayLabel = days[d.weekday % 7];
    return '$dayLabel, ${d.day} ${months[d.month - 1]}';
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

  IconData _modeIcon(String mode) {
    switch (mode) {
      case 'Debit Card':
        return Icons.credit_card_outlined;
      case 'UPI':
        return Icons.smartphone_outlined;
      default:
        return Icons.account_balance_outlined;
    }
  }

  String _formatAmount(int amt) {
    final s = amt.toString();
    final buf = StringBuffer();
    // Indian numbering: last 3 digits, then groups of 2.
    final reversed = s.split('').reversed.toList();
    for (var i = 0; i < reversed.length; i++) {
      if (i == 3 || (i > 3 && (i - 3) % 2 == 0)) buf.write(',');
      buf.write(reversed[i]);
    }
    return buf.toString().split('').reversed.join();
  }

  // ----- Actions -----
  Future<void> _openFilters() async {
    final result = await Navigator.of(context).push<Map<String, Set<String>>>(
      PageRouteBuilder(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, __, ___) => _FiltersPage(
          initial: {
            for (final e in _filters.entries) e.key: {...e.value},
          },
        ),
        transitionsBuilder: (_, anim, __, child) {
          final tween = Tween(begin: const Offset(1, 0), end: Offset.zero)
              .chain(CurveTween(curve: Curves.easeOut));
          return SlideTransition(position: anim.drive(tween), child: child);
        },
      ),
    );
    if (result != null) {
      setState(() {
        for (final k in _filters.keys) {
          _filters[k] = result[k] ?? <String>{};
        }
      });
    }
  }

  void _removeFilterValue(String value) {
    setState(() {
      for (final k in _filters.keys) {
        _filters[k]!.remove(value);
      }
    });
  }

  void _clearAll() {
    setState(() {
      for (final k in _filters.keys) {
        _filters[k]!.clear();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ----- Build -----
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final filtered = _filtered;
    final groups = _groupByDate(filtered);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FB),
      body: SafeArea(
        child: Column(
          children: [
            

            // -------- Title + actions --------
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Transaction History',
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() {
                      _showSearch = !_showSearch;
                      if (!_showSearch) {
                        _search = '';
                        _searchCtrl.clear();
                      }
                    }),
                    icon: const Icon(Icons.search, size: 20),
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: _openFilters,
                        icon: const Icon(Icons.tune, size: 20),
                      ),
                      if (_activeFilterCount > 0)
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            width: 16,
                            height: 16,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: scheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$_activeFilterCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // -------- Search bar --------
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              child: _showSearch
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: TextField(
                        controller: _searchCtrl,
                        autofocus: true,
                        onChanged: (v) => setState(() => _search = v),
                        decoration: InputDecoration(
                          hintText: 'Search transactions...',
                          prefixIcon: const Icon(Icons.search, size: 18),
                          suffixIcon: _search.isEmpty
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.close, size: 16),
                                  onPressed: () => setState(() {
                                    _search = '';
                                    _searchCtrl.clear();
                                  }),
                                ),
                          isDense: true,
                          filled: true,
                          fillColor: const Color(0xFFEFEDF5),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            // -------- Active filter chips --------
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
                          label: Text(v,
                              style: const TextStyle(fontSize: 11)),
                          onDeleted: () => _removeFilterValue(v),
                          backgroundColor: scheme.primary.withOpacity(0.1),
                          labelStyle: TextStyle(color: scheme.primary),
                          deleteIconColor: scheme.primary,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          side: BorderSide.none,
                        ),
                    TextButton(
                      onPressed: _clearAll,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Clear',
                          style: TextStyle(
                              fontSize: 11,
                              decoration: TextDecoration.underline,
                              color: Colors.black54)),
                    ),
                  ],
                ),
              ),

            // -------- List --------
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('No transactions found',
                              style: TextStyle(color: Colors.black54)),
                          if (_activeFilterCount > 0)
                            TextButton(
                              onPressed: _clearAll,
                              child: const Text('Clear filters'),
                            ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: groups.length,
                      itemBuilder: (_, gi) {
                        final group = groups[gi];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Date header with divider line.
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [ IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () {
        if (widget.onBack != null) {
          widget.onBack!();   // 👈 go back to Home
        } else {
          Navigator.pop(context);
        }
      },
    ),
                                    Text(
                                      _formatDateHeader(group.key),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Expanded(child: Divider(height: 1)),
                                  ],
                                ),
                              ),
                              // Card with transactions for this date.
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                  border: Border.all(
                                      color: const Color(0xFFEEEAF3)),
                                ),
                                child: Column(
                                  children: [
                                    for (var i = 0;
                                        i < group.value.length;
                                        i++)
                                      _buildTxRow(
                                        group.value[i],
                                        isLast: i == group.value.length - 1,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      
    );
  }

  Widget _buildTxRow(Tx tx, {required bool isLast}) {
    final isFailed = tx.status == 'Failed';
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFF1EEF6), width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar/icon
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFF1EEF6),
              shape: BoxShape.circle,
            ),
            child: Text(tx.icon, style: const TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 10),
          // Middle column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: isFailed ? Colors.black45 : Colors.black87,
                    decoration:
                        isFailed ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(_modeIcon(tx.mode),
                        size: 11, color: Colors.black45),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '${tx.mode}${tx.card.isNotEmpty ? ' ${tx.card}' : ''} • ${tx.time}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 10, color: Colors.black54),
                      ),
                    ),
                    if (isFailed) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Failed',
                            style: TextStyle(
                                fontSize: 9,
                                color: Colors.red,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 10, color: Colors.black38),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        tx.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 9, color: Colors.black45),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Amount
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isFailed)
                const Icon(Icons.error_outline,
                    size: 14, color: Colors.red),
              const SizedBox(width: 4),
              Text(
                '${tx.type == 'sent' ? '- ' : '+ '}₹${_formatAmount(tx.amount)}',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  decoration:
                      isFailed ? TextDecoration.lineThrough : null,
                  color: isFailed
                      ? Colors.black45
                      : (tx.type == 'sent'
                          ? Colors.red
                          : const Color(0xFF15803D)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------- Filters page ----------
class _FiltersPage extends StatefulWidget {
  final Map<String, Set<String>> initial;
  const _FiltersPage({required this.initial});

  @override
  State<_FiltersPage> createState() => _FiltersPageState();
}

class _FiltersPageState extends State<_FiltersPage> {
  static const _tabs = [
    'Months',
    'Categories',
    'Instruments',
    'Payment status',
    'Payment types',
  ];

  static const Map<String, String> _tabKey = {
    'Months': 'months',
    'Categories': 'categories',
    'Instruments': 'instruments',
    'Payment status': 'paymentStatus',
    'Payment types': 'paymentTypes',
  };

  static const Map<String, List<String>> _options = {
    'Months': [
      'Apr 2026', 'Mar 2026', 'Feb 2026', 'Jan 2026',
      'Dec 2025', 'Nov 2025', 'Oct 2025', 'Sept 2025',
      'Aug 2025', 'Jul 2025', 'Jun 2025', 'May 2025',
      'Apr 2025', 'Mar 2025',
    ],
    'Categories': [
      'Money sent',
      'Money received',
      'Merchant payments',
      'UPI Lite add money & closure',
    ],
    'Instruments': ['UPI/Bank account', 'UPI Lite'],
    'Payment status': ['Failed', 'Successful'],
    'Payment types': ['IPO & external autoPay'],
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

  int get _totalSelected =>
      _local.values.fold(0, (s, set) => s + set.length);

  void _toggle(String value) {
    final k = _tabKey[_activeTab]!;
    setState(() {
      final set = _local[k]!;
      if (set.contains(value)) {
        set.remove(value);
      } else {
        set.add(value);
      }
    });
  }

  void _clearAll() {
    setState(() {
      for (final k in _local.keys) {
        _local[k]!.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final activeKey = _tabKey[_activeTab]!;
    final selected = _local[activeKey]!;
    final options = _options[_activeTab]!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                border: Border(
                    bottom:
                        BorderSide(color: Color(0xFFEEEAF3), width: 1)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Text(
                    'Filters',
                    style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _clearAll,
                    child: const Text('Clear all',
                        style: TextStyle(color: Colors.black54)),
                  ),
                ],
              ),
            ),
            // Body: two columns
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left tab list
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.38,
                    child: Container(
                      color: const Color(0xFFF8F7FB),
                      child: ListView.builder(
                        itemCount: _tabs.length,
                        itemBuilder: (_, i) {
                          final tab = _tabs[i];
                          final isActive = tab == _activeTab;
                          final count = _local[_tabKey[tab]]!.length;
                          return InkWell(
                            onTap: () => setState(() => _activeTab = tab),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(
                                color: isActive ? Colors.white : null,
                                border: Border(
                                  left: BorderSide(
                                    color: isActive
                                        ? scheme.primary
                                        : Colors.transparent,
                                    width: 2.5,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      tab,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: isActive
                                            ? Colors.black87
                                            : Colors.black54,
                                      ),
                                    ),
                                  ),
                                  if (count > 0)
                                    Container(
                                      width: 18,
                                      height: 18,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: scheme.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text('$count',
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Right options
                  Expanded(
                    child: ListView.builder(
                      itemCount: options.length,
                      itemBuilder: (_, i) {
                        final opt = options[i];
                        final isSel = selected.contains(opt);
                        return InkWell(
                          onTap: () => _toggle(opt),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    color: Color(0xFFF1EEF6), width: 1),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Text(opt,
                                        style:
                                            const TextStyle(fontSize: 13.5))),
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: isSel
                                        ? scheme.primary
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isSel
                                          ? scheme.primary
                                          : Colors.black26,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: isSel
                                      ? const Icon(Icons.check,
                                          size: 14, color: Colors.white)
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Apply button (above bottom safe area)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                    top: BorderSide(color: Color(0xFFEEEAF3), width: 1)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(_local),
                  child: Text(
                    _totalSelected > 0
                        ? 'Apply ($_totalSelected)'
                        : 'Apply',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
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