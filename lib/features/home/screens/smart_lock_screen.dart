// smartlock_screen.dart
// Single-file Flutter implementation of the Smart Lock banking screen.
// Mirrors the React/Tailwind app: status card, emergency freeze (hold-to-confirm
// + unfreeze), security activity (login history), night lock scheduler,
// international usage default-on, granular controls, and bottom nav.
//
// Drop this file into lib/ and use SmartLockScreen() as your home widget.
// Add to pubspec.yaml:
//   google_fonts: ^6.1.0

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
// THEME
// ─────────────────────────────────────────────────────────────────────────────

class AppColors {
  static const primary = Color(0xFF2E9461);
static const primaryGlow = Color(0xFF5CCFA0);
  static const primaryFg = Colors.white;
  static const background = Color(0xFFF8FAFC);
  static const card = Colors.white;
  static const border = Color(0xFFE2E8F0);
  static const muted = Color(0xFFF1F5F9);
  static const mutedFg = Color(0xFF64748B);
  static const foreground = Color(0xFF0F172A);
  static const destructive = Color(0xFFDC2626);
  static const destructiveFg = Colors.white;
}

TextStyle _font(double size, FontWeight w, [Color c = AppColors.foreground]) =>
    GoogleFonts.plusJakartaSans(fontSize: size, fontWeight: w, color: c);

// ─────────────────────────────────────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────────────────────────────────────

class LockFeature {
  final String id;
  final IconData icon;
  final String title;
  final String description;
  const LockFeature(this.id, this.icon, this.title, this.description);
}

const List<LockFeature> _features = [
  LockFeature('schedule', Icons.access_time_rounded, 'Night Lock (11PM–6AM)',
      'Auto-freeze account during night hours'),
  LockFeature('international', Icons.public_rounded, 'International Usage',
      'Blocked by default — disable only when travelling abroad'),
  LockFeature('card', Icons.credit_card_rounded, 'Freeze Debit Card',
      'Block all debit card transactions instantly'),
  LockFeature('online', Icons.language_rounded, 'Online Transactions',
      'Disable internet banking & online payments'),
  LockFeature('upi', Icons.smartphone_rounded, 'UPI Payments',
      'Block all UPI-based fund transfers'),
  LockFeature('pos', Icons.shopping_cart_rounded, 'POS / Swipe',
      'Disable point-of-sale terminal transactions'),
  LockFeature('atm', Icons.account_balance_wallet_rounded, 'ATM Withdrawal',
      'Block cash withdrawals from ATMs'),
  LockFeature('qr', Icons.qr_code_rounded, 'QR Code Payments',
      'Disable scan-and-pay QR transactions'),
];

class LoginItem {
  final String device;
  final String time;
  const LoginItem(this.device, this.time);
}

const List<LoginItem> _loginLog = [
  LoginItem('Mobile Banking App · iPhone 15 Pro', 'Today, 10:42 AM'),
  LoginItem('Net Banking · Chrome · MacBook', 'Yesterday, 08:30 PM'),
  LoginItem('Mobile Banking App · iPhone 15 Pro', 'Yesterday, 09:15 AM'),
  LoginItem('Mobile Banking App · iPhone 15 Pro', '2 days ago, 07:48 PM'),
  LoginItem('Net Banking · Safari · iPad', '3 days ago, 11:02 AM'),
  LoginItem('Mobile Banking App · iPhone 15 Pro', '4 days ago, 08:30 AM'),
];

// ─────────────────────────────────────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class SmartLockScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const SmartLockScreen({super.key, this.onBack});

  @override
  State<SmartLockScreen> createState() => _SmartLockScreenState();
}

class _SmartLockScreenState extends State<SmartLockScreen> {
  bool _accountLocked = false;
  late Map<String, bool> _toggles;
  TimeOfDay _nightStart = const TimeOfDay(hour: 23, minute: 0);
  TimeOfDay _nightEnd = const TimeOfDay(hour: 6, minute: 0);

  @override
  void initState() {
    super.initState();
    _toggles = {for (final f in _features) f.id: f.id == 'international'};
  }

