import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: const Color(0xFFF2F0EB)),
      home: const HomeScreen(),
    );
  }
}

// ─── PALETTE ─────────────────────────────────────────────────────────────────
const _kForest = Color(0xFF1A3328);
const _kMid = Color(0xFF245C3F);
const _kAccent = Color(0xFF4CAF7A);
const _kCream = Color(0xFFF2F0EB);
const _kCard = Color(0xFFFFFFFF);
const _kSub = Color(0xFF9A9A94);
const _kInk = Color(0xFF1A1A18);

// ─── HOME SCREEN ──────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _navIdx = 0;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kCream,
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: FadeTransition(
              opacity: _fade,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 14),
                        _TopBar(),
                        const SizedBox(height: 20),
                        const _CardStack(),
                        const SizedBox(height: 16),
                        const _AIBanner(),
                        const SizedBox(height: 22),
                        const _QuickActions(),
                        const SizedBox(height: 28),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _BottomNav(
              currentIndex: _navIdx,
              onTap: (i) => setState(() => _navIdx = i)),
        ]),
      ),
    );
  }
}

// ─── TOP BAR ──────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            color: _kCard,
            borderRadius: BorderRadius.circular(23),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3))
            ],
          ),
          child: const Row(children: [
            SizedBox(width: 16),
            Icon(Icons.search_rounded, color: _kSub, size: 20),
            SizedBox(width: 8),
            Text('Search',
                style: TextStyle(
                    color: _kSub, fontSize: 14, fontWeight: FontWeight.w400)),
          ]),
        ),
      ),
      const SizedBox(width: 10),
      _Bubble(
          child: Stack(clipBehavior: Clip.none, children: [
        const Icon(Icons.notifications_none_rounded, color: _kInk, size: 20),
        Positioned(
          top: -2,
          right: -2,
          child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                  color: Color(0xFFE53935), shape: BoxShape.circle)),
        ),
      ])),
      const SizedBox(width: 8),
      _Bubble(
          child: const Icon(Icons.power_settings_new_rounded,
              color: _kInk, size: 20)),
    ]);
  }
}

class _Bubble extends StatelessWidget {
  final Widget child;
  const _Bubble({required this.child});
  @override
  Widget build(BuildContext context) => Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _kCard,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
        ),
        child: child,
      );
}

// ─── STACKED CARDS ────────────────────────────────────────────────────────────
class _CardStack extends StatefulWidget {
  const _CardStack();
  @override
  State<_CardStack> createState() => _CardStackState();
}

class _CardStackState extends State<_CardStack> {
  bool _open = false;

  static const double _loanH = 112;
  static const double _savingsH = 164;
  static const double _collapsedOffset = 36;
  static const double _expandedOffset = _loanH + 12;

  double get _containerHeight {
    final topOffset = _open ? _expandedOffset : _collapsedOffset;
    // Added 2px buffer to prevent bleed/clipping
    return topOffset + _savingsH + 6; 
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _open = !_open),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOut,
        height: _containerHeight,
        child: Stack(clipBehavior: Clip.none, children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _LoanCard(),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeInOut,
            top: _open ? _expandedOffset : _collapsedOffset,
            left: 0,
            right: 0,
            child: const _SavingsCard(),
          ),
        ]),
      ),
    );
  }
}

class _LoanCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Container(
        height: 112,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6B4E2A), Color(0xFFA37848)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF6B4E2A).withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 8))
          ],
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('LOAN ACCOUNT · PEEK',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1)),
              ),
              const SizedBox(height: 10),
              const Text('₹4,20,000',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5)),
              Text('outstanding balance',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 11)),
            ]),
      ),
    );
  }
}

class _SavingsCard extends StatelessWidget {
  const _SavingsCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 164,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A3328), Color(0xFF245C3F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: _kForest.withOpacity(0.45),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const _Glass('PORTFOLIO'),
            const SizedBox(width: 6),
            const _Glass('SAVINGS'),
            const Spacer(),
            _Dot(true),
            const SizedBox(width: 4),
            _Dot(false),
            const SizedBox(width: 4),
            _Dot(false),
          ]),
          const SizedBox(height: 12),
          Text('•••• •••• •••• 2345',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.65),
                  fontSize: 13,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w500)),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('TOTAL BALANCE',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0)),
                const SizedBox(height: 3),
                const Text('₹1,24,500',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5)),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('Rahul Kumar',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Row(children: [10.0, 16.0, 22.0, 14.0, 8.0]
                    .map((h) => Padding(
                          padding: const EdgeInsets.only(left: 2),
                          child: Container(
                              width: 3,
                              height: h,
                              decoration: BoxDecoration(
                                  color: _kAccent.withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(2))),
                        ))
                    .toList()),
              ]),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.keyboard_arrow_up_rounded,
                  color: Colors.white.withOpacity(0.35), size: 14),
              Text('tap card to reveal loan',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.35),
                      fontSize: 9,
                      letterSpacing: 0.3)),
            ]),
          ),
        ],
      ),
    );
  }
}

class _Glass extends StatelessWidget {
  final String t;
  const _Glass(this.t);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Text(t,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0)),
      );
}

