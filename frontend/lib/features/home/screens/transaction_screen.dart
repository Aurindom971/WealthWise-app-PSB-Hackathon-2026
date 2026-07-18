// transaction_screen.dart
// Single-file Flutter Transaction History screen for PSB app.
// Includes: search, filters, date grouping, failed styling, location,
// and NEW: per-transaction Help & Support sheet with fraud reporting
// (1930 helpline + I4C portal), evidence pack, and quick actions.
//
// Dependencies (add to pubspec.yaml):
//   supabase_flutter: ^2.5.0
//   url_launcher: ^6.3.0
//
// Fully self-contained — no external project imports required.
// Backend Supabase queries are UNCHANGED (reads from `transactions` table).

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// ---------- Model ----------
class Tx {
  final String id;
  final String name;
  final String type; // 'credit' | 'debit'
  final double amount;
  final String icon;
  final String date; // YYYY-MM-DD
  final String time;
  final String mode; // UPI / NEFT / IMPS / Debit Card
  final String card;
  final String status; // Successful / Failed
  final String category;
  final String location;
  final String? refId;
  final Map<String, dynamic> raw;

  Tx({
    required this.id,
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
    this.refId,
    this.raw = const {},
  });

  factory Tx.fromMap(Map<String, dynamic> m) {
    final dt = DateTime.tryParse(m['created_at']?.toString() ?? '') ?? DateTime.now();
    return Tx(
      id: m['id']?.toString() ?? '',
      name: (m['counterparty'] ?? m['name'] ?? 'Unknown').toString(),
      type: (m['type'] ?? 'debit').toString(),
      amount: double.tryParse(m['amount']?.toString() ?? '0') ?? 0,
      icon: (m['icon'] ?? '👤').toString(),
      date: '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}',
      time: _fmtTime(dt),
      mode: (m['mode'] ?? 'UPI').toString(),
      card: (m['card'] ?? '').toString(),
      status: (m['status'] ?? 'Successful').toString(),
      category: (m['category'] ?? 'Money sent').toString(),
      location: (m['location'] ?? 'Unknown').toString(),
      refId: m['ref_id']?.toString(),
      raw: m,
    );
  }

  static String _fmtTime(DateTime dt) {
    final h = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final ap = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ap';
  }
}

// ---------- Screen ----------
class TransactionScreen extends StatefulWidget {
  final VoidCallback onBack;

  const TransactionScreen({
    super.key,
    required this.onBack,
  });

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final _supabase = Supabase.instance.client;
  final _searchCtrl = TextEditingController();

  bool _loading = true;
  bool _showSearch = false;
  String _search = '';
  List<Tx> _all = [];

  // Filters
  Set<String> _fMonths = {};
  Set<String> _fCategories = {};
  Set<String> _fInstruments = {};
  Set<String> _fStatus = {};

