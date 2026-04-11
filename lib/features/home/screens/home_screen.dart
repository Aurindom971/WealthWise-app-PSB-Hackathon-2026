import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:securewealth_twin/features/cards_and_forex/screens/cards_and_forex_screen.dart';
import 'package:securewealth_twin/features/home/widgets/home_navigation_widgets.dart';
import 'package:securewealth_twin/features/loans/screens/loans_screen.dart';
import 'package:securewealth_twin/features/insurance/screens/insurance_screen.dart';

// ─── HOME SCREEN ──────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _navIdx = 0;
  bool _isShowingDashboard = true;
  bool _isShowingCardsAndForex = false;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Logout',
          style: TextStyle(color: kForest, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to log out of your secure session?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: kSub)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade800,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
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
                onHomeTap: () => setState(() {
                  _isShowingDashboard = true;
                  _isShowingCardsAndForex = false;
                }),
                onLogoutTap: _handleLogout,
              ),
            ),
            Expanded(
              child: FadeTransition(
                opacity: _fade,
                child: _isShowingCardsAndForex
                    ? CardsAndForexScreen(
                        showFreezeCard: true,
                        onBack: () =>
                            setState(() => _isShowingCardsAndForex = false),
                      )
                    : (_isShowingDashboard
                          ? _buildDashboard()
                          : _buildTabContent()),
              ),
            ),
            BottomNav(
              currentIndex: _isShowingDashboard ? -1 : _navIdx,
              onTap: (i) => setState(() {
                _navIdx = i;
                _isShowingDashboard = false;
                _isShowingCardsAndForex = false;
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 6),
              const _CardStack(),
              const SizedBox(height: 16),
              const _AIBanner(),
              const SizedBox(height: 22),
              _QuickActions(
                onCardsForexTap: () =>
                    setState(() => _isShowingCardsAndForex = true),
              ),
              const SizedBox(height: 28),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildTabContent() {
    final titles = [
      'Profile',
      'Transactions',
      'UPI',
      'Investments',
      'Smart Lock',
    ];
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.construction_rounded,
                  size: 60,
                  color: kAccent.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  '${titles[_navIdx]} Module',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: kForest,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Coming soon to SecureWealth Twin',
                  style: TextStyle(color: kSub),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── STACKED CARDS ────────────────────────────────────────────────────────────
class _CardStack extends StatefulWidget {
  const _CardStack();
  @override
  State<_CardStack> createState() => _CardStackState();
}

class _CardStackState extends State<_CardStack> with TickerProviderStateMixin {
  late final AnimationController _releaseCtrl;
  late final AnimationController _snapCtrl;
  late Animation<double> _snapAnim;

  int _topIndex = 0;
  double _dragY = 0.0;
  double _startDragY = 0.0;
  bool _isReleasing = false;
  bool _obscureBalances = true;

  static const int _cardCount = 3;
  static const double _baseOffset = -12.0;
  static const double _maxCardHeight = 164.0;
  static const double _headroom = 36.0;

  @override
  void initState() {
    super.initState();

    _releaseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _releaseCtrl.addListener(() => setState(() {}));
    _releaseCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _topIndex = (_topIndex + 1) % _cardCount;
          _dragY = 0.0;
          _isReleasing = false;
        });
        _releaseCtrl.reset();
      }
    });

    _snapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _snapCtrl.addListener(() {
      setState(() {
        _dragY = _snapAnim.value;
      });
    });
  }

  @override
  void dispose() {
    _releaseCtrl.dispose();
    _snapCtrl.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    if (_isReleasing || _snapCtrl.isAnimating) return;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isReleasing || _snapCtrl.isAnimating) return;
    setState(() {
      double resistance = 1.0 - (_dragY / 300.0).clamp(0.0, 0.8);
      _dragY += details.delta.dy * resistance * 0.85;
      if (_dragY < 0) _dragY = 0;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isReleasing || _snapCtrl.isAnimating) return;

    if (_dragY > 60 || details.velocity.pixelsPerSecond.dy > 300) {
      _startDragY = _dragY;
      _isReleasing = true;
      _releaseCtrl.animateTo(1.0, curve: Curves.easeInCubic);
    } else {
      _snapAnim = Tween<double>(
        begin: _dragY,
        end: 0.0,
      ).animate(CurvedAnimation(parent: _snapCtrl, curve: Curves.easeOutBack));
      _snapCtrl.forward(from: 0.0);
    }
  }

  void _toggleObscure() {
    setState(() {
      _obscureBalances = !_obscureBalances;
    });
  }

  Widget _buildCard(int index) {
    if (index == 0)
      return _SavingsCard(obscured: _obscureBalances, onToggle: _toggleObscure);
    if (index == 1)
      return _PortfolioCard(
        obscured: _obscureBalances,
        onToggle: _toggleObscure,
      );
    if (index == 2)
      return _LoanCard(obscured: _obscureBalances, onToggle: _toggleObscure);
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Container(
        color: Colors.transparent,
        height: _maxCardHeight + _headroom,
        child: Stack(
          clipBehavior: Clip.none,
          children: List.generate(_cardCount, (reverseIdx) {
            int visualIdx = _cardCount - 1 - reverseIdx;
            int cardIdx = (_topIndex + visualIdx) % _cardCount;
            Widget card = _buildCard(cardIdx);

            double dy = 0;
            double scale = 1.0;
            double opacity = 1.0;

            if (_isReleasing) {
              double t = _releaseCtrl.value;
              if (visualIdx == 0) {
                // Top card slides down to back
                dy = _startDragY + (400.0 - _startDragY) * t;
                opacity = (1.0 - (t * 1.5)).clamp(0.0, 1.0);
              } else if (visualIdx == 1) {
                // Next card moves up
                double startDY = _baseOffset - (_startDragY * 0.08);
                dy = startDY * (1.0 - t);
                scale = 0.96 + (0.04 * t);
              } else if (visualIdx == 2) {
                double startDY = (_baseOffset * 2) - (_startDragY * 0.04);
                dy = startDY + ((_baseOffset - startDY) * t);
                scale = 0.92 + (0.04 * t);
              } else {
                dy = _baseOffset * visualIdx;
                scale = 1.0 - (visualIdx * 0.04);
              }
            } else {
              if (visualIdx == 0) {
                dy = _dragY;
              } else if (visualIdx == 1) {
                dy = _baseOffset - (_dragY * 0.08);
                scale = 0.96;
              } else if (visualIdx == 2) {
                dy = (_baseOffset * 2) - (_dragY * 0.04);
                scale = 0.92;
              } else {
                dy = _baseOffset * visualIdx;
                scale = 1.0 - (visualIdx * 0.04);
              }
            }

            return Positioned(
              top: _headroom,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: opacity,
                child: Transform.translate(
                  offset: Offset(0, dy),
                  child: Transform.scale(
                    scale: scale,
                    alignment: Alignment.topCenter,
                    child: card,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _LoanCard extends StatelessWidget {
  final bool obscured;
  final VoidCallback onToggle;
  const _LoanCard({required this.obscured, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Container(
        height: 164,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
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
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const _Glass('LOAN ACCOUNT'),
                const Spacer(),
                const _Dot(false),
                const SizedBox(width: 4),
                const _Dot(false),
                const SizedBox(width: 4),
                const _Dot(true),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '•••• •••• •••• 9876',
              style: TextStyle(
                color: Colors.white.withOpacity(0.65),
                fontSize: 13,
                letterSpacing: 2,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'OUTSTANDING BALANCE',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: onToggle,
                          child: Icon(
                            obscured
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            color: Colors.white.withOpacity(0.7),
                            size: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      obscured ? '₹ ••••••' : '₹4,20,000',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.white.withOpacity(0.35),
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'pull down to reveal next',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.35),
                      fontSize: 9,
                      letterSpacing: 0.3,
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

class _PortfolioCard extends StatelessWidget {
  final bool obscured;
  final VoidCallback onToggle;
  const _PortfolioCard({required this.obscured, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 164,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A5F), Color(0xFF3B5998)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A5F).withOpacity(0.45),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _Glass('PORTFOLIO'),
              const Spacer(),
              const _Dot(false),
              const SizedBox(width: 4),
              const _Dot(true),
              const SizedBox(width: 4),
              const _Dot(false),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '•••• •••• •••• 5678',
            style: TextStyle(
              color: Colors.white.withOpacity(0.65),
              fontSize: 13,
              letterSpacing: 2,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'TOTAL INVESTMENTS',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: onToggle,
                        child: Icon(
                          obscured
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: Colors.white.withOpacity(0.7),
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    obscured ? '₹ ••••••' : '₹8,45,200',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rahul Kumar',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [22.0, 14.0, 18.0, 10.0, 16.0]
                        .map(
                          (h) => Padding(
                            padding: const EdgeInsets.only(left: 2),
                            child: Container(
                              width: 3,
                              height: h,
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF8AB4F8,
                                ).withOpacity(0.85),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.white.withOpacity(0.35),
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  'pull down to reveal next',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 9,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SavingsCard extends StatelessWidget {
  final bool obscured;
  final VoidCallback onToggle;
  const _SavingsCard({required this.obscured, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 164,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kForest, kMid],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: kForest.withOpacity(0.45),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _Glass('SAVINGS'),
              const Spacer(),
              const _Dot(true),
              const SizedBox(width: 4),
              const _Dot(false),
              const SizedBox(width: 4),
              const _Dot(false),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '•••• •••• •••• 2345',
            style: TextStyle(
              color: Colors.white.withOpacity(0.65),
              fontSize: 13,
              letterSpacing: 2,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'TOTAL BALANCE',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: onToggle,
                        child: Icon(
                          obscured
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: Colors.white.withOpacity(0.7),
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    obscured ? '₹ ••••••' : '₹1,24,500',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rahul Kumar',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [10.0, 16.0, 22.0, 14.0, 8.0]
                        .map(
                          (h) => Padding(
                            padding: const EdgeInsets.only(left: 2),
                            child: Container(
                              width: 3,
                              height: h,
                              decoration: BoxDecoration(
                                color: kAccent.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.white.withOpacity(0.35),
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  'pull down to reveal next',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 9,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
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
    child: Text(
      t,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 9,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
      ),
    ),
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
      color: a ? kAccent : Colors.white.withOpacity(0.3),
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
        color: kCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kAccent.withOpacity(0.22)),
        boxShadow: [
          BoxShadow(
            color: kForest.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kMid, kAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: kAccent.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NEED HELP?',
                  style: TextStyle(
                    color: kAccent,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Secure Wealth AI',
                  style: TextStyle(
                    color: kForest,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: kForest.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: kForest,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── QUICK ACTIONS ────────────────────────────────────────────────────────────
class _QuickActions extends StatelessWidget {
  final VoidCallback onCardsForexTap;
  const _QuickActions({required this.onCardsForexTap});

  static const _data = [
    _AData(
      Icons.send_rounded,
      'Send /\nTransfer',
      Color(0xFFE3F5EC),
      Color(0xFFBBE8D0),
      Color(0xFF1B7A49),
    ),
    _AData(
      Icons.receipt_long_rounded,
      'Bills &\nRecharge',
      Color(0xFFFFF4E5),
      Color(0xFFFFE0B2),
      Color(0xFFD4820A),
    ),
    _AData(
      Icons.account_balance,
      'Loans',
      Color(0xFFEAF6F0),
      Color(0xFFEAF6F0),
      Color(0xFF1F7A5A),
    ),
    _AData(
      Icons.credit_card_rounded,
      'Cards &\nForex',
      Color(0xFFF3E8FF),
      Color(0xFFE1BEFF),
      Color(0xFF7B2FBE),
    ),
    _AData(
      Icons.tune_rounded,
      'Services',
      Color(0xFFFFE8EC),
      Color(0xFFFFBBC8),
      Color(0xFFCE2D48),
    ),
    _AData(
      Icons.shield_outlined,
      'Insurance',
      Color(0xFFE6F0FA),
      Color(0xFFE6F0FA),
      Color(0xFF2F6FD6),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'QUICK ACTIONS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.3,
            color: kInk,
          ),
        ),
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
          itemBuilder: (_, i) => _Tile(
            d: _data[i],
            onTap: _data[i].label == 'Cards &\nForex' ? onCardsForexTap : null,
          ),
        ),
      ],
    );
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
  final VoidCallback? onTap;
  const _Tile({required this.d, this.onTap});
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
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _s = Tween<double>(
      begin: 1,
      end: 0.92,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
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
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap!();
        }
      },
      child: AnimatedBuilder(
        animation: _s,
        builder: (_, child) => Transform.scale(scale: _s.value, child: child),
        child: Container(
          decoration: BoxDecoration(
            color: kCard,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.d.ic.withOpacity(0.10),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onHighlightChanged: (h) => h ? _c.forward() : _c.reverse(),
              onTap: () {
                if (widget.onTap != null) {
                  widget.onTap!();
                } else if (widget.d.label == 'Loans') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoansScreen()),
                  );
                } else if (widget.d.label == 'Insurance') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const InsuranceScreen()),
                  );
                }
              },
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
                    widget.d.label.replaceAll('\n', ' '),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: kInk,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
