import 'package:flutter/material.dart';
import 'package:securewealth_twin/features/home/widgets/home_navigation_widgets.dart';
import 'package:securewealth_twin/features/cards_and_forex/screens/cards_and_forex_screen.dart';

class CardServicesPage extends StatelessWidget {
  const CardServicesPage({super.key});

  void _navigateToCards(BuildContext context, String? highlight) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: kCream,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: kForest),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Cards & Forex',
              style: TextStyle(
                color: kForest,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: kForest),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.power_settings_new_rounded, color: kForest),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: kSub.withOpacity(0.1), height: 1),
            ),
          ),
          body: CardsAndForexScreen(
            highlightAction: highlight,
          ),
        ),
      ),
    );
  }

  void _navigateToPlaceholder(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: kForest),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              title,
              style: const TextStyle(
                color: kForest,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: kForest),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.power_settings_new_rounded, color: kForest),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: kSub.withOpacity(0.1), height: 1),
            ),
          ),
          backgroundColor: kCream,
          body: const Center(
            child: Text('Under construction', style: TextStyle(color: kSub)),
          ),
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, String title, IconData icon, [String? highlight]) {
    return GestureDetector(
      onTap: () {
        if (title != 'Report lost card') {
          _navigateToCards(context, highlight);
        } else {
          _navigateToPlaceholder(context, title);
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: kForest),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Cards Services',
          style: TextStyle(
            color: kForest,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: kForest),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.power_settings_new_rounded, color: kForest),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: kSub.withOpacity(0.1), height: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _buildTile(context, 'View card details', Icons.credit_card_outlined),
          _buildTile(context, 'Block / Unblock card', Icons.lock_outline_rounded, 'Block'),
          _buildTile(context, 'Set card limits', Icons.sync_rounded, 'Limits'),
          _buildTile(context, 'Report lost card', Icons.privacy_tip_outlined),
        ],
      ),
    );
  }
}
