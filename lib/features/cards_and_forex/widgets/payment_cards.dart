import 'package:flutter/material.dart';

class PaymentCard extends StatelessWidget {
  final String type;
  final String number;
  final String balance;
  final String holder;
  final List<Color> gradient;
  final bool obscured;
  final VoidCallback onToggle;
  final int index;
  final int total;

  const PaymentCard({
    super.key,
    required this.type,
    required this.number,
    required this.balance,
    required this.holder,
    required this.gradient,
    this.obscured = false,
    required this.onToggle,
    required this.index,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Glass(type),
              const Spacer(),
              for (int i = 0; i < total; i++)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: _Dot(i == index),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            number,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 14,
              letterSpacing: 2.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'AVAILABLE BALANCE',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onToggle,
                        child: Icon(
                          obscured ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    obscured ? '₹ ••••••' : balance,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    holder,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'VISA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white.withValues(alpha: 0.4), size: 16),
                const SizedBox(width: 6),
                Text(
                  'pull down to reveal next',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Glass extends StatelessWidget {
  final String t;
  const _Glass(this.t);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
    ),
    child: Text(
      t,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 9,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
      ),
    ),
  );
}

class _Dot extends StatelessWidget {
  final bool a;
  const _Dot(this.a);
  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    width: a ? 14 : 6,
    height: 6,
    decoration: BoxDecoration(
      color: a ? const Color(0xFF4CAF7A) : Colors.white.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(3),
    ),
  );
}
