import 'package:flutter/material.dart';
import 'package:securewealth_twin/features/home/widgets/home_navigation_widgets.dart';

class AccountServicesPage extends StatelessWidget {
  const AccountServicesPage({super.key});

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

  Widget _buildTile(BuildContext context, String title, IconData icon) {
    return GestureDetector(
      onTap: () => _navigateToPlaceholder(context, title),
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
          'Accounts Services',
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
          _buildTile(context, 'Account statement', Icons.description_outlined),
          _buildTile(context, 'Download passbook', Icons.download_outlined),
          _buildTile(context, 'Nominee management', Icons.shield_outlined),
          _buildTile(context, 'Modify account details', Icons.sync_rounded),
        ],
      ),
    );
  }
}
