import 'package:flutter/material.dart';

// ─── PALETTE ─────────────────────────────────────────────────────────────────
const kForest = Color(0xFF1A3328);
const kMid = Color(0xFF245C3F);
const kAccent = Color(0xFF4CAF7A);
const kCream = Color(0xFFF2F0EB);
const kCard = Color(0xFFFFFFFF);
const kSub = Color(0xFF9A9A94);
const kInk = Color(0xFF1A1A18);

class TopBar extends StatelessWidget {
  final VoidCallback onHomeTap;
  final VoidCallback onLogoutTap;
  final VoidCallback? onNotificationTap;

  const TopBar({super.key, required this.onHomeTap, required this.onLogoutTap, this.onNotificationTap});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Bubble(
        onTap: onHomeTap,
        child: const Icon(Icons.home_rounded, color: kForest, size: 22),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            color: kCard,
            borderRadius: BorderRadius.circular(23),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3))
            ],
          ),
          child: Row(children: [
            const SizedBox(width: 16),
            const Icon(Icons.search_rounded, color: kSub, size: 20),
            const SizedBox(width: 8),
            Text(searchText,
                style: const TextStyle(
                    color: kSub, fontSize: 14, fontWeight: FontWeight.w400)),
          ]),
        ),
      ),
      const SizedBox(width: 10),
      Bubble(
          onTap: onNotificationTap,
          child: Stack(clipBehavior: Clip.none, children: [
        Icon(Icons.notifications_none_rounded, color: kInk, size: 20),
        Positioned(
          top: -2,
          right: -2,
          child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                  color: Color(0xFFE53935), shape: BoxShape.circle)),
        ),
      ])),
      const SizedBox(width: 8),
      Bubble(
          onTap: onLogoutTap,
          child: const Icon(Icons.power_settings_new_rounded,
              color: Color(0xFFE53935), size: 20)),
    ]);
  }
}

class Bubble extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  const Bubble({super.key, required this.child, this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: kCard,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 10,
                  offset: const Offset(0, 3))
            ],
          ),
          child: child,
        ),
      );
}

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const BottomNav({super.key, required this.currentIndex, required this.onTap});

  static const _items = [
    (Icons.person_rounded, 'Profile', false),
    (Icons.swap_horiz_rounded, 'Transactions', false),
    (Icons.qr_code_scanner_rounded, 'UPI', true),
    (Icons.bar_chart_rounded, 'Investments', false),
    (Icons.lock_rounded, 'Smart Lock', false),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kCard,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4))
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final (icon, label, isCenter) = _items[i];
              final active = currentIndex == i;

              if (isCenter) {
                return GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/qr_scanner'),
                  child: Container(
                    width: 60,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [kForest, kMid],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: kForest.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4))
                      ],
                    ),
                    child: const Icon(Icons.qr_code_scanner_rounded,
                        color: Colors.white, size: 22),
                  ),
                );
              }

              return GestureDetector(
                onTap: () => onTap(i),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: active ? 28 : 0,
                      height: active ? 3 : 0,
                      margin: EdgeInsets.only(bottom: active ? 4 : 0),
                      decoration: BoxDecoration(
                        color: kAccent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Icon(icon,
                        size: 22, color: active ? kForest : kSub),
                    const SizedBox(height: 3),
                    Text(label,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: active
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: active ? kForest : kSub)),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