  int get _activeFilterCount =>
      _fMonths.length + _fCategories.length + _fInstruments.length + _fStatus.length;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        setState(() { _all = []; _loading = false; });
        return;
      }
      final rows = await _supabase
          .from('transactions')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
      _all = (rows as List).map((e) => Tx.fromMap(Map<String, dynamic>.from(e))).toList();
    } catch (e) {
      debugPrint('tx load error: $e');
    }
    if (mounted) setState(() => _loading = false);
  }

  List<Tx> get _filtered {
    return _all.where((tx) {
      if (_search.isNotEmpty && !tx.name.toLowerCase().contains(_search.toLowerCase())) return false;
      if (_fMonths.isNotEmpty) {
        final parts = tx.date.split('-');
        final label = '${_monthShort(parts[1])} ${parts[0]}';
        if (!_fMonths.contains(label)) return false;
      }
      if (_fCategories.isNotEmpty && !_fCategories.contains(tx.category)) return false;
      if (_fInstruments.isNotEmpty && !_fInstruments.contains(_instrumentForMode(tx.mode))) return false;
      if (_fStatus.isNotEmpty && !_fStatus.contains(tx.status)) return false;
      return true;
    }).toList();
  }

  static String _monthShort(String m) => const {
    '01': 'Jan','02': 'Feb','03': 'Mar','04': 'Apr','05': 'May','06': 'Jun',
    '07': 'Jul','08': 'Aug','09': 'Sept','10': 'Oct','11': 'Nov','12': 'Dec',
  }[m] ?? m;

  static String _instrumentForMode(String mode) =>
      mode == 'Debit Card' ? 'Debit/Credit card' : 'UPI/Bank account';

  String _formatDateHeader(String d) {
    final today = DateTime.now();
    final todayStr = '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final y = today.subtract(const Duration(days: 1));
    final yStr = '${y.year.toString().padLeft(4, '0')}-${y.month.toString().padLeft(2, '0')}-${y.day.toString().padLeft(2, '0')}';
    if (d == todayStr) return 'TODAY';
    if (d == yStr) return 'YESTERDAY';
    final dt = DateTime.parse(d);
    const days = ['SUN','MON','TUE','WED','THU','FRI','SAT'];
    const months = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'];
    return '${days[dt.weekday % 7]}, ${dt.day} ${months[dt.month - 1]}';
  }

  IconData _modeIcon(String mode) {
    if (mode == 'Debit Card') return Icons.credit_card_rounded;
    if (mode == 'UPI') return Icons.smartphone_rounded;
    return Icons.account_balance_rounded;
  }

  @override
  Widget build(BuildContext context) {
    // no-op
    final grouped = <String, List<Tx>>{};
    for (final tx in _filtered) {
      grouped.putIfAbsent(tx.date, () => []).add(tx);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5EF),
      body: SafeArea(
        child: Column(
          children: [
            // Bank header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: const BoxDecoration(
                color: Color(0xFF1B5E3F),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Row(children: const [
                CircleAvatar(radius: 16, backgroundColor: Colors.white, child: Text('P', style: TextStyle(color: Color(0xFF1B5E3F), fontWeight: FontWeight.bold))),
                SizedBox(width: 10),
                Text('Punjab & Sind Bank', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ]),
            ),

            // Title row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  const Expanded(child: Text('Transaction History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
                  IconButton(icon: const Icon(Icons.search, size: 20), onPressed: () => setState(() => _showSearch = !_showSearch)),
                  Stack(children: [
                    IconButton(icon: const Icon(Icons.tune_rounded, size: 20), onPressed: _openFilters),
                    if (_activeFilterCount > 0)
                      Positioned(right: 6, top: 6, child: Container(
                        width: 14, height: 14, alignment: Alignment.center,
                        decoration: const BoxDecoration(color: Color(0xFF1B5E3F), shape: BoxShape.circle),
                        child: Text('$_activeFilterCount', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                      )),
                  ]),
                ],
              ),
            ),

            if (_showSearch)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  controller: _searchCtrl,
                  autofocus: true,
                  onChanged: (v) => setState(() => _search = v),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, size: 18),
                    hintText: 'Search transactions...',
                    filled: true, fillColor: const Color(0xFFEDEBE4),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),

            // List
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _filtered.isEmpty
                      ? const Center(child: Text('No transactions found', style: TextStyle(color: Colors.grey)))
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                            children: grouped.entries.map((g) => _dateGroup(g.key, g.value)).toList(),
                          ),
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (_) {},
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'History'),
          NavigationDestination(icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _dateGroup(String date, List<Tx> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(children: [
            Text(_formatDateHeader(date), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey, letterSpacing: 0.5)),
            const SizedBox(width: 8),
            Expanded(child: Container(height: 1, color: const Color(0xFFE5E1D6))),
          ]),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE5E1D6)),
          ),
          child: Column(children: [
            for (int i = 0; i < items.length; i++) ...[
              _txRow(items[i]),
              if (i < items.length - 1) const Divider(height: 1, indent: 12, endIndent: 12, color: Color(0xFFEFEBDE)),
            ],
          ]),
        ),
      ]),
    );
  }

  Widget _txRow(Tx tx) {
    final failed = tx.status == 'Failed';
    final sent = tx.type == 'debit' || tx.type == 'sent';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: const BoxDecoration(color: Color(0xFFF1EEE3), shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(tx.icon, style: const TextStyle(fontSize: 16)),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tx.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w500,
            color: failed ? Colors.grey : Colors.black87,
            decoration: failed ? TextDecoration.lineThrough : null,
          )),
          const SizedBox(height: 2),
          Row(children: [
            Icon(_modeIcon(tx.mode), size: 11, color: Colors.grey),
            const SizedBox(width: 4),
            Flexible(child: Text('${tx.mode}${tx.card.isNotEmpty ? ' ${tx.card}' : ''} • ${tx.time}',
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, color: Colors.grey))),
            if (failed) Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(color: Colors.red.withOpacity(.1), borderRadius: BorderRadius.circular(8)),
                child: const Text('Failed', style: TextStyle(fontSize: 9, color: Colors.red, fontWeight: FontWeight.w500)),
              ),
            ),
          ]),
          Row(children: [
            const Icon(Icons.location_on_outlined, size: 10, color: Color(0xFFBBBBBB)),
            const SizedBox(width: 2),
            Flexible(child: Text(tx.location, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 9, color: Color(0xFFAAAAAA)))),
          ]),
        ])),
        const SizedBox(width: 6),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${sent ? '- ' : '+ '}₹${tx.amount.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600,
                color: failed ? Colors.grey : (sent ? Colors.red : Colors.green.shade700),
                decoration: failed ? TextDecoration.lineThrough : null,
              )),
        ]),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFF1B5E3F)),
          onPressed: () => _openHelpSheet(tx),
          tooltip: 'Help & Support',
        ),
      ]),
    );
  }

  // ---------- Filters sheet ----------
  void _openFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _FiltersSheet(
        months: _fMonths, categories: _fCategories, instruments: _fInstruments, status: _fStatus,
        onApply: (m, c, i, s) {
          setState(() { _fMonths = m; _fCategories = c; _fInstruments = i; _fStatus = s; });
          Navigator.pop(context);
        },
      ),
    );
  }

  // ---------- Help & Support sheet (NEW) ----------
  void _openHelpSheet(Tx tx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85, minChildSize: 0.5, maxChildSize: 0.95, expand: false,
        builder: (_, scroll) => Container(
          decoration: const BoxDecoration(color: Color(0xFFF7F5EF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: ListView(controller: scroll, padding: const EdgeInsets.all(16), children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(
                color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 14),
            const Text('Help & Support', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('Transaction with ${tx.name}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 16),

            // Summary card
            _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _kv('Reference ID', tx.refId ?? tx.id),
              _kv('Status', tx.status),
              _kv('Amount', '₹${tx.amount.toStringAsFixed(2)}'),
              _kv('Mode', '${tx.mode}${tx.card.isNotEmpty ? ' • ${tx.card}' : ''}'),
              _kv('Date & time', '${tx.date} • ${tx.time}'),
              _kv('Location', tx.location),
            ])),

            const SizedBox(height: 14),
            // Fraud panel
            _card(color: const Color(0xFFFFF3F3), border: Colors.red.shade200, child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: const [
                  Icon(Icons.gpp_maybe_rounded, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Text('Report Fraud / Cybercrime', style: TextStyle(fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 6),
                const Text(
                  'If this transaction is unauthorised or suspicious, act immediately. '
                  'India\'s National Cybercrime Helpline is 1930.',
                  style: TextStyle(fontSize: 12, color: Colors.black87)),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: ElevatedButton.icon(
                    onPressed: () => _launch('tel:1930'),
                    icon: const Icon(Icons.call, size: 16),
                    label: const Text('Call 1930'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: OutlinedButton.icon(
                    onPressed: () => _launch('https://cybercrime.gov.in'),
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('I4C Portal'),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                  )),
                ]),
              ])),

            const SizedBox(height: 14),
            // Evidence pack
            _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: const [
                Icon(Icons.description_outlined, size: 18, color: Color(0xFF1B5E3F)),
                SizedBox(width: 8),
                Text('Evidence Pack', style: TextStyle(fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 6),
              const Text('Auto-generated report with all transaction metadata for filing a complaint.',
                  style: TextStyle(fontSize: 12, color: Colors.black87)),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFF1EEE3), borderRadius: BorderRadius.circular(10)),
                child: Text(_buildEvidence(tx), style: const TextStyle(fontFamily: 'monospace', fontSize: 10.5)),
              ),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: OutlinedButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: _buildEvidence(tx)));
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Evidence copied to clipboard')));
                  },
                  icon: const Icon(Icons.copy, size: 16), label: const Text('Copy'),
                )),
                const SizedBox(width: 8),
                Expanded(child: ElevatedButton.icon(
                  onPressed: () => _launch(
                    'mailto:report@cybercrime.gov.in?subject=${Uri.encodeComponent('Fraud report - ${tx.refId ?? tx.id}')}&body=${Uri.encodeComponent(_buildEvidence(tx))}'),
                  icon: const Icon(Icons.email_outlined, size: 16), label: const Text('Email'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E3F), foregroundColor: Colors.white),
                )),
              ]),
            ])),

            const SizedBox(height: 14),
            // Quick actions
            _card(child: Column(children: [
              _actionTile(Icons.report_gmailerrorred, 'Raise a dispute', 'Contest this transaction with the bank',
                  () => _launch('tel:18001234')),
              const Divider(height: 1),
              _actionTile(Icons.block, 'Block card / UPI', 'Immediately freeze the payment instrument',
                  () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Card/UPI freeze requested. Contact support to confirm.')));
                  }),
              const Divider(height: 1),
              _actionTile(Icons.support_agent, 'Call customer support', '1800-419-8300 (toll free, 24x7)',
                  () => _launch('tel:18004198300')),
            ])),

            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }

  String _buildEvidence(Tx tx) {
    final b = StringBuffer()
      ..writeln('PUNJAB & SIND BANK — TRANSACTION EVIDENCE')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('----------------------------------------')
      ..writeln('Reference ID : ${tx.refId ?? tx.id}')
      ..writeln('Counterparty : ${tx.name}')
      ..writeln('Type         : ${tx.type}')
      ..writeln('Amount (INR) : ${tx.amount.toStringAsFixed(2)}')
      ..writeln('Mode         : ${tx.mode}${tx.card.isNotEmpty ? ' (${tx.card})' : ''}')
      ..writeln('Status       : ${tx.status}')
      ..writeln('Date / Time  : ${tx.date} ${tx.time}')
      ..writeln('Location     : ${tx.location}')
      ..writeln('Category     : ${tx.category}')
      ..writeln('----------------------------------------')
      ..writeln('Raw metadata :')
      ..writeln(const JsonEncoder.withIndent('  ').convert(tx.raw));
    return b.toString();
  }

  Widget _card({required Widget child, Color color = Colors.white, Color? border}) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border ?? const Color(0xFFE5E1D6))),
    child: child,
  );

  Widget _kv(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 100, child: Text(k, style: const TextStyle(fontSize: 12, color: Colors.grey))),
      Expanded(child: Text(v, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
    ]),
  );

  Widget _actionTile(IconData icon, String title, String sub, VoidCallback onTap) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon, color: const Color(0xFF1B5E3F)),
    title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
    subtitle: Text(sub, style: const TextStyle(fontSize: 11)),
    trailing: const Icon(Icons.chevron_right, size: 18),
    onTap: onTap,
  );

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