class _Dot extends StatelessWidget {
  final bool a;
  const _Dot(this.a);
  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: a ? 14 : 6,
        height: 6,
        decoration: BoxDecoration(
          color: a ? _kAccent : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(3),
        ),
      );
}

// ─── AI BANNER ────────────────────────────────────────────────────────────────
class _AIBanner extends StatelessWidget {
  const _AIBanner();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kAccent.withOpacity(0.22)),
        boxShadow: [
          BoxShadow(
              color: _kForest.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [_kMid, _kAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: _kAccent.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3))
            ],
          ),
          child: const Icon(Icons.auto_awesome_rounded,
              color: Colors.white, size: 20),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NEED HELP?',
                    style: TextStyle(
                        color: _kAccent,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2)),
                SizedBox(height: 2),
                Text('Secure Wealth AI',
                    style: TextStyle(
                        color: _kForest,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3)),
              ]),
        ),
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: _kForest.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_forward_ios_rounded,
              size: 12, color: _kForest),
        ),
      ]),
    );
  }
}

// ─── QUICK ACTIONS ────────────────────────────────────────────────────────────
class _QuickActions extends StatelessWidget {
  const _QuickActions();

  static const _data = [
    _AData(Icons.send_rounded, 'Send /\nTransfer', Color(0xFFE3F5EC), Color(0xFFBBE8D0), Color(0xFF1B7A49)),
    _AData(Icons.receipt_long_rounded, 'Bills &\nRecharge', Color(0xFFFFF4E5), Color(0xFFFFE0B2), Color(0xFFD4820A)),
    _AData(Icons.savings_rounded, 'Savings', Color(0xFFE8F0FE), Color(0xFFBBD0FB), Color(0xFF1A56C4)),
    _AData(Icons.credit_card_rounded, 'Cards &\nForex', Color(0xFFF3E8FF), Color(0xFFE1BEFF), Color(0xFF7B2FBE)),
    _AData(Icons.tune_rounded, 'Services', Color(0xFFFFE8EC), Color(0xFFFFBBC8), Color(0xFFCE2D48)),
    _AData(Icons.qr_code_scanner_rounded, 'UPI', Color(0xFFE5F9F2), Color(0xFFA8EDD3), Color(0xFF0E7C5B)),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // FIX 1: Removed "More" button from the header row.
      const Text('QUICK ACTIONS',
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.3,
              color: _kInk)),
      const SizedBox(height: 14),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _data.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.97,
        ),
        itemBuilder: (_, i) => _Tile(d: _data[i]),
      ),
    ]);
  }
}

class _AData {
  final IconData icon;
  final String label;
  final Color g1, g2, ic;
  const _AData(this.icon, this.label, this.g1, this.g2, this.ic);
}

class _Tile extends StatefulWidget {
  final _AData d;
  const _Tile({required this.d});
  @override
  State<_Tile> createState() => _TileState();
}

class _TileState extends State<_Tile> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _s;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _s = Tween<double>(begin: 1, end: 0.92)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _c.forward(),
      onTapUp: (_) => _c.reverse(),
      onTapCancel: () => _c.reverse(),
      child: AnimatedBuilder(
        animation: _s,
        builder: (_, child) =>
            Transform.scale(scale: _s.value, child: child),
        child: Container(
          decoration: BoxDecoration(
            color: _kCard,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: widget.d.ic.withOpacity(0.10),
                  blurRadius: 12,
                  offset: const Offset(0, 5))
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [widget.d.g1, widget.d.g2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(widget.d.icon, size: 26, color: widget.d.ic),
              ),
              const SizedBox(height: 9),
              Text(
                widget.d.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _kInk,
                    height: 1.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── BOTTOM NAV ───────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

  // FIX 2: Items updated to Profile, Transactions, UPI, Investments, Smart Lock.
  static const _items = [
    (Icons.person_rounded, 'Profile', false),
    (Icons.swap_horiz_rounded, 'Transactions', false),
    (Icons.qr_code_scanner_rounded, 'UPI', true),
    (Icons.bar_chart_rounded, 'Investments', false),
    (Icons.lock_rounded, 'Smart Lock', false),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4))
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final (icon, label, isCenter) = _items[i];
              final active = currentIndex == i;

              if (isCenter) {
                return GestureDetector(
                  onTap: () => onTap(i),
                  child: Container(
                    width: 60,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [_kForest, _kMid],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: _kForest.withOpacity(0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4))
                      ],
                    ),
                    child: const Icon(Icons.qr_code_scanner_rounded,
                        color: Colors.white, size: 22),
                  ),
                );
              }

              return GestureDetector(
                onTap: () => onTap(i),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: active ? 28 : 0,
                      height: active ? 3 : 0,
                      margin: EdgeInsets.only(bottom: active ? 4 : 0),
                      decoration: BoxDecoration(
                        color: _kAccent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Icon(icon,
                        size: 22, color: active ? _kForest : _kSub),
                    const SizedBox(height: 3),
                    Text(label,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: active
                                ? FontWeight.w800
                                : FontWeight.w500,
                            color: active ? _kForest : _kSub)),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}