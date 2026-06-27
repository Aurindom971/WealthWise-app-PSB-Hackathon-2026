import 'dart:async';
import 'smart_lock_screen.dart';
import 'transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wealthwise/features/cards_and_forex/screens/cards_and_forex_screen.dart';
import 'package:wealthwise/features/home/widgets/home_navigation_widgets.dart';
import 'package:wealthwise/features/loans/screens/loans_screen.dart';
import 'package:wealthwise/features/insurance/screens/insurance_screen.dart';
import 'package:wealthwise/features/home/screens/notifications_screen.dart';
import 'package:wealthwise/features/bill_and_recharge/screens/bill_and_recharge_screen.dart';
import 'package:wealthwise/features/bill_and_recharge/models/bill_models.dart';
import 'package:wealthwise/features/bill_and_recharge/screens/utility_payment_screen.dart';
import 'package:wealthwise/features/bill_and_recharge/screens/all_upcoming_bills_screen.dart';
import 'package:wealthwise/features/bill_and_recharge/screens/payment_gateway_screen.dart';
import 'package:wealthwise/features/loans/screens/loan_eligibility_screen.dart';
import 'package:wealthwise/features/loans/screens/loan_statement_screen.dart';
import 'package:wealthwise/features/loans/screens/active_loans_screen.dart';
import 'package:wealthwise/features/loans/screens/apply_loan_screen.dart';
import 'package:wealthwise/features/loans/screens/compare_loans_screen.dart';
import 'package:wealthwise/features/loans/screens/application_status_screen.dart';
import 'package:wealthwise/features/investments/invest.dart';
import 'package:wealthwise/features/profile/profile_page.dart';
import 'package:wealthwise/features/service/services_page.dart';
import 'package:wealthwise/features/ai_assistant/screens/wealthwise_ai_screen.dart';
import '../../../services/security_service.dart';

enum LoanSubState {
  main,
  eligibility,
  activeLoans,
  statement,
  apply,
  compare,
  status,
}

// Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬ HOME SCREEN Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
class HomeScreen extends StatefulWidget {
  final int? initialIndex;
  const HomeScreen({super.key, this.initialIndex});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _navIdx = 0;
  bool _isShowingDashboard = true;
  bool _isShowingCardsAndForex = false;
  bool _isShowingBillAndRecharge = false;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;

  // Sub-navigation state for Bill & Recharge
  BillRechargeSubState _billSubState = BillRechargeSubState.main;
  BillRechargeSubState _previousBillSubState = BillRechargeSubState.main;
  UtilityProvider? _selectedUtility;
  Bill? _selectedBill;

  // Sub-navigation state for Loans
  bool _isShowingLoans = false;
  bool _isShowingServices = false;
  LoanSubState _loanSubState = LoanSubState.main;
  String? _selectedLoanType;
  String? _selectedLoanId;

  // AI Assistant state
  bool _isShowingWealthWiseAI = false;

  // Data State
  bool _isLoading = true;
  String? _fullName;
  List<dynamic> _accounts = [];
  List<dynamic> _cards = [];
  List<dynamic> _investments = [];
  List<dynamic> _loans = [];
  double _totalInvestment = 0;
  double _totalLoan = 0;

  @override
  void initState() {
    super.initState();
    _navIdx = widget.initialIndex ?? 0;
    _isShowingDashboard = _navIdx == 0;

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    _fetchHomeData();
  }

  double _parseAmount(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    if (val is String) {
      final cleaned = val.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(cleaned) ?? 0.0;
    }
    return 0.0;
  }

