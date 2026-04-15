import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── DATA MODEL ─────────────────────────────────────────────
class LockFeature {
  final String id;
  final IconData icon;
  final String title;
  final String description;

  const LockFeature({
    required this.id,
    required this.icon,
    required this.title,
    required this.description,
  });
}

// ─── MAIN SCREEN ────────────────────────────────────────────
class SmartLockScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const SmartLockScreen({super.key, this.onBack});

  @override
  State<SmartLockScreen> createState() => _SmartLockScreenState();
}

class _SmartLockScreenState extends State<SmartLockScreen> {
  bool _accountLocked = false;
  late Map<String, bool> _toggles;

  static const _features = [
    LockFeature(
      id: 'schedule',
      icon: Icons.nightlight_round,
      title: 'Night Lock (11PM–6AM)',
      description: 'Auto-freeze account during night hours',
    ),
    LockFeature(
      id: 'card',
      icon: Icons.credit_card,
      title: 'Freeze Debit Card',
      description: 'Block all debit card transactions instantly',
    ),
    LockFeature(
      id: 'online',
      icon: Icons.language,
      title: 'Online Transactions',
      description: 'Disable internet banking & online payments',
    ),
    LockFeature(
      id: 'upi',
      icon: Icons.smartphone,
      title: 'UPI Payments',
      description: 'Block all UPI-based fund transfers',
    ),
    LockFeature(
      id: 'pos',
      icon: Icons.shopping_cart,
      title: 'POS / Swipe',
      description: 'Disable point-of-sale terminal transactions',
    ),
    LockFeature(
      id: 'atm',
      icon: Icons.money,
      title: 'ATM Withdrawal',
      description: 'Block cash withdrawals from ATMs',
    ),
    LockFeature(
      id: 'qr',
      icon: Icons.qr_code,
      title: 'QR Code Payments',
      description: 'Disable scan-and-pay QR transactions',
    ),
    LockFeature(
      id: 'international',
      icon: Icons.pin_drop,
      title: 'International Usage',
      description: 'Block overseas transactions on all channels',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _toggles = {for (var f in _features) f.id: false};
  }

  void _handleAccountToggle() {
    setState(() {
      _accountLocked = !_accountLocked;
      if (_accountLocked) {
        _toggles.updateAll((key, value) => true);
      }
    });
  }

  void _handleEmergencyFreeze() {
    setState(() {
      _accountLocked = true;
      _toggles.updateAll((key, value) => true);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.shield, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text('Emergency freeze activated! All account activity blocked.'),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2E9461),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _handleFeatureToggle(String id) {
    setState(() {
      _toggles[id] = !_toggles[id]!;
      if (_toggles.values.every((v) => !v)) {
        _accountLocked = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── HEADER ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 🔙 Back button (left)
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: widget.onBack,
                      child: _iconButton(Icons.arrow_back, cs),
                    ),
                  ],
                ),

                // 🎯 PERFECTLY CENTERED TITLE
                Text(
                  'Smart Lock',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // ── LOCK STATUS CARD ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF2E9461),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  // Decorative circles
                  Positioned(
                    top: -32,
                    right: -32,
                    child: Container(
                      width: 128,
                      height: 128,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -16,
                    left: -16,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  // Content
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Account Status',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _accountLocked ? 'Account Frozen' : 'Account Active',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _accountLocked ? 'All transactions are blocked' : 'All services are running normally',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    color: Colors.white60,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: _handleAccountToggle,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: _accountLocked ? cs.error : Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                _accountLocked ? Icons.shield_outlined : Icons.shield,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _PulsingDot(
                            color: _accountLocked ? cs.error : Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _accountLocked ? 'Protection active — tap shield to unfreeze' : 'Tap shield to freeze account',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── EMERGENCY FREEZE BUTTON ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => _showEmergencySheet(context),
                icon: const Icon(Icons.warning_amber_rounded, size: 18),
                label: Text(
                  'Emergency Freeze',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.error,
                  foregroundColor: cs.onError,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),

          // ── SECURITY CONTROLS HEADING ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Text(
              'SECURITY CONTROLS',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF6B7F74),
                letterSpacing: 1.2,
              ),
            ),
          ),

          // ── TOGGLE LIST ──
          ...List.generate(_features.length, (i) {
            final f = _features[i];
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE0E8E4),
                  ),
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _toggles[f.id]! ? const Color(0xFF2E9461).withValues(alpha: 0.1) : const Color(0xFFEAF3EF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        f.icon,
                        size: 20,
                        color: _toggles[f.id]! ? const Color(0xFF2E9461) : const Color(0xFF6B7F74),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            f.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            f.description,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: const Color(0xFF6B7F74),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: _toggles[f.id]!,
                      onChanged: (_) => _handleFeatureToggle(f.id),
                      activeTrackColor: const Color(0xFF2E9461),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon, ColorScheme cs) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, size: 20, color: cs.onSurface),
    );
  }

  void _showEmergencySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EmergencyFreezeSheet(
        onConfirm: () {
          Navigator.pop(ctx);
          _handleEmergencyFreeze();
        },
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.4, end: 1.0).animate(_ctrl),
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _EmergencyFreezeSheet extends StatefulWidget {
  final VoidCallback onConfirm;
  const _EmergencyFreezeSheet({required this.onConfirm});

  @override
  State<_EmergencyFreezeSheet> createState() => _EmergencyFreezeSheetState();
}

class _EmergencyFreezeSheetState extends State<_EmergencyFreezeSheet> {
  double _holdProgress = 0;
  Timer? _holdTimer;

  void _startHold() {
    _holdTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {
        _holdProgress += 2;
        if (_holdProgress >= 100) {
          timer.cancel();
          _holdProgress = 0;
          widget.onConfirm();
        }
      });
    });
  }

  void _stopHold() {
    _holdTimer?.cancel();
    _holdTimer = null;
    setState(() => _holdProgress = 0);
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bulletPoints = [
      'All debit/credit card transactions will be blocked',
      'UPI, net banking & ATM access will be disabled',
      'International transactions will be suspended',
      'You can unfreeze anytime from this screen',
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Confirm Emergency Freeze',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F3F1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 16, color: Color(0xFF6B7F74)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...bulletPoints.map((text) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle, size: 16, color: cs.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        text,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: const Color(0xFF6B7F74),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 12),
          GestureDetector(
            onLongPressStart: (_) => _startHold(),
            onLongPressEnd: (_) => _stopHold(),
            onLongPressCancel: _stopHold,
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: cs.error,
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 30),
                    width: (MediaQuery.of(context).size.width - 48) *
                        (_holdProgress / 100),
                    height: 56,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  Center(
                    child: Text(
                      _holdProgress > 0
                          ? 'Freezing... ${_holdProgress.toInt()}%'
                          : 'Hold to Freeze Account',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Press and hold for 1.5 seconds',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: const Color(0xFF6B7F74),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

