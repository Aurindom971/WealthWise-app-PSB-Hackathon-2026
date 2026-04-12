import 'package:flutter/material.dart';
import 'package:securewealth_twin/features/home/widgets/home_navigation_widgets.dart';
import 'order_cheque_book_page.dart';

class ManageDeliverablesPage extends StatefulWidget {
  const ManageDeliverablesPage({super.key});

  // Global-like static state for the session
  static final List<Map<String, String>> trackedOrders = [];

  @override
  State<ManageDeliverablesPage> createState() => _ManageDeliverablesPageState();
}

class _ManageDeliverablesPageState extends State<ManageDeliverablesPage> {
  bool isOrderTab = true;

  Widget _buildOrderTile(String title, String subtitle, IconData icon) {
    return GestureDetector(
      onTap: () {
        if (title == 'Cheque Book') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OrderChequeBookPage()),
          ).then((_) => setState(() {})); // Refresh in case an order was added
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
              child: Icon(icon, color: kForest, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: kForest,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: kSub,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: kSub, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackedCard(Map<String, String> order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order['title']!,
                      style: const TextStyle(
                        color: kForest,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: kAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        order['status']!,
                        style: const TextStyle(
                          color: kForest,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Ordered on ${order['date']}',
                  style: const TextStyle(
                    color: kSub,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
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
          'Order Deliverables',
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
      ),
      body: Column(
        children: [
          // Custom Tab Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => isOrderTab = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      color: isOrderTab ? kForest : kAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Order',
                      style: TextStyle(
                        color: isOrderTab ? Colors.white : kSub,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => setState(() => isOrderTab = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      color: !isOrderTab ? kForest : kAccent.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Track',
                      style: TextStyle(
                        color: !isOrderTab ? Colors.white : kSub,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Top divider
          Container(color: kSub.withOpacity(0.1), height: 1),
          // Content
          Expanded(
            child: isOrderTab
                ? ListView(
                    padding: const EdgeInsets.all(18),
                    children: [
                      const Text(
                        'Order cheque books, cards, and other banking\ndeliverables',
                        style: TextStyle(
                          color: kSub,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildOrderTile(
                        'Cheque Book',
                        'Order a new cheque book for your account',
                        Icons.menu_book_rounded,
                      ),
                      _buildOrderTile(
                        'Debit Card',
                        'Request a new or replacement debit card',
                        Icons.credit_card_outlined,
                      ),
                      _buildOrderTile(
                        'Credit Card',
                        'Apply for a credit card',
                        Icons.credit_card_outlined,
                      ),
                      _buildOrderTile(
                        'Passbook',
                        'Request a new passbook',
                        Icons.import_contacts_rounded,
                      ),
                      _buildOrderTile(
                        'Welcome Kit',
                        'Request a welcome kit with account essentials',
                        Icons.inventory_2_outlined,
                      ),
                      _buildOrderTile(
                        'Token / Security Device',
                        'Order a hardware security token',
                        Icons.shield_outlined,
                      ),
                    ],
                  )
                : ManageDeliverablesPage.trackedOrders.isEmpty
                    ? const Center(
                        child: Text(
                          'No active requests found.',
                          style: TextStyle(color: kSub),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(18),
                        itemCount: ManageDeliverablesPage.trackedOrders.length,
                        itemBuilder: (context, i) {
                          return _buildTrackedCard(ManageDeliverablesPage.trackedOrders[i]);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