  String _fmt(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final p = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $p';
  }

  void _emergencyFreeze() {
    setState(() {
      _accountLocked = true;
      _toggles = {for (final f in _features) f.id: true};
    });
    _toast('Emergency freeze activated', 'All account activity has been blocked.',
        AppColors.destructive);
  }

  void _emergencyUnfreeze() {
    setState(() {
      _accountLocked = false;
      _toggles = {for (final f in _features) f.id: f.id == 'international'};
    });
    _toast('Emergency freeze lifted', 'Your account activity has been restored.',
        AppColors.primary);
  }

  void _toggleFeature(String id) {
    if (id == 'schedule') {
      if (!(_toggles[id] ?? false)) {
        _openNightLockSheet();
      } else {
        setState(() {
          _toggles[id] = false;
          if (_toggles.values.every((v) => !v)) _accountLocked = false;
        });
      }
      return;
    }
    setState(() {
      _toggles[id] = !(_toggles[id] ?? false);
      if (_toggles.values.every((v) => !v)) _accountLocked = false;
    });
  }

  void _toast(String title, String desc, Color color) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: _font(14, FontWeight.w700, Colors.white)),
              const SizedBox(height: 2),
              Text(desc, style: _font(12, FontWeight.w500, Colors.white70)),
            ],
          ),
        ),
      );
  }

  void _openNightLockSheet() async {
    final result = await showModalBottomSheet<Map<String, TimeOfDay>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NightLockSheet(start: _nightStart, end: _nightEnd),
    );
    if (result != null) {
      setState(() {
        _nightStart = result['start']!;
        _nightEnd = result['end']!;
        _toggles['schedule'] = true;
      });
    }
  }

  void _openSecurityActivity() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _SecurityActivitySheet(),
    );
  }

  void _openEmergencyConfirm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EmergencyConfirmSheet(onConfirmed: _emergencyFreeze),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 448),
            child: Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.only(bottom: 110),
                  children: [
                    const _SmartLockHeader(),
                    _LockStatusCard(isLocked: _accountLocked),
                    _EmergencyFreezeButton(
                      isFrozen: _accountLocked,
                      onFreeze: _openEmergencyConfirm,
                      onUnfreeze: _emergencyUnfreeze,
                    ),
                    _SecurityActivityButton(onTap: _openSecurityActivity),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                      child: Text('SECURITY CONTROLS',
                          style: _font(12, FontWeight.w800, AppColors.mutedFg)
                              .copyWith(letterSpacing: 1.2)),
                    ),
                    ..._features.map((f) {
                      final on = _toggles[f.id] ?? false;
                      String title = f.title;
                      String desc = f.description;
                      if (f.id == 'schedule' && on) {
                        title =
                            'Night Lock (${_fmt(_nightStart)} – ${_fmt(_nightEnd)})';
                        desc = 'Tap to change schedule';
                      }
                      return Padding(
                        padding:
                            const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        child: _LockToggleItem(
                          icon: f.icon,
                          title: title,
                          description: desc,
                          enabled: on,
                          onChanged: (_) => _toggleFeature(f.id),
                        ),
                      );
                    }),
                  ],
                ),
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────────────────────────────────────

class _SmartLockHeader extends StatelessWidget {
  final VoidCallback? onBack; // ✅ ADD THIS

  const _SmartLockHeader({this.onBack}); // ✅ ADD THIS

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                onBack?.call(); // ✅ FIXED
              }
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.muted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_rounded),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Smart Lock', style: _font(20, FontWeight.w800)),
                Text(
                  'Account Security Center',
                  style: _font(12, FontWeight.w500, AppColors.mutedFg),
                ),
              ],
            ),
          ),

          
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STATUS CARD (display only — no toggling)
// ─────────────────────────────────────────────────────────────────────────────

