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

  void _showOrderConfirmation(String title, IconData icon) {
    String? selectedSubtype;
    bool isCard = title.contains('Card');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: kSub.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kAccent.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: kForest, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Order $title',
                    style: const TextStyle(
                      color: kForest,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Delivery Address',
                style: TextStyle(
                  color: kSub,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Branch Address (Connaught Place)\nRegistered Local Address',
                style: TextStyle(color: kForest, fontSize: 14, height: 1.5),
              ),
              if (isCard) ...[
                const SizedBox(height: 24),
                const Text(
                  'Select Card Type',
                  style: TextStyle(
                    color: kSub,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildSubtypeOption(
                      'Visa',
                      selectedSubtype == 'Visa',
                      () => setModalState(() => selectedSubtype = 'Visa'),
                    ),
                    const SizedBox(width: 12),
                    _buildSubtypeOption(
                      'Mastercard',
                      selectedSubtype == 'Mastercard',
                      () => setModalState(() => selectedSubtype = 'Mastercard'),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () {
                  if (isCard && selectedSubtype == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a card type'),
                      ),
                    );
                    return;
                  }

                  // Add to tracked orders
                  ManageDeliverablesPage.trackedOrders.insert(0, {
                    'title': isCard ? '$selectedSubtype $title' : title,
                    'status': 'Requested',
                    'date': 'Oct 14, 2023',
                  });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '$title order has been placed successfully',
                      ),
                      backgroundColor: kForest,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  setState(() {});
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: kForest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'Confirm Order',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubtypeOption(
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? kForest : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? kForest : kSub.withOpacity(0.2),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : kForest,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderTile(String title, String subtitle, IconData icon) {
    return GestureDetector(
      onTap: () {
        if (title == 'Cheque Book') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const OrderChequeBookPage(),
            ),
          ).then((_) => setState(() {}));
        } else {
          _showOrderConfirmation(title, icon);
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
                    style: const TextStyle(color: kSub, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: kSub,
              size: 22,
            ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
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
                  style: const TextStyle(color: kSub, fontSize: 12),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
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
                        style: TextStyle(color: kSub, fontSize: 13),
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
                      return _buildTrackedCard(
                        ManageDeliverablesPage.trackedOrders[i],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
