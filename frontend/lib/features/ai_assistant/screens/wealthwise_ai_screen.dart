import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../l10n/app_localizations.dart';
import '../../home/widgets/home_navigation_widgets.dart';
import '../../../services/ai_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/language_provider.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final List<String>? options;
  final List<String>? optionDescriptions;
  final String? type;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.options,
    this.optionDescriptions,
    this.type,
  });
}

class WealthWiseAIScreen extends StatefulWidget {
  final VoidCallback onBack;
  final bool guestMode;

  const WealthWiseAIScreen({
    super.key,
    required this.onBack,
    this.guestMode = false,
  });

  @override
  State<WealthWiseAIScreen> createState() => _WealthWiseAIScreenState();
}

class _WealthWiseAIScreenState extends State<WealthWiseAIScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  String _cusId = "CUST1"; // safe fallback

  String? _selectedRisk;
  String? _selectedAssetClass;

  @override
  void initState() {
    super.initState();
    if (!widget.guestMode) {
      _loadCustomerId();
    }
  }

  Future<void> _loadCustomerId() async {
    try {
      final authUser = AuthProvider.instance.currentUser;
      if (authUser != null && authUser['cus_id'] != null) {
        if (mounted) {
          setState(() {
            _cusId = authUser['cus_id'];
            debugPrint('SAGE Loaded customer ID from AuthProvider: $_cusId');
          });
        }
        return;
      }

      final supabase = Supabase.instance.client;
      final userEmail = authUser?['email'] ?? supabase.auth.currentUser?.email;
      if (userEmail != null) {
        final res = await supabase
            .from('users')
            .select('cus_id')
            .eq('email', userEmail)
            .maybeSingle();
        if (res != null && res['cus_id'] != null) {
          if (mounted) {
            setState(() {
              _cusId = res['cus_id'];
              debugPrint('SAGE Loaded customer ID: $_cusId');
            });
          }
        }
      }
    } catch (e) {
      debugPrint('SAGE Error loading customer ID: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSuggestionTap(String text) {
    setState(() {
      _controller.text = text;
    });
    _handleSendMessage();
  }

  bool _isInvestmentQuery(String text) {
    final lower = text.toLowerCase();
    
    // Explicit trigger if the word 'investment' or 'invest' exists,
    // or if the query contains investment/advisory related keywords.
    return lower.contains('investment') ||
        lower.contains('invest') ||
        lower.contains('portfolio') ||
        lower.contains('wealth') ||
        lower.contains('asset') ||
        lower.contains('advice') ||
        lower.contains('where should i put my money');
  }

  void _onOptionSelected(String option, String? type) {
    if (type == 'risk_appetite') {
      setState(() {
        _messages.add(ChatMessage(text: option, isUser: true));
        _isTyping = true;
      });
      
      if (option.contains('Low')) {
        _selectedRisk = 'low';
      } else if (option.contains('Moderate')) {
        _selectedRisk = 'moderate';
      } else {
        _selectedRisk = 'high';
      }
      
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() {
            _isTyping = false;
            _messages.add(ChatMessage(
              text: "Got it. Now, what type of asset class or investment vehicle are you looking to explore today?",
              isUser: false,
              type: 'asset_class',
              options: [
                "Mutual Funds & SIPs",
                "Fixed & Recurring Deposits",
                "Government Schemes",
                "Digital Gold/Silver",
                "Stocks & Equities",
                "Derivatives & Options",
                "Diversify my Portfolio"
              ],
            ));
          });
        }
      });
    } else if (type == 'asset_class') {
      setState(() {
        _messages.add(ChatMessage(text: option, isUser: true));
        _isTyping = true;
      });
      
      if (option.contains('Diversify')) {
        Future.delayed(const Duration(milliseconds: 200), () async {
          try {
            final reply = await AIService.getChatReply(
              message: "Recommend how to diversify my portfolio based on my current and previous holdings. My risk appetite is ${_selectedRisk ?? 'moderate'}.",
              cusId: widget.guestMode ? "GUEST" : _cusId,
              guestMode: widget.guestMode,
            );
            if (mounted) {
              setState(() {
                _isTyping = false;
                _messages.add(ChatMessage(
                  text: reply,
                  isUser: false,
                ));
              });
            }
          } catch (e) {
            if (mounted) {
              setState(() {
                _isTyping = false;
                _messages.add(ChatMessage(
                  text: "Sorry, I was unable to retrieve your portfolio data. Please try again.",
                  isUser: false,
                ));
              });
            }
          }
        });
      } else {
        if (option.contains('Mutual Funds')) {
          _selectedAssetClass = 'mutual_funds';
        } else if (option.contains('Fixed & Recurring')) {
          _selectedAssetClass = 'deposits';
        } else if (option.contains('Government')) {
          _selectedAssetClass = 'government';
        } else if (option.contains('Gold/Silver')) {
          _selectedAssetClass = 'gold_silver';
        } else if (option.contains('Stocks')) {
          _selectedAssetClass = 'stocks';
        } else {
          _selectedAssetClass = 'derivatives';
        }

        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            final recommendation = _generateSageRecommendation(_selectedRisk ?? 'moderate', _selectedAssetClass ?? 'stocks');
            final fullReply = "$recommendation\n\nDisclaimer: This suggestion is generated for educational purposes based on your self-selected risk metrics. Review your specific timeline and goals prior to deployment.";
            setState(() {
              _isTyping = false;
              _messages.add(ChatMessage(
                text: fullReply,
                isUser: false,
              ));
            });
          }
        });
      }
    }
  }

  String _generateSageRecommendation(String risk, String assetClass) {
    if (assetClass == 'derivatives') {
      if (risk == 'low') {
        return "For a conservative profile looking at derivatives, we suggest utilizing strategy frameworks like **Covered Calls** or **Protective Puts** to ensure predictable, limited risk. A **Covered Call** involves writing call options against underlying stocks you already own, generating premium income that acts as a partial downside cushion. A **Protective Put** involves purchasing put options for assets you hold, acting as an insurance policy that caps your maximum potential loss. These strategies prioritize capital protection by combining option contracts with existing equity positions, shielding your wealth from major market drawdowns while yielding steady cash flow.";
      } else if (risk == 'moderate') {
        return "For a moderate risk tolerance, we suggest strategy frameworks like **Credit Spreads** or **Iron Condors** to define and cap maximum potential losses. A **Bull Put Spread** or **Bear Call Spread** (Credit Spreads) lets you collect upfront premiums by buying and selling options at different strike prices, restricting both maximum risk and maximum reward to predefined boundaries. An **Iron Condor** combines both spreads to profit from a stock trading within a specific range. These structured setups let you capture consistent premiums with strict risk boundaries, ensuring market volatility cannot lead to unchecked losses.";
      } else {
        return "For aggressive/speculative objectives, we suggest high-leverage frameworks like **Naked Calls/Puts** or **Long Straddles** where out-of-the-money premiums are risked for potentially exponential returns. Writing **Naked Options** captures maximum premium but exposes you to theoretically unlimited risk, requiring precise margin control. A **Long Straddle** involves buying both a call and a put option at the same strike price, capitalizing on massive price swings regardless of direction. These high-leverage setups accept complete premium loss in exchange for explosive gains on sharp market movements or volatility bursts, making them suitable only for active risk-tolerant accounts.";
      }
    }
    
    // Matrix B
    if (assetClass == 'stocks') {
      if (risk == 'low') {
        return "For capital preservation in equities, we suggest focusing on **blue-chip, large-cap dividend-yielding stocks**. These are shares of well-established, industry-leading companies with robust balance sheets and a proven history of surviving recessions. By focusing on firms with steady cash flows, you secure regular passive income through dividends, which can be reinvested to compound wealth. Large-cap stocks exhibit significantly lower price volatility compared to mid or small-caps. This structural approach safeguards your principal capital while offering steady growth and inflation protection over a long-term investment horizon.";
      } else if (risk == 'moderate') {
        return "For balanced growth in equities, we suggest focusing on a mix of **large-cap and mid-cap stocks**, or **broad diversified index funds**. This approach balances the stability of top-tier enterprises with the higher growth potential of medium-sized companies. Mid-cap companies often possess strong market share and are in their high-growth phase, though they experience moderate price swings. Diversifying across sectors like banking, technology, and consumer goods helps mitigate company-specific risk. This framework targets capital appreciation while absorbing short-term fluctuations, offering a balanced growth trajectory.";
      } else {
        return "For aggressive stock investing, we suggest focusing on **growth-oriented small-cap stocks, thematic sector equities**, or **momentum stock baskets**. Small-cap companies are early-stage businesses with smaller market capitalizations, offering the potential for exponential growth and multi-bagger returns. However, they are highly sensitive to market downturns and lack liquidity. A momentum strategy targets stocks exhibiting strong upward price trends. This high-conviction approach accepts substantial price volatility, drawdown risks, and capital losses in pursuit of market-outperforming growth, requiring a long time horizon and high tolerance for fluctuations.";
      }
    }
    
    if (assetClass == 'mutual_funds') {
      if (risk == 'low') {
        return "For conservative mutual fund exposure, we suggest focusing on **liquid debt funds, overnight funds**, or **short-duration debt mutual funds**. These funds primarily invest in highly secure, interest-bearing securities such as government bonds, treasury bills, and high-rating commercial paper. They prioritize capital preservation and offer high liquidity, allowing you to withdraw funds quickly without penalty. With very low sensitivity to stock market movements, debt funds provide predictable, steady yields. This is an ideal parking vehicle for capital where preservation of principal is the absolute priority.";
      } else if (risk == 'moderate') {
        return "For balanced mutual fund exposure, we suggest focusing on **flexi-cap mutual funds** or **balanced advantage hybrid funds**. Flexi-cap funds allow professional managers to dynamically shift investments between large, mid, and small-cap stocks depending on market opportunities. Balanced advantage funds dynamically manage asset allocation between equity and debt based on market valuations, automatically booking profits in bull markets and buying equities during market dips. This double-layer diversification provides steady long-term capital appreciation while smoothing out market volatility and cushioning downside drawdowns.";
      } else {
        return "For aggressive mutual fund investing, we suggest focusing on **aggressive small-cap equity funds** or **sector-specific/thematic mutual funds** (like technology, infrastructure, or healthcare). These funds concentrate their holdings in smaller, fast-growing companies or single sectors to target exponential, market-beating returns. While they can deliver high returns during growth phases, they are highly vulnerable to prolonged market drawdowns and sector cycles. This high-conviction approach accepts severe short-term volatility and structural risks in exchange for long-term wealth compounding, suitable only for speculative portfolios.";
      }
    }
    
    if (assetClass == 'deposits') {
      if (risk == 'low') {
        return "For absolute safety in deposits, we suggest focusing on capital protection frameworks like **fixed deposits (FDs) with public-sector banks, senior citizen savings terms**, or **tax-saving deposits**. These interest-bearing contracts guarantee the safety of your principal up to statutory insurance limits while paying a fixed, predictable rate of return. Senior citizen schemes offer premium interest rates, enhancing cash flow. Because these instruments are backed by strong banking institutions and regulated frameworks, they carry negligible default risk, making them the cornerstone of any capital-preservation plan.";
      } else if (risk == 'moderate') {
        return "For enhanced yields with measured risk, we suggest focusing on high-quality (AAA-rated) **corporate fixed deposits** or **inflation-indexed deposits**. Corporate deposits are offered by companies to raise capital, yielding higher interest rates than traditional bank FDs. Restricting exposure to AAA-rated entities minimizes the default risk while capturing the premium yield. Inflation-indexed deposits protect your purchasing power by adjusting returns based on consumer price trends. This approach slightly increases credit risk but safeguards your money from being eroded by rising costs.";
      } else {
        return "For maximizing returns in fixed income, we suggest focusing on **high-yield corporate deposits** or **high-yield corporate debt funds**. These placements target lower-rated companies (AA or below) or specialized credit opportunities, offering significantly higher interest rates to compensate for the elevated default risk. While they pay premium yields, they are sensitive to company financial health and credit rating downgrades. This strategy accepts credit default risks and potential liquidity bottlenecks in exchange for maximizing interest income, making it a speculative tool within a fixed-income portfolio.";
      }
    }
    
    if (assetClass == 'government') {
      if (risk == 'low') {
        return "For sovereign-backed safety, we suggest highlighting capital protection frameworks like **Public Provident Fund (PPF), National Savings Certificates (NSC)**, or **Sovereign Gold Bonds (SGBs)**. These schemes are directly backed by the central government, eliminating any default or credit risk. PPF offers tax-free returns and long-term compounding, while NSC provides fixed interest with tax deduction benefits. SGBs provide gold price appreciation alongside a regular semi-annual interest payout. These government-backed vehicles are designed to safeguard your principal capital completely while yielding inflation-aligned, tax-efficient growth.";
      } else if (risk == 'moderate') {
        return "For balanced retirement growth, we suggest focusing on the **National Pension System (NPS)** with a moderate asset allocation, such as the **Active Choice** option capped at **50% Equity (Asset Class E)**, with the remainder in corporate and government bonds. This structured vehicle builds long-term wealth by combining the steady yield of debt instruments with the growth potential of blue-chip stocks. The balanced mix automatically dampens market swings while offering tax-deductible contributions, providing a highly regulated and cost-effective wealth-building framework.";
      } else {
        return "For aggressive retirement growth, we suggest utilizing the **National Pension System (NPS)** with an aggressive equity allocation under the **Active Choice** option, allocating the maximum permissible **75% to Equity (Asset Class E)**. The remaining 25% is split between corporate and government debt. This maximizes your exposure to equity markets within a structured, long-term retirement framework, compounding wealth rapidly through market-leading companies. While subject to short-term market corrections, the long lock-in period allows the portfolio to recover and target maximum tax-efficient returns.";
      }
    }
    
    if (assetClass == 'gold_silver') {
      if (risk == 'low') {
        return "For capital protection in precious metals, we suggest focusing on **SGBs (Sovereign Gold Bonds)** or **Gold Exchange-Traded Funds (ETFs)**. SGBs are government-backed securities denominated in grams of gold, offering a secure way to track gold prices while earning a fixed 2.5% annual interest. Gold ETFs represent physical gold held securely by custodians, traded on the stock exchange. These methods completely eliminate the storage costs, theft risks, and making charges associated with physical gold, providing a safe, liquid, and institutional-grade framework for capital preservation.";
      } else if (risk == 'moderate') {
        return "For systematic accumulation, we suggest utilizing **systematic Digital Gold or Silver accumulation plans**. These platforms allow you to purchase 24-karat gold or silver in small fractional amounts (starting as low as ₹100), with the physical metal stored in secured, insured vaults. By investing a fixed amount monthly, you utilize rupee-cost averaging to buy more units when prices are low and fewer when prices are high. This dampens the impact of short-term commodity price swings, building a liquid precious metal hedge over time.";
      } else {
        return "For aggressive commodity exposure, we suggest focusing on **leveraged gold/silver commodity derivatives** (futures/options) or **gold mining stocks**. Commodity futures allow you to control large contract values with a small margin, amplifying gains on minor gold or silver price movements. Mining stocks represent equity in gold-producing companies, whose profits are highly sensitive to metal prices, often rising faster than gold itself. These leveraged plays carry high capital risks, margin calls, and extreme price volatility, suitable only for trading accounts seeking speculative commodity gains.";
      }
    }
    
    return "Focus on blue-chip, diversified index funds or Sovereign Gold Bonds for capital preservation.";
  }

  // 🔥 NEW SIMPLIFIED SEND LOGIC
  Future<void> _handleSendMessage() async {
    final userMessage = _controller.text.trim();
    if (userMessage.isEmpty || _isTyping) return;

    // 1. Add user message to UI
    setState(() {
      _messages.add(ChatMessage(text: userMessage, isUser: true));
      _controller.clear();
      _isTyping = true;
    });

    // Check if this is an investment suggestion request (only in authenticated mode)
    if (!widget.guestMode && _isInvestmentQuery(userMessage)) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() {
            _isTyping = false;
            _messages.add(ChatMessage(
              text: "To provide an accurate and unbiased suggestion, let's first determine your risk appetite (your willingness to accept financial uncertainty in exchange for potential rewards):",
              isUser: false,
              type: 'risk_appetite',
              options: [
                "Low Risk Appetite (Capital Preservation)",
                "Moderate Risk Appetite (Balanced)",
                "High Risk Appetite (Aggressive/Speculative)"
              ],
              optionDescriptions: [
                "You prefer predictable, limited risk.",
                "You are open to measured risk for better returns with strictly defined maximum losses.",
                "You are willing to risk premiums for potentially exponential returns."
              ],
            ));
          });
        }
      });
      return;
    }

    // 2. Call Backend AI Chat
    final currentLang = Provider.of<LanguageProvider>(context, listen: false).languageCode;
    final reply = await AIService.getChatReply(
      message: userMessage,
      cusId: widget.guestMode ? "GUEST" : _cusId,
      guestMode: widget.guestMode,
      language: currentLang,
    );

    // 3. Add AI reply to UI
    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(text: reply, isUser: false));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      body: SafeArea(
        child: Column(
          children: [
            // --- Header ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: widget.onBack,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: kCard,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: kForest, size: 20),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'SAGE',
                              style: TextStyle(
                                color: kForest,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: widget.guestMode
                                    ? Colors.amber.shade700.withValues(alpha: 0.15)
                                    : kAccent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: widget.guestMode
                                      ? Colors.amber.shade700.withValues(alpha: 0.4)
                                      : kAccent.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    widget.guestMode ? Icons.person_outline_rounded : Icons.verified_user_rounded,
                                    color: widget.guestMode ? Colors.amber.shade800 : kAccent,
                                    size: 10,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    widget.guestMode ? 'GUEST MODE' : 'SECURE',
                                    style: TextStyle(
                                      color: widget.guestMode ? Colors.amber.shade900 : kAccent,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Text(
                          widget.guestMode
                              ? 'General banking & security assistant'
                              : 'Ask anything about your finances',
                          style: const TextStyle(
                            color: kSub,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- Guest Mode Banner ---
            if (widget.guestMode)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: const Color(0xFFFFF8E1),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFFB45309)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Guest Mode — Sign in to access personalized financial insights.",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            Expanded(
              child: _messages.isEmpty ? _buildEmptyState() : _buildChatList(),
            ),

            // --- Bottom Controls ---
            Container(
              padding: const EdgeInsets.only(left: 18, right: 18, top: 18, bottom: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- Suggestion Chips ---
                  if (_messages.isEmpty)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: widget.guestMode
                            ? [
                                _SuggestionChip(
                                  text: 'What is a mutual fund?',
                                  onTap: () => _onSuggestionTap('What is a mutual fund?'),
                                ),
                                const SizedBox(width: 10),
                                _SuggestionChip(
                                  text: 'Safe banking tips',
                                  onTap: () => _onSuggestionTap('Safe banking tips'),
                                ),
                                const SizedBox(width: 10),
                                _SuggestionChip(
                                  text: 'How to open an account?',
                                  onTap: () => _onSuggestionTap('How to open an account?'),
                                ),
                              ]
                            : [
                                _SuggestionChip(
                                  text: 'Why was my last transaction risky?',
                                  onTap: () => _onSuggestionTap('Why was my last transaction risky?'),
                                ),
                                const SizedBox(width: 10),
                                _SuggestionChip(
                                  text: 'How much did I spend this week?',
                                  onTap: () => _onSuggestionTap('How much did I spend this week?'),
                                ),
                                const SizedBox(width: 10),
                                _SuggestionChip(
                                  text: 'Check my savings',
                                  onTap: () => _onSuggestionTap('Check my savings'),
                                ),
                              ],
                      ),
                    ),
                  if (_messages.isEmpty) const SizedBox(height: 16),
                  // --- Input Bar ---
                  Container(
                    height: 58,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: kCard,
                      borderRadius: BorderRadius.circular(29),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            onChanged: (val) => setState(() {}),
                            onSubmitted: (_) => _handleSendMessage(),
                            decoration: const InputDecoration(
                              hintText: 'Ask something...',
                              hintStyle: TextStyle(color: kSub, fontSize: 15),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        GestureDetector(
                          onTap: _handleSendMessage,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: _controller.text.trim().isNotEmpty 
                                  ? const Color(0xFF2ECC71) 
                                  : (_isTyping ? kAccent.withValues(alpha: 0.5) : const Color(0xFFD1DAD5)),
                              shape: BoxShape.circle,
                              boxShadow: [
                                if (_controller.text.trim().isNotEmpty)
                                  BoxShadow(
                                    color: const Color(0xFF2ECC71).withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                              ],
                            ),
                            child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 22),
                          ),
                        ),
                      ],
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

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(left: 32, right: 32, bottom: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: kMid.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
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
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: widget.guestMode ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                children: widget.guestMode
                    ? [
                        Text(
                          AppLocalizations.of(context)?.guestModeGreeting ??
                              "Hello! I'm SAGE.\n\nI can help you with:\n• Account opening\n• Banking services\n• KYC\n• Fixed Deposits\n• Interest rates\n• Branch information\n• ATM services\n• UPI basics\n• Debit/Credit cards\n• Loans (general)\n• Security awareness\n• RBI guidelines\n• Banking FAQs\n\nPlease sign in for investment advice, account details and personalized financial insights.",
                          style: const TextStyle(
                            color: kForest,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                          ),
                        ),
                      ]
                    : const [
                        Text(
                          'How can I help you today?',
                          style: TextStyle(
                            color: kForest,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'You can ask about transactions, security, spending, and more.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: kSub,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
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

  Widget _buildChatList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length) {
          return _buildTypingIndicator();
        }
        final msg = _messages[index];
        return _buildChatRow(msg);
      },
    );
  }

  Widget _buildChatRow(ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!msg.isUser) ...[
                _buildAIAvatar(),
                const SizedBox(width: 8),
              ],
              _buildChatBubble(msg),
            ],
          ),
          if (msg.options != null && msg.options!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 36, top: 10, right: 18),
              child: _buildOptionsList(msg),
            ),
        ],
      ),
    );
  }

  Widget _buildAIAvatar() {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: kMid,
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/ai_logo.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _parseAndRenderText(String text, TextStyle baseStyle) {
    final List<TextSpan> spans = [];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int start = 0;
    
    for (final match in regex.allMatches(text)) {
      if (match.start > start) {
        spans.add(TextSpan(
          text: text.substring(start, match.start),
          style: baseStyle,
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: baseStyle.copyWith(fontWeight: FontWeight.w900),
      ));
      start = match.end;
    }
    
    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: baseStyle,
      ));
    }
    
    return RichText(
      text: TextSpan(children: spans),
    );
  }

  Widget _buildChatBubbleContent(ChatMessage msg, TextStyle baseStyle) {
    if (msg.text.contains("Disclaimer:")) {
      final parts = msg.text.split("Disclaimer:");
      final mainText = parts[0].trim();
      final disclaimerText = "Disclaimer: ${parts[1].trim()}";
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _parseAndRenderText(mainText, baseStyle),
          const SizedBox(height: 12),
          Divider(height: 1, color: kForest.withValues(alpha: 0.15), thickness: 0.5),
          const SizedBox(height: 8),
          _parseAndRenderText(
            disclaimerText,
            baseStyle.copyWith(
              color: kSub,
              fontSize: 11,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      );
    }
    return _parseAndRenderText(msg.text, baseStyle);
  }

  Widget _buildChatBubble(ChatMessage msg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
      decoration: BoxDecoration(
        color: msg.isUser ? kForest : kCard,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(msg.isUser ? 18 : 4),
          bottomRight: Radius.circular(msg.isUser ? 4 : 18),
        ),
        boxShadow: [
          if (!msg.isUser)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: _buildChatBubbleContent(
        msg,
        TextStyle(
          color: msg.isUser ? Colors.white : kForest,
          fontSize: 14,
          fontWeight: msg.isUser ? FontWeight.w500 : FontWeight.w600,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildOptionsList(ChatMessage msg) {
    final bool isActive = (msg == _messages.last) && !_isTyping;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(msg.options!.length, (index) {
        final option = msg.options![index];
        final desc = msg.optionDescriptions != null && index < msg.optionDescriptions!.length
            ? msg.optionDescriptions![index]
            : null;
        return _OptionButton(
          title: option,
          subtitle: desc,
          onTap: () => _onOptionSelected(option, msg.type),
          isActive: isActive,
        );
      }),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildAIAvatar(),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              "AI is thinking...",
              style: TextStyle(color: kSub, fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _SuggestionChip({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: kLightGreenBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: kMid,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isActive;

  const _OptionButton({
    required this.title,
    this.subtitle,
    required this.onTap,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isActive ? 1.0 : 0.5,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        width: double.infinity,
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? kForest.withValues(alpha: 0.25) : kForest.withValues(alpha: 0.1),
            width: 1.5,
          ),
          boxShadow: [
            if (isActive)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isActive ? onTap : null,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: kForest,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        color: kSub,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
