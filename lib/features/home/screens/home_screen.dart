import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/stacked_cards.dart';
import '../widgets/ai_banner.dart';
import '../widgets/home_grid_item.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _gridItems = [
    {"icon": Icons.send, "label": "Send Money"},
    {"icon": Icons.receipt_long, "label": "Bill Pay & FASTag"},
    {"icon": Icons.account_balance, "label": "Loans"},
    {"icon": Icons.credit_card, "label": "Cards & Forex"},
    {"icon": Icons.health_and_safety, "label": "Insurance"},
    {"icon": Icons.miscellaneous_services, "label": "Services"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top Section (Header)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
                          ]
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: AppColors.textSecondary),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: "Search",
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.mic, color: AppColors.textSecondary),
                              onPressed: () {
                                HapticFeedback.lightImpact();
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.menu, color: AppColors.textPrimary, size: 28),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                      },
                    )
                  ],
                ),
              ),
            ),

            // Stacked Cards Section
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: SizedBox(
                  height: 220,
                  child: StackedCards(),
                ),
              ),
            ),

            // Secure Wealth AI Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: GestureDetector(
                  onTap: () {
                     HapticFeedback.mediumImpact();
                  },
                  child: const AiBanner(),
                ),
              ),
            ),

            // Feature Grid Section
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = _gridItems[index];
                    return HomeGridItem(icon: item["icon"], label: item["label"]);
                  },
                  childCount: _gridItems.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
          ]
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          backgroundColor: Colors.white,
          onTap: (index) {
            HapticFeedback.selectionClick();
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: "Profile"),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: "Transactions"),
            BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), activeIcon: Icon(Icons.qr_code), label: "UPI"),
            BottomNavigationBarItem(icon: Icon(Icons.pie_chart_outline), activeIcon: Icon(Icons.pie_chart), label: "Investments"),
            BottomNavigationBarItem(icon: Icon(Icons.lock_outline), activeIcon: Icon(Icons.lock), label: "Smart Lock"),
          ],
        ),
      ),
    );
  }
}
