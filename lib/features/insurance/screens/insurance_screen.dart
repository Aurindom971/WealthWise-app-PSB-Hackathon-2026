import 'package:flutter/material.dart';
import '../../home/widgets/home_navigation_widgets.dart';
import 'track_claims_screen.dart';
import 'insurance_category_screen.dart';
import 'all_plans_screen.dart';

class InsuranceScreen extends StatefulWidget {
  const InsuranceScreen({super.key});

  @override
  State<InsuranceScreen> createState() => _InsuranceScreenState();
}

class _InsuranceScreenState extends State<InsuranceScreen> {
  final ValueNotifier<double> _categoriesScrollPos = ValueNotifier(0.0);
  final ScrollController _categoriesController = ScrollController();

  // Premium Calculator Controllers
  String? _selectedCategory;
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  String? _calculatedPremium;

  @override
  void initState() {
    super.initState();
    _categoriesController.addListener(() {
      if (_categoriesController.hasClients) {
        double maxScroll = _categoriesController.position.maxScrollExtent;
        if (maxScroll > 0) {
          _categoriesScrollPos.value = _categoriesController.offset / maxScroll;
        }
      }
    });
  }

  @override
  void dispose() {
    _categoriesController.dispose();
    _ageController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _calculatePremium() {
    final double age = double.tryParse(_ageController.text) ?? 0;
    final double duration = double.tryParse(_durationController.text) ?? 0;

    if (age <= 0 || duration <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter valid age and duration'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    // Dummy calculation logic
    double basePremium = 100;
    if (_selectedCategory == 'Health')
      basePremium = 500;
    else if (_selectedCategory == 'Life')
      basePremium = 800;
    else if (_selectedCategory == 'Vehicle')
      basePremium = 300;
    else if (_selectedCategory == 'Term')
      basePremium = 400;
    else if (_selectedCategory == 'Travel')
      basePremium = 100;

    final double ageFactor = (age / 10);
    final double durationFactor = 1 / (duration * 0.5 + 0.5);
    final double result = (basePremium * ageFactor * durationFactor) / 12;

    setState(() {
      _calculatedPremium = '₹${result.toStringAsFixed(0)}';
    });
  }

  void _navigateToCategory(String name) {
    final data = insuranceCategoryDataMap[name];
    if (data != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InsuranceCategoryScreen(category: data),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar matching Loans
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: TopBar(
                onHomeTap: () => Navigator.pop(context),
                onLogoutTap: () => Navigator.pop(context),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Insurance Header Banner (Loans Style)
                    Container(
                      margin: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      decoration: BoxDecoration(
                        color: kMid.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://www.transparenttextures.com/patterns/carbon-fibre.png',
                          ),
                          opacity: 0.05,
                          repeat: ImageRepeat.repeat,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.shield_outlined,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              const Text(
                                'Insurance',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Protect what matters most with our curated plans',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Simple Claim Process
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18),
                      child: Text(
                        'Simple Claim Process',
                        style: TextStyle(
                          color: kInk,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: kCard,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildClaimStep(
                                  Icons.description_outlined,
                                  'File Claim',
                                  'Submit your\nonline',
                                ),
                                _buildConnector(),
                                _buildClaimStep(
                                  Icons.manage_search_outlined,
                                  'Review',
                                  'We verify\nyour docs',
                                ),
                                _buildConnector(),
                                _buildClaimStep(
                                  Icons.thumb_up_alt_outlined,
                                  'Approval',
                                  'Get paid in\n2-3 days',
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const TrackClaimsScreen(),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: kMid,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                child: const Text(
                                  'Track Your Claim',
                                  style: TextStyle(
                                    color: kMid,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Browse Categories
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Browse Categories',
                        style: TextStyle(
                          color: kInk,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _BrowseCategoriesSection(
                      controller: _categoriesController,
                      scrollPos: _categoriesScrollPos,
                      onExplore: _navigateToCategory,
                    ),

                    const SizedBox(height: 32),

                    // Recommended Plans
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recommended Plans',
                            style: TextStyle(
                              color: kInk,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AllPlansScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'View All >',
                              style: TextStyle(
                                color: kMid,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _buildPlanCard(
                            title: 'Super Health Plus',
                            price: '₹499',
                            unit: '/month',
                            isPopular: true,
                            features: [
                              '₹5L coverage for family',
                              'Cashless hospitalization',
                              'Free health checkups',
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildPlanCard(
                            title: 'Life Shield 1Cr',
                            price: '₹849',
                            unit: '/month',
                            isPopular: false,
                            features: [
                              '₹1 Cr life cover',
                              'Tax benefits under 80C',
                              'Accidental coverage included',
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Premium Calculator
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Premium Calculator',
                        style: TextStyle(
                          color: kInk,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: kCard,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCalcLabel('Insurance Plan'),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2F2F2),
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedCategory,
                                  isExpanded: true,
                                  hint: Text(
                                    'Select insurance type',
                                    style: TextStyle(
                                      color: kInk.withOpacity(0.4),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  icon: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: kInk.withOpacity(0.4),
                                    size: 24,
                                  ),
                                  dropdownColor: Colors.white,
                                  borderRadius: BorderRadius.circular(28),
                                  items:
                                      [
                                        'Health Insurance',
                                        'Life Insurance',
                                        'Vehicle Insurance',
                                        'Term Insurance',
                                        'Travel Insurance',
                                      ].map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(
                                            value,
                                            style: const TextStyle(
                                              color: kInk,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                  onChanged: (val) =>
                                      setState(() => _selectedCategory = val!),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildCalcLabel('Age'),
                            const SizedBox(height: 6),
                            _buildCalInput(_ageController, 'Enter your age'),
                            const SizedBox(height: 16),
                            _buildCalcLabel('Coverage Amount (₹)'),
                            const SizedBox(height: 6),
                            _buildCalInput(
                              null,
                              'Enter coverage amount',
                            ), // Placeholder for new field
                            const SizedBox(height: 16),
                            _buildCalcLabel('Duration (Years)'),
                            const SizedBox(height: 6),
                            _buildCalInput(
                              _durationController,
                              'Enter duration in years',
                            ),
                            const SizedBox(height: 24),
                            if (_calculatedPremium != null) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                margin: const EdgeInsets.only(bottom: 24),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F9F5),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Estimated Premium',
                                      style: TextStyle(
                                        color: kSub,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '$_calculatedPremium /mo',
                                      style: const TextStyle(
                                        color: kMid,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _calculatePremium,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kMid,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Calculate Premium',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Why Choose Us Widget
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FAF7),
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: kMid.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.shield_outlined,
                                color: kMid,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Why Choose Us?',
                                    style: TextStyle(
                                      color: kInk,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '99% claim settlement ratio • 24/7 support • Instant policy issuance',
                                    style: TextStyle(
                                      color: kInk.withOpacity(0.5),
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Bottom Nav matching Home
            BottomNav(currentIndex: -1, onTap: (i) => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildClaimStep(IconData icon, String title, String desc) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Color(0xFFEAF6F0),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: kMid, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            color: kInk,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          desc,
          textAlign: TextAlign.center,
          style: const TextStyle(color: kSub, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildConnector() {
    return Container(
      margin: const EdgeInsets.only(top: 18),
      width: 20,
      height: 1.5,
      color: Colors.grey.withOpacity(0.3),
    );
  }

  Widget _buildCalcLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: kInk,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildCalInput(TextEditingController? controller, String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(
          color: kInk,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          hintStyle: TextStyle(
            color: kInk.withOpacity(0.35),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required String unit,
    required bool isPopular,
    required List<String> features,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: kInk,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              if (isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4E5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Popular',
                    style: TextStyle(
                      color: Color(0xFFD68E24),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                price,
                style: const TextStyle(
                  color: Color(0xFFD68E24),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  color: kInk.withOpacity(0.4),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...features.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: kMid, width: 1.2),
                    ),
                    child: const Icon(Icons.check, color: kMid, size: 10),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      f,
                      style: TextStyle(
                        color: kInk.withOpacity(0.75),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: kMid,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Buy Now',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrowseCategoriesSection extends StatelessWidget {
  final ScrollController controller;
  final ValueNotifier<double> scrollPos;
  final Function(String) onExplore;

  const _BrowseCategoriesSection({
    required this.controller,
    required this.scrollPos,
    required this.onExplore,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        'name': 'Health Insurance',
        'icon': Icons.favorite_outline,
        'desc': 'Medical coverage for\nyou & family',
        'bubbleColor': const Color(0xFFFFEEEF),
        'iconColor': const Color(0xFFFF5252),
      },
      {
        'name': 'Life Insurance',
        'icon': Icons.shield_outlined,
        'desc': "Secure your family's\nfuture",
        'bubbleColor': const Color(0xFFE8F1FF),
        'iconColor': const Color(0xFF2196F3),
      },
      {
        'name': 'Vehicle Insurance',
        'icon': Icons.directions_car_outlined,
        'desc': 'Comprehensive auto\nprotection',
        'bubbleColor': const Color(0xFFF3E8FF),
        'iconColor': const Color(0xFF9C27B0),
      },
      {
        'name': 'Term Insurance',
        'icon': Icons.description_outlined,
        'desc': 'Pure life coverage at\nlow cost',
        'bubbleColor': const Color(0xFFE8F1FF),
        'iconColor': const Color(0xFF2196F3),
      },
      {
        'name': 'Travel Insurance',
        'icon': Icons.flight_takeoff_outlined,
        'desc': 'Safe travels\nworldwide',
        'bubbleColor': const Color(0xFFFFF4E5),
        'iconColor': const Color(0xFFFF9800),
      },
    ];

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: controller,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: categories
                .map(
                  (cat) => _buildCategoryCard(
                    cat['name'] as String,
                    cat['icon'] as IconData,
                    cat['desc'] as String,
                    cat['bubbleColor'] as Color,
                    cat['iconColor'] as Color,
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: _buildScrollIndicator(),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(
    String name,
    IconData icon,
    String desc,
    Color bubbleColor,
    Color iconColor,
  ) {
    return Container(
      width: 190,
      height: 220,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bubbleColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              color: kInk,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              height: 1.1,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: kInk.withOpacity(0.45),
              fontSize: 12,
              height: 1.2,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => onExplore(name),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: kMid.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Explore',
                style: TextStyle(
                  color: kMid,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollIndicator() {
    return ValueListenableBuilder<double>(
      valueListenable: scrollPos,
      builder: (context, pos, _) {
        return Row(
          children: [
            const Icon(Icons.arrow_left, size: 18, color: Color(0xFF9E9E9E)),
            const SizedBox(width: 4),
            Expanded(
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double thumbWidth =
                        constraints.maxWidth * 0.5; // Approx 50% width
                    double availableSpace = constraints.maxWidth - thumbWidth;
                    return Stack(
                      children: [
                        Positioned(
                          left: pos * availableSpace,
                          child: Container(
                            width: thumbWidth,
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFF888888),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_right, size: 18, color: Color(0xFF9E9E9E)),
          ],
        );
      },
    );
  }
}