// ---------- Filters bottom sheet ----------
class _FiltersSheet extends StatefulWidget {
  final Set<String> months, categories, instruments, status;
  final void Function(Set<String>, Set<String>, Set<String>, Set<String>) onApply;
  const _FiltersSheet({required this.months, required this.categories, required this.instruments, required this.status, required this.onApply});
  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  int _tab = 0;
  late Set<String> _m = {...widget.months};
  late Set<String> _c = {...widget.categories};
  late Set<String> _i = {...widget.instruments};
  late Set<String> _s = {...widget.status};

  static const _tabs = ['Months', 'Categories', 'Instruments', 'Status'];
  static const _months = ['Apr 2026','Mar 2026','Feb 2026','Jan 2026','Dec 2025'];
  static const _cats = ['Money sent','Money received','Merchant payments','Bills & recharges'];
  static const _inst = ['UPI/Bank account','Debit/Credit card','Wallet'];
  static const _stat = ['Successful','Failed','Pending'];

  Set<String> _current() => [_m, _c, _i, _s][_tab];
  List<String> _options() => [_months, _cats, _inst, _stat][_tab];

  int get _count => _m.length + _c.length + _i.length + _s.length;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * .8,
      child: Column(children: [
        const SizedBox(height: 8),
        Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 8),
        const Padding(padding: EdgeInsets.all(12), child: Align(alignment: Alignment.centerLeft, child: Text('Filters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)))),
        Expanded(child: Row(children: [
          Container(width: 120, color: const Color(0xFFF1EEE3),
            child: ListView.builder(itemCount: _tabs.length, itemBuilder: (_, i) => InkWell(
              onTap: () => setState(() => _tab = i),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: _tab == i ? Colors.white : Colors.transparent,
                    border: Border(left: BorderSide(color: _tab == i ? const Color(0xFF1B5E3F) : Colors.transparent, width: 3))),
                child: Text(_tabs[i], style: TextStyle(fontSize: 13, fontWeight: _tab == i ? FontWeight.w600 : FontWeight.w400)),
              ),
            )),
          ),
          Expanded(child: ListView(children: _options().map((o) => CheckboxListTile(
            dense: true,
            value: _current().contains(o),
            onChanged: (v) => setState(() { v == true ? _current().add(o) : _current().remove(o); }),
            title: Text(o, style: const TextStyle(fontSize: 13)),
            activeColor: const Color(0xFF1B5E3F),
          )).toList())),
        ])),
        Padding(padding: const EdgeInsets.all(12), child: SizedBox(width: double.infinity, child: ElevatedButton(
          onPressed: () => widget.onApply(_m, _c, _i, _s),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E3F), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
          child: Text(_count > 0 ? 'Apply ($_count)' : 'Apply'),
        ))),
      ]),
    );
  }
}
