import 'package:flutter/material.dart';
import 'package:securewealth_twin/features/home/widgets/home_navigation_widgets.dart';
import 'package:securewealth_twin/features/cards_and_forex/screens/cards_and_forex_screen.dart';
import 'package:securewealth_twin/features/home/screens/smart_lock_screen.dart';
import '../../loans/widgets/loan_header.dart';
import '../../home/screens/notifications_screen.dart';

class CardServicesPage extends StatelessWidget {
  const CardServicesPage({super.key});

  void _navigateToSmartLock(BuildContext context, String? highlightId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: kCream,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  child: TopBar(
                    onHomeTap: () =>
                        Navigator.popUntil(context, (route) => route.isFirst),
                    onLogoutTap: () =>
                        Navigator.popUntil(context, (route) => route.isFirst),
                    onNotificationTap: () => showNotifications(context),
                  ),
                ),
                LoanHeader(
                  title: "",
                  subtitle: "Smart Lock",
                  icon: Icons.lock_outline_rounded,
                  onBack: () => Navigator.pop(context),
                ),
                Expanded(
                  child: SmartLockScreen(
                    onBack: () => Navigator.pop(context),
                    highlightId: highlightId,
                  ),
                ),
                BottomNav(
                  currentIndex: -1,
                  onTap: (i) =>
                      Navigator.popUntil(context, (route) => route.isFirst),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToCards(BuildContext context, String? highlight) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: kCream,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  child: TopBar(
                    onHomeTap: () =>
                        Navigator.popUntil(context, (route) => route.isFirst),
                    onLogoutTap: () =>
                        Navigator.popUntil(context, (route) => route.isFirst),
                    onNotificationTap: () => showNotifications(context),
                  ),
                ),
                LoanHeader(
                  title: "",
                  subtitle: "Cards & Forex",
                  icon: Icons.credit_card_outlined,
                  onBack: () => Navigator.pop(context),
                ),
                Expanded(
                  child: CardsAndForexScreen(highlightAction: highlight),
                ),
                BottomNav(
                  currentIndex: -1,
                  onTap: (i) =>
                      Navigator.popUntil(context, (route) => route.isFirst),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showReportLostCardModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 24,
          left: 20,
          right: 20,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: const BoxDecoration(
                  color: Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Report Lost Card',
              style: TextStyle(
                color: kForest,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter your card details to report it lost or stolen.',
              style: TextStyle(color: kSub, fontSize: 13),
            ),
            const SizedBox(height: 24),
            const Text(
              'Card Number',
              style: TextStyle(
                color: kForest,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'XXXX XXXX XXXX 1234',
                filled: true,
                fillColor: kCream,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Reason',
              style: TextStyle(
                color: kForest,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'e.g. Lost in transit',
                filled: true,
                fillColor: kCream,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Card has been reported lost'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE74C3C),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Report Lost Card',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context,
    String title,
    IconData icon, [
    String? highlight,
  ]) {
    return GestureDetector(
      onTap: () {
        if (title == 'Report lost card') {
          _showReportLostCardModal(context);
        } else if (title == 'Block / Unblock card') {
          _navigateToSmartLock(context, 'card');
        } else {
          _navigateToCards(context, highlight);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: kAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: kForest, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: kForest,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: kSub, size: 20),
          ],
        ),
      ),
    );
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
                onHomeTap: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                onLogoutTap: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                onNotificationTap: () => showNotifications(context),
              ),
            ),
            LoanHeader(
              title: "",
              subtitle: "Cards Services",
              icon: Icons.credit_card_outlined,
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  _buildTile(
                      context, 'View card details', Icons.credit_card_outlined),
                  _buildTile(
                    context,
                    'Block / Unblock card',
                    Icons.lock_outline_rounded,
                    'Block',
                  ),
                  _buildTile(
                      context, 'Set card limits', Icons.sync_rounded, 'Limits'),
                  _buildTile(
                      context, 'Report lost card', Icons.privacy_tip_outlined),
                ],
              ),
            ),
            BottomNav(
              currentIndex: -1,
              onTap: (i) =>
                  Navigator.popUntil(context, (route) => route.isFirst),
            ),
          ],
        ),
      ),
    );
  }
}
