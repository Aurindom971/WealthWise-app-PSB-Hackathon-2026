import 'package:flutter/material.dart';

class BannerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    // Polygon shape with sharp pointed edges
    path.lineTo(size.width - 15, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width - 15, size.height);
    path.lineTo(15, size.height);
    path.lineTo(0, size.height / 2);
    path.lineTo(15, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class AiBanner extends StatelessWidget {
  const AiBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: BannerClipper(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2962FF), Color(0xFF1E88E5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        ),
        child: const Center(
          child: Text(
            "Secure Wealth AI",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
