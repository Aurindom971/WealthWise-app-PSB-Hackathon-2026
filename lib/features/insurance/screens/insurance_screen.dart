import 'package:flutter/material.dart';
import '../../home/widgets/home_navigation_widgets.dart';
import '../../home/screens/notifications_screen.dart';

class InsuranceScreen extends StatelessWidget {
  const InsuranceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar matching Home
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: TopBar(
                onHomeTap: () => Navigator.pop(context),
                onLogoutTap: () => Navigator.pop(context),
                onNotificationTap: () => showNotifications(context),
              ),
            ),
            
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE6F0FA),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shield_outlined, size: 64, color: Color(0xFF2F6FD6)),
                    ),
                    const SizedBox(height: 24),
                    const Text('Insurance Module', 
                      style: TextStyle(color: kInk, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Protecting your assets.', 
                      style: TextStyle(color: kSub, fontSize: 14)),
                  ],
                ),
              ),
            ),

            // Bottom Nav matching Home
            BottomNav(
              currentIndex: -1,
              onTap: (i) => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
