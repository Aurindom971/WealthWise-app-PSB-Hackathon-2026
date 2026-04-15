import 'package:flutter/material.dart';
import 'package:securewealth_twin/features/home/widgets/home_navigation_widgets.dart';

class YourRequestsPage extends StatefulWidget {
  const YourRequestsPage({super.key});

  @override
  State<YourRequestsPage> createState() => _YourRequestsPageState();
}

class _YourRequestsPageState extends State<YourRequestsPage> {
  bool isNewApplication = true;
  String selectedCategory = 'All';
  final List<Map<String, String>> trackedApplications = [];

  final List<Map<String, String>> categories = [
    {'label': 'All'},
    {'label': 'Account'},
    {'label': 'Loan'},
    {'label': 'Card'},
    {'label': 'Insurance'},
  ];

  final List<Map<String, String>> applications = [
    {
      'title': 'Open Fixed Deposit',
      'subtitle': 'Start a new FD with competitive interest rates',
      'category': 'Account',
    },
    {
      'title': 'Open Recurring Deposit',
      'subtitle': 'Set up a monthly recurring deposit',
      'category': 'Account',
    },
    {
      'title': 'Apply for Personal Loan',
      'subtitle': 'Get a personal loan at attractive rates',
      'category': 'Loan',
    },
    {
      'title': 'Apply for Home Loan',
      'subtitle': 'Finance your dream home',
      'category': 'Loan',
    },
    {
      'title': 'Apply for Credit Card',
      'subtitle': 'Get a credit card with great rewards',
      'category': 'Card',
    },
    {
      'title': 'Apply for Insurance',
      'subtitle': 'Protect yourself with insurance plans',
      'category': 'Insurance',
    },
  ];

  void _showApplyDialog(Map<String, String> app) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Application Started',
          style: TextStyle(color: kForest, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Your application has started and you can now track it under the track application option.',
          style: TextStyle(color: kInk),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                trackedApplications.add({
                  ...app,
                  'status': 'In Progress',
                  'date': 'Oct 12, 2023',
                });
              });
              Navigator.pop(context);
            },
            child: const Text(
              'OK',
              style: TextStyle(color: kMid, fontWeight: FontWeight.bold),
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
          'Your Requests',
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
      body: Column(
        children: [
          const SizedBox(height: 20),
          // Toggle Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isNewApplication = true),
                    child: Container(
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isNewApplication
                            ? kForest
                            : kSub.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Text(
                        'New Application',
                        style: TextStyle(
                          color: isNewApplication ? Colors.white : kSub,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isNewApplication = false),
                    child: Container(
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: !isNewApplication
                            ? kForest
                            : kSub.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Text(
                        'Track Requests',
                        style: TextStyle(
                          color: !isNewApplication ? Colors.white : kSub,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Category Filters
          SizedBox(
            height: 36,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final cat = categories[i]['label']!;
                final isActive = selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => selectedCategory = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isActive
                          ? kAccent.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isActive ? kAccent : kSub.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: isActive ? kForest : kSub,
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Application List
          Expanded(
            child: isNewApplication
                ? ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    itemCount: applications.length,
                    itemBuilder: (context, i) {
                      final app = applications[i];
                      if (selectedCategory != 'All' &&
                          app['category'] != selectedCategory) {
                        return const SizedBox.shrink();
                      }
                      return _buildApplicationCard(app);
                    },
                  )
                : trackedApplications.isEmpty
                ? const Center(
                    child: Text(
                      'No requests to track yet.',
                      style: TextStyle(color: kSub),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    itemCount: trackedApplications.length,
                    itemBuilder: (context, i) {
                      final app = trackedApplications[i];
                      if (selectedCategory != 'All' &&
                          app['category'] != selectedCategory) {
                        return const SizedBox.shrink();
                      }
                      return _buildTrackedCard(app);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationCard(Map<String, String> app) {
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
                Text(
                  app['title']!,
                  style: const TextStyle(
                    color: kForest,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  app['subtitle']!,
                  style: const TextStyle(color: kSub, fontSize: 12),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showApplyDialog(app),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: kForest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Apply',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackedCard(Map<String, String> app) {
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
                      app['title']!,
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
                        app['status']!,
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
                  'Applied on ${app['date']}',
                  style: const TextStyle(color: kSub, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
