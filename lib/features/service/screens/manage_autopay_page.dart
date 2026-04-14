import 'package:flutter/material.dart';
import 'package:securewealth_twin/features/home/widgets/home_navigation_widgets.dart';

enum AutopayStatus { active, skipped, stopped }

class AutopayMandate {
  final String title;
  final String subtitle;
  final String amount;
  final IconData icon;
  final Color iconBgColor;
  AutopayStatus status;
  bool isExpanded;

  AutopayMandate({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.icon,
    required this.iconBgColor,
    this.status = AutopayStatus.active,
    this.isExpanded = false,
  });
}

class ManageAutopayPage extends StatefulWidget {
  const ManageAutopayPage({super.key});

  @override
  State<ManageAutopayPage> createState() => _ManageAutopayPageState();
}

class _AutopayMandateCard extends StatelessWidget {
  final AutopayMandate mandate;
  final VoidCallback onToggle;
  final VoidCallback onSkip;
  final VoidCallback onReactivate;
  final VoidCallback onStop;
  final VoidCallback onRemove;

  const _AutopayMandateCard({
    required this.mandate,
    required this.onToggle,
    required this.onSkip,
    required this.onReactivate,
    required this.onStop,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          if (mandate.status == AutopayStatus.skipped && mandate.isExpanded)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: kSub.withOpacity(0.05),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Next payment skipped',
                          style: TextStyle(
                            color: kForest,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'The upcoming debit has been cancelled.',
                          style: TextStyle(
                            color: kForest.withOpacity(0.7),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: kSub),
                    onPressed: () {}, // visual only or same as toggle?
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: mandate.iconBgColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(mandate.icon, color: mandate.iconBgColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mandate.title,
                        style: const TextStyle(
                          color: kForest,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mandate.subtitle,
                        style: const TextStyle(
                          color: kSub,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      mandate.amount,
                      style: const TextStyle(
                        color: kForest,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mandate.status == AutopayStatus.active
                          ? 'Active'
                          : mandate.status == AutopayStatus.skipped
                              ? 'Skipped'
                              : 'Stopped',
                      style: TextStyle(
                        color: mandate.status == AutopayStatus.active
                            ? kAccent
                            : mandate.status == AutopayStatus.skipped
                                ? Colors.orange
                                : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (mandate.isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  if (mandate.status != AutopayStatus.stopped)
                    Expanded(
                      child: GestureDetector(
                        onTap: mandate.status == AutopayStatus.active ? onSkip : onReactivate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: mandate.status == AutopayStatus.active
                                ? const Color(0xFFFFEBEE)
                                : const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              mandate.status == AutopayStatus.active ? 'Skip Next' : 'Reactivate',
                              style: TextStyle(
                                color: mandate.status == AutopayStatus.active
                                    ? Colors.red
                                    : kAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (mandate.status != AutopayStatus.stopped)
                    const SizedBox(width: 12),
                  if (mandate.status != AutopayStatus.stopped)
                    Expanded(
                      child: GestureDetector(
                        onTap: onStop,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53935),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              'Stop Autopay',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (mandate.status == AutopayStatus.stopped)
                    Expanded(
                      child: GestureDetector(
                        onTap: onRemove,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53935),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              'Remove Mandate',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: onToggle,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: kSub.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          color: kForest,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            GestureDetector(
              onTap: onToggle,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: const Center(
                  child: Text(
                    'Review / Manage',
                    style: TextStyle(
                      color: kMid,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ManageAutopayPageState extends State<ManageAutopayPage> {
  final List<AutopayMandate> _mandates = [
    AutopayMandate(
      title: 'Netflix Subscription',
      subtitle: 'Monthly • Next: 25 Apr 2026',
      amount: '₹649',
      icon: Icons.movie_filter_rounded,
      iconBgColor: const Color(0xFF1E1E1E),
    ),
    AutopayMandate(
      title: 'Electricity Bill',
      subtitle: 'Monthly • Next: 01 May 2026',
      amount: '₹2,340',
      icon: Icons.bolt_rounded,
      iconBgColor: const Color(0xFF4CAF50),
    ),
    AutopayMandate(
      title: 'Jio Fiber',
      subtitle: 'Monthly • Next: 15 Apr 2026',
      amount: '₹999',
      icon: Icons.wifi_rounded,
      iconBgColor: const Color(0xFF1976D2),
    ),
    AutopayMandate(
      title: 'Life Insurance Premium',
      subtitle: 'Quarterly • Next: 01 Jun 2026',
      amount: '₹12,500',
      icon: Icons.shield_outlined,
      iconBgColor: const Color(0xFF00796B),
    ),
    AutopayMandate(
      title: 'Credit Card Auto-Pay',
      subtitle: 'Monthly • Next: 05 May 2026',
      amount: 'Min. Due',
      icon: Icons.credit_card_rounded,
      iconBgColor: const Color(0xFF5D4037),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    int activeCount = _mandates.where((m) => m.status != AutopayStatus.stopped).length;

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
          'Manage Autopay',
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
      body: _mandates.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: kCard,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.autorenew_rounded, size: 50, color: kSub),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No active autopay mandates',
                    style: TextStyle(
                      color: kSub,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
              children: [
                Text(
                  '$activeCount active mandates',
                  style: const TextStyle(
                    color: kSub,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                ..._mandates.map((mandate) => _AutopayMandateCard(
                      mandate: mandate,
                      onToggle: () => setState(() => mandate.isExpanded = !mandate.isExpanded),
                      onSkip: () {
                        setState(() {
                          mandate.status = AutopayStatus.skipped;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Next payment skipped')),
                        );
                      },
                      onReactivate: () {
                        setState(() {
                          mandate.status = AutopayStatus.active;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Autopay reactivated')),
                        );
                      },
                      onStop: () {
                        setState(() {
                          mandate.status = AutopayStatus.stopped;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Autopay stopped')),
                        );
                      },
                      onRemove: () {
                        setState(() {
                          _mandates.remove(mandate);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Mandate removed permanently')),
                        );
                      },
                    )),
              ],
            ),
    );
  }
}