  Future<void> _fetchHomeData() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        debugPrint('[Home] Error: No authenticated user found.');
        setState(() => _isLoading = false);
        return;
      }

      final userEmail = user.email;
      debugPrint('[Home] Fetching get_home_data for: $userEmail');

      final response = await supabase.rpc(
        'get_home_data',
        params: {'user_email': userEmail},
      );

      debugPrint('[Home] get_home_data Response: $response');

      if (response == null) {
        debugPrint('[Home] Warning: get_home_data returned null');
        setState(() => _isLoading = false);
        return;
      }

      final data = response as Map<String, dynamic>;

      if (mounted) {
        setState(() {
          _accounts = data['accounts'] as List<dynamic>? ?? [];
          _cards = data['cards'] as List<dynamic>? ?? [];

          final investmentValue =
              data['investments'] ??
              data['total_investments'] ??
              data['investment'] ??
              0;
          final loanValue =
              data['loans'] ?? data['total_loans'] ?? data['loan'] ?? 0;

          _totalInvestment = _parseAmount(investmentValue);
          _totalLoan = _parseAmount(loanValue);

          _fullName = 'Rajesh Kumar';

          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[Home] RPC Execution Error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
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
                searchText: _isShowingServices
                    ? 'Search in Services'
                    : (_navIdx == 0 && !_isShowingDashboard
                          ? 'Search in Profile'
                          : 'Search'),
                onHomeTap: () => setState(() {
                  _isShowingDashboard = true;
                  _isShowingCardsAndForex = false;
                  _isShowingBillAndRecharge = false;
                  _isShowingLoans = false;
                  _isShowingServices = false;
                  _isShowingWealthWiseAI = false;
                }),
                onLogoutTap: _handleLogout,
                onNotificationTap: () => showNotifications(context),
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
                    : (_isShowingBillAndRecharge
                          ? _buildBillAndRechargeContent()
                          : (_isShowingLoans
                                ? _buildLoansContent()
                                : (_isShowingServices
                                      ? ServicesPage()
                                      : (_isShowingWealthWiseAI
                                            ? WealthWiseAIScreen(
                                                onBack: () => setState(() => _isShowingWealthWiseAI = false),
                                              )
                                            : (_isShowingDashboard
                                                  ? _buildDashboard()
                                                  : _buildTabContent()))))),
              ),
            ),
            BottomNav(
              currentIndex: _isShowingDashboard ? -1 : _navIdx,
              onTap: (i) => setState(() {
                _navIdx = i;
                _isShowingDashboard = false;
                _isShowingCardsAndForex = false;
                _isShowingBillAndRecharge = false;
                _isShowingLoans = false;
                _isShowingServices = false;
                _isShowingWealthWiseAI = false;
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
              const SizedBox(height: 4),
              if (_isLoading)
                const SizedBox(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(color: kForest),
                  ),
                )
              else
                _CardStack(
                  fullName: _fullName ?? 'User',
                  accounts: _accounts,
                  cards: _cards,
                  investments: _investments,
                  loans: _loans,
                  totalInvestment: _totalInvestment,
                  totalLoan: _totalLoan,
                ),
              const SizedBox(height: 30),
              _AIBanner(
                onTap: () => setState(() => _isShowingWealthWiseAI = true),
                onLongPress: () {
                  SecurityService.updateSmartLockSettings({
                    'online_enabled': true,
                    'upi_enabled': true,
                    'pos_enabled': true,
                    'atm_enabled': true,
                    'card_freeze_enabled': true,
                    'emergency_freeze': true,
                  });
                  SecurityService.toggleGlobalCardFreeze(true);
                  SecurityService.syncGlobalAtmLimits(true);
                },
              ),
              const SizedBox(height: 30),
              _QuickActions(
                onCardsForexTap: () =>
                    setState(() => _isShowingCardsAndForex = true),
                onBillRechargeTap: () =>
                    setState(() => _isShowingBillAndRecharge = true),
                onLoansTap: () => setState(() {
                  _isShowingLoans = true;
                  _loanSubState = LoanSubState.main;
                }),
                onServicesTap: () => setState(() => _isShowingServices = true),
              ),
              const SizedBox(height: 28),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildBillAndRechargeContent() {
    switch (_billSubState) {
      case BillRechargeSubState.main:
        return BillAndRechargeScreen(
          onBack: () => setState(() => _isShowingBillAndRecharge = false),
          onSelectUtility: (provider) => setState(() {
            _selectedUtility = provider;
            _billSubState = BillRechargeSubState.utilityDetails;
          }),
          onViewAllUpcoming: () => setState(() {
            _billSubState = BillRechargeSubState.upcomingBills;
          }),
          onPayBill: (bill) => setState(() {
            _selectedBill = bill;
            _previousBillSubState = _billSubState;
            _billSubState = BillRechargeSubState.paymentGateway;
          }),
        );
      case BillRechargeSubState.utilityDetails:
        return UtilityPaymentScreen(
          provider: _selectedUtility!,
          onBack: () =>
              setState(() => _billSubState = BillRechargeSubState.main),
          onProceedToPay: (bill) => setState(() {
            _selectedBill = bill;
            _previousBillSubState = _billSubState;
            _billSubState = BillRechargeSubState.paymentGateway;
          }),
        );
      case BillRechargeSubState.upcomingBills:
        return AllUpcomingBillsScreen(
          onBack: () =>
              setState(() => _billSubState = BillRechargeSubState.main),
          onPayBill: (bill) => setState(() {
            _selectedBill = bill;
            _previousBillSubState = _billSubState;
            _billSubState = BillRechargeSubState.paymentGateway;
          }),
        );
      case BillRechargeSubState.paymentGateway:
        return PaymentGatewayScreen(
          bill: _selectedBill!,
          onBack: () => setState(
            () => _billSubState = _previousBillSubState,
          ),
          onSuccess: () => setState(() {
            _billSubState = BillRechargeSubState.main;
            _isShowingBillAndRecharge = false;
          }),
        );
    }
  }

  Widget _buildLoansContent() {
    switch (_loanSubState) {
      case LoanSubState.main:
        return LoansScreen(
          onBack: () => setState(() => _isShowingLoans = false),
          onNavigate: (state, {loanType, loanId}) => setState(() {
            _loanSubState = state;
            if (loanType != null) _selectedLoanType = loanType;
            if (loanId != null) _selectedLoanId = loanId;
          }),
        );
      case LoanSubState.eligibility:
        return LoanEligibilityScreen(
          onBack: () => setState(() => _loanSubState = LoanSubState.main),
        );
      case LoanSubState.activeLoans:
        return ActiveLoansScreen(
          onBack: () => setState(() => _loanSubState = LoanSubState.main),
          onViewStatement: (type, id) => setState(() {
            _selectedLoanType = type;
            _selectedLoanId = id;
            _loanSubState = LoanSubState.statement;
          }),
        );
      case LoanSubState.statement:
        return LoanStatementScreen(
          loanType: _selectedLoanType ?? 'Personal Loan',
          loanId: _selectedLoanId ?? 'PL-000',
          onBack: () => setState(() => _loanSubState = LoanSubState.main),
        );
      case LoanSubState.apply:
        return ApplyLoanScreen(
          initialLoanType: _selectedLoanType,
          onBack: () => setState(() => _loanSubState = LoanSubState.main),
          onSuccess: () => setState(() {
            _loanSubState = LoanSubState.status;
          }),
        );
      case LoanSubState.compare:
        return CompareLoansScreen(
          onBack: () => setState(() => _loanSubState = LoanSubState.main),
          onApply: (type) => setState(() {
            _selectedLoanType = type;
            _loanSubState = LoanSubState.apply;
          }),
        );
      case LoanSubState.status:
        return ApplicationStatusScreen(
          loanType: _selectedLoanType ?? 'Loan',
          loanId: _selectedLoanId ?? '',
          onBack: () => setState(() => _loanSubState = LoanSubState.main),
        );
    }
  }

  Widget _buildTabContent() {
    if (_navIdx == 1)
      return TransactionScreen(
        onBack: () => setState(() => _isShowingDashboard = true),
      );
    if (_navIdx == 3)
      return InvestmentsScreen(
        onBack: () => setState(() => _isShowingDashboard = true),
      );
    if (_navIdx == 4)
      return SmartLockScreen(
        onBack: () => setState(() => _isShowingDashboard = true),
      );
    if (_navIdx == 0) return const ProfilePage();
    if (_navIdx == 1) {
      return TransactionScreen(
        onBack: () => setState(() => _isShowingDashboard = true),
      );
    }
    if (_navIdx == 4) {
      return SmartLockScreen(
        onBack: () => setState(() => _isShowingDashboard = true),
      );
    }

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
                  color: kAccent.withValues(alpha: 0.3),
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
                const SizedBox(height: 4),
                Text(
                  'Coming soon to WealthWise Twin',
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

// Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬ STACKED CARDS Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
class _CardStack extends StatefulWidget {
  final String fullName;
  final List<dynamic> accounts;
  final List<dynamic> cards;
  final List<dynamic> investments;
  final List<dynamic> loans;
  final double totalInvestment;
  final double totalLoan;

  const _CardStack({
    this.fullName = 'User',
    this.accounts = const [],
    this.cards = const [],
    this.investments = const [],
    this.loans = const [],
    this.totalInvestment = 0,
    this.totalLoan = 0,
  });

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
  static const double _maxCardHeight = 196.0;
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

  void _onVerticalDragStart(DragStartDetails details) {
    if (_isReleasing || _snapCtrl.isAnimating) return;
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (_isReleasing) return;
    setState(() {
      _dragY += details.delta.dy;
      if (_dragY > 150) _dragY = 150;
      if (_dragY < -20) _dragY = -20;
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
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
    // Summing savings balances
    double totalSavings = 0;
    for (var acc in widget.accounts) {
      totalSavings += (acc['balance'] ?? 0).toDouble();
    }

    if (index == 0) {
      return _SavingsCard(
        obscured: _obscureBalances,
        onToggle: _toggleObscure,
        fullName: widget.fullName,
        balance: totalSavings,
      );
    }
    if (index == 1) {
      return _PortfolioCard(
        obscured: _obscureBalances,
        onToggle: _toggleObscure,
        fullName: widget.fullName,
        totalInvestment: widget.totalInvestment,
      );
    }
    if (index == 2) {
      return _LoanCard(
        obscured: _obscureBalances,
        onToggle: _toggleObscure,
        totalLoan: widget.totalLoan,
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragStart: _onVerticalDragStart,
      onVerticalDragUpdate: _onVerticalDragUpdate,
      onVerticalDragEnd: _onVerticalDragEnd,
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
                dy = _startDragY + (400.0 - _startDragY) * t;
                opacity = (1.0 - (t * 1.5)).clamp(0.0, 1.0);
              } else if (visualIdx == 1) {
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
  final double totalLoan;
  const _LoanCard({
    required this.obscured,
    required this.onToggle,
    this.totalLoan = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Container(
        height: 196,
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6B4E2A), Color(0xFFA37848)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6B4E2A).withValues(alpha: 0.4),
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
            const SizedBox(height: 4),
            Text(
              '\u2022\u2022\u2022\u2022 \u2022\u2022\u2022\u2022 \u2022\u2022\u2022\u2022 9876',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 13,
                letterSpacing: 2,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
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
                            color: Colors.white.withValues(alpha: 0.5),
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
                            color: Colors.white.withValues(alpha: 0.7),
                            size: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        obscured
                            ? '\u20B9 \u2022\u2022\u2022\u2022\u2022\u2022'
                            : '\u20B9${totalLoan.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            const SizedBox(height: 4),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.white.withValues(alpha: 0.35),
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'pull down to reveal next',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35),
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
  final String fullName;
  final double totalInvestment;

  const _PortfolioCard({
    required this.obscured,
    required this.onToggle,
    this.fullName = 'User',
    this.totalInvestment = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 196,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A5F), Color(0xFF3B5998)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A5F).withValues(alpha: 0.45),
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
          const SizedBox(height: 4),
          Text(
            '\u2022\u2022\u2022\u2022 \u2022\u2022\u2022\u2022 \u2022\u2022\u2022\u2022 5678',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 13,
              letterSpacing: 2,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
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
                          color: Colors.white.withValues(alpha: 0.5),
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
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      obscured
                          ? '\u20B9 \u2022\u2022\u2022\u2022\u2022\u2022'
                          : '\u20B9${totalInvestment.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    fullName,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
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
                                ).withValues(alpha: 0.85),
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
          const Spacer(),
          const SizedBox(height: 4),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.white.withValues(alpha: 0.35),
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  'pull down to reveal next',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35),
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
  final String fullName;
  final double balance;

  const _SavingsCard({
    required this.obscured,
    required this.onToggle,
    this.fullName = 'User',
    this.balance = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 196,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kForest, kMid],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: kForest.withValues(alpha: 0.45),
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
          const SizedBox(height: 4),
          Text(
            '\u2022\u2022\u2022\u2022 \u2022\u2022\u2022\u2022 \u2022\u2022\u2022\u2022 2345',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 13,
              letterSpacing: 2,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
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
                          color: Colors.white.withValues(alpha: 0.5),
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
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      obscured
                          ? '\u20B9 \u2022\u2022\u2022\u2022\u2022\u2022'
                          : '\u20B9${balance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    fullName,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [10.0, 16.0, 22.0, 14.0, 8.0]
                        .map(
                          (h) => Padding(
                            padding: const EdgeInsets.only(left: 2),
                            child: Container(
                              width: 3,
                              height: h,
                              decoration: BoxDecoration(
                                color: kAccent.withValues(alpha: 0.85),
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
          const Spacer(),
          const SizedBox(height: 4),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.white.withValues(alpha: 0.35),
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  'pull down to reveal next',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35),
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
      color: Colors.white.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
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
    height: 4,
    decoration: BoxDecoration(
      color: a ? kAccent : Colors.white.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(3),
    ),
  );
}

// Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬ AI BANNER Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
class _AIBanner extends StatefulWidget {
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  const _AIBanner({required this.onTap, this.onLongPress});

  @override
  State<_AIBanner> createState() => _AIBannerState();
}

class _AIBannerState extends State<_AIBanner> {
  Timer? _holdTimer;

  void _startHold() {
    _holdTimer?.cancel();
    _holdTimer = Timer(const Duration(seconds: 5), () {
      if (widget.onLongPress != null) {
        widget.onLongPress!();
      }
    });
  }

  void _cancelHold() {
    _holdTimer?.cancel();
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _startHold(),
      onTapUp: (_) => _cancelHold(),
      onTapCancel: _cancelHold,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kAccent.withValues(alpha: 0.22)),
          boxShadow: [
            BoxShadow(
              color: kForest.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: kAccent.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/ai_logo.png',
                  fit: BoxFit.cover,
                ),
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
                    'SAGE',
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
                color: kForest.withValues(alpha: 0.08),
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
      ),
    );
  }
}

// Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬ QUICK ACTIONS Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
class _QuickActions extends StatelessWidget {
  final VoidCallback onCardsForexTap;
  final VoidCallback onBillRechargeTap;
  final VoidCallback onLoansTap;
  final VoidCallback onServicesTap;
  const _QuickActions({
    required this.onCardsForexTap,
    required this.onBillRechargeTap,
    required this.onLoansTap,
    required this.onServicesTap,
  });

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
      Color(0xFF1F5D3A),
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
            onTap: _data[i].label == 'Cards &\nForex'
                ? onCardsForexTap
                : (_data[i].label == 'Bills &\nRecharge'
                      ? onBillRechargeTap
                      : (_data[i].label == 'Loans'
                            ? onLoansTap
                            : (_data[i].label == 'Services'
                                  ? onServicesTap
                                  : null))),
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
                color: widget.d.ic.withValues(alpha: 0.10),
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
                } else if (widget.d.label == 'Send /\nTransfer') {
                  // Entry-level guard for Send/Transfer
                  SecurityService.isOnlineLockActive().then((blocked) {
                    if (blocked) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Online Transactions are currently blocked by Smart Lock.'),
                          backgroundColor: Colors.red.shade800,
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.only(bottom: 90, left: 16, right: 16),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    } else {
                      Navigator.pushNamed(context, '/send_transfer');
                    }
                  });
                } else if (widget.d.label == 'Loans') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LoansScreen(
                        onBack: () => Navigator.pop(context),
                        onNavigate: (state, {loanType, loanId}) =>
                            Navigator.pop(context),
                      ),
                    ),
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