class _LockStatusCard extends StatelessWidget {
  final bool isLocked;
  const _LockStatusCard({required this.isLocked});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            top: -32,
            right: -32,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Account Status',
                            style: _font(13, FontWeight.w500,
                                Colors.white.withOpacity(0.7))),
                        const SizedBox(height: 4),
                        Text(
                          isLocked ? 'Account Frozen' : 'Account Active',
                          style: _font(22, FontWeight.w800, Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isLocked
                              ? 'All transactions are blocked'
                              : 'All services are running normally',
                          style: _font(13, FontWeight.w500,
                              Colors.white.withOpacity(0.6)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: isLocked
                          ? AppColors.destructive
                          : Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      isLocked
                          ? Icons.gpp_bad_rounded
                          : Icons.shield_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color:
                          isLocked ? AppColors.destructive : Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isLocked
                          ? 'Protection active — use Emergency Freeze to unlock'
                          : 'Use Emergency Freeze below to lock account',
                      style: _font(11, FontWeight.w500,
                          Colors.white.withOpacity(0.75)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMERGENCY FREEZE BUTTON + CONFIRM SHEET (hold to freeze)
// ─────────────────────────────────────────────────────────────────────────────

class _EmergencyFreezeButton extends StatelessWidget {
  final bool isFrozen;
  final VoidCallback onFreeze;
  final VoidCallback onUnfreeze;
  const _EmergencyFreezeButton({
    required this.isFrozen,
    required this.onFreeze,
    required this.onUnfreeze,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: SizedBox(
        height: 48,
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: isFrozen ? onUnfreeze : onFreeze,
          icon: Icon(
            isFrozen ? Icons.verified_user_rounded : Icons.warning_rounded,
            size: 18,
          ),
          label: Text(
            isFrozen ? 'Unfreeze Account' : 'Emergency Freeze',
            style: _font(14, FontWeight.w700, Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isFrozen ? AppColors.primary : AppColors.destructive,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
    );
  }
}

class _EmergencyConfirmSheet extends StatefulWidget {
  final VoidCallback onConfirmed;
  const _EmergencyConfirmSheet({required this.onConfirmed});
  @override
  State<_EmergencyConfirmSheet> createState() => _EmergencyConfirmSheetState();
}

class _EmergencyConfirmSheetState extends State<_EmergencyConfirmSheet> {
  double _progress = 0;
  Timer? _timer;

  void _start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 30), (t) {
      setState(() => _progress = (_progress + 2).clamp(0, 100));
      if (_progress >= 100) {
        t.cancel();
        Navigator.of(context).pop();
        widget.onConfirmed();
      }
    });
  }

  void _stop() {
    _timer?.cancel();
    setState(() => _progress = 0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bullets = const [
      'All debit/credit card transactions will be blocked',
      'UPI, net banking & ATM access will be disabled',
      'International transactions will be suspended',
      'You can unfreeze anytime from this screen',
    ];
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text('Confirm Emergency Freeze',
                    style: _font(18, FontWeight.w800)),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded,
                    color: AppColors.mutedFg),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...bullets.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(b,
                          style:
                              _font(13, FontWeight.w500, AppColors.mutedFg)),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 16),
          GestureDetector(
            onTapDown: (_) => _start(),
            onTapUp: (_) => _stop(),
            onTapCancel: _stop,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.destructive,
                borderRadius: BorderRadius.circular(18),
              ),
              clipBehavior: Clip.hardEdge,
              child: Stack(
                children: [
                  FractionallySizedBox(
                    widthFactor: _progress / 100,
                    child: Container(color: Colors.white.withOpacity(0.2)),
                  ),
                  Center(
                    child: Text(
                      _progress > 0
                          ? 'Freezing... ${_progress.toInt()}%'
                          : 'Hold to Freeze Account',
                      style: _font(14, FontWeight.w800, Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text('Press and hold for 1.5 seconds',
                style: _font(11, FontWeight.w500, AppColors.mutedFg)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECURITY ACTIVITY
// ─────────────────────────────────────────────────────────────────────────────

class _SecurityActivityButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SecurityActivityButton({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: SizedBox(
        height: 48,
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.shield_outlined,
              size: 18, color: AppColors.primary),
          label: Text('Security Activity',
              style: _font(14, FontWeight.w700, AppColors.primary)),
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
    );
  }
}

class _SecurityActivitySheet extends StatelessWidget {
  const _SecurityActivitySheet();
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.shield_rounded,
                    size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Security Activity',
                      style: _font(18, FontWeight.w800)),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.mutedFg),
                ),
              ],
            ),
            Text('Recent logins on your account',
                style: _font(12, FontWeight.w500, AppColors.mutedFg)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                controller: controller,
                itemCount: _loginLog.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final item = _loginLog[i];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.smartphone_rounded,
                              color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Logged in',
                                  style: _font(13, FontWeight.w700)),
                              const SizedBox(height: 2),
                              Text(item.device,
                                  style: _font(11, FontWeight.w500,
                                      AppColors.mutedFg)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.access_time_rounded,
                                      size: 12,
                                      color: AppColors.mutedFg),
                                  const SizedBox(width: 4),
                                  Text(item.time,
                                      style: _font(11, FontWeight.w500,
                                          AppColors.mutedFg)),
                                ],
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
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                border:
                    Border.all(color: AppColors.primary.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Don't recognize a login? Tap Emergency Freeze immediately.",
                      style:
                          _font(11, FontWeight.w600, AppColors.foreground),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOCK TOGGLE ITEM
// ─────────────────────────────────────────────────────────────────────────────

class _LockToggleItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool enabled;
  final ValueChanged<bool> onChanged;
  const _LockToggleItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: enabled
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.muted,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon,
                size: 20,
                color:
                    enabled ? AppColors.primary : AppColors.mutedFg),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: _font(13, FontWeight.w700)),
                const SizedBox(height: 2),
                Text(description,
                    style:
                        _font(11, FontWeight.w500, AppColors.mutedFg)),
              ],
            ),
          ),
          Switch(
            value: enabled,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NIGHT LOCK SHEET
// ─────────────────────────────────────────────────────────────────────────────

class _NightLockSheet extends StatefulWidget {
  final TimeOfDay start;
  final TimeOfDay end;
  const _NightLockSheet({required this.start, required this.end});
  @override
  State<_NightLockSheet> createState() => _NightLockSheetState();
}

class _NightLockSheetState extends State<_NightLockSheet> {
  late TimeOfDay _start;
  late TimeOfDay _end;

  @override
  void initState() {
    super.initState();
    _start = widget.start;
    _end = widget.end;
  }

  String _fmt(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final p = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $p';
  }

  Future<void> _pick(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _start : _end,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _start = picked;
        } else {
          _end = picked;
        }
      });
    }
  }

  Widget _row(String label, TimeOfDay t, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: _font(11, FontWeight.w800, AppColors.mutedFg)
                .copyWith(letterSpacing: 1.2)),
        const SizedBox(height: 10),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.card,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time_rounded,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Text(_fmt(t),
                    style: _font(15, FontWeight.w700, AppColors.foreground)),
                const Spacer(),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.mutedFg),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.access_time_rounded,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text('Set Night Lock Schedule',
                  style: _font(18, FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Choose when to auto-freeze your account',
              style: _font(12, FontWeight.w500, AppColors.mutedFg)),
          const SizedBox(height: 24),
          _row('Start Time', _start, () => _pick(true)),
          const SizedBox(height: 16),
          _row('End Time', _end, () => _pick(false)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(
                  context, {'start': _start, 'end': _end}),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('Set Night Lock Schedule',
                  style: _font(14, FontWeight.w800, Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOTTOM NAV
// ─────────────────────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  const _BottomNav();
  @override
  Widget build(BuildContext context) {
    final items = const [
      [Icons.home_rounded, 'Home'],
      [Icons.swap_horiz_rounded, 'Pay'],
      [Icons.shield_rounded, 'Lock'],
      [Icons.person_rounded, 'Profile'],
    ];
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final active = i == 2;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(items[i][0] as IconData,
                  size: 22,
                  color:
                      active ? AppColors.primary : AppColors.mutedFg),
              const SizedBox(height: 4),
              Text(items[i][1] as String,
                  style: _font(
                      10,
                      active ? FontWeight.w800 : FontWeight.w600,
                      active ? AppColors.primary : AppColors.mutedFg)),
            ],
          );
        }),
      ),
    );
  }
}
