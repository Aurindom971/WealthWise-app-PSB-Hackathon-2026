import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FeatureActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const FeatureActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isHighlighted = false,
  });

  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFDCF0E5),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: isHighlighted 
                    ? const Color(0xFF38B27C).withOpacity(0.4) 
                    : Colors.black.withOpacity(0.05),
                  blurRadius: isHighlighted ? 15 : 10,
                  spreadRadius: isHighlighted ? 2 : 0,
                  offset: isHighlighted ? Offset.zero : const Offset(0, 4),
                ),
              ],
              border: isHighlighted 
                ? Border.all(color: const Color(0xFF38B27C), width: 2) 
                : null,
            ),
            child: Icon(
              icon,
              color: const Color(0xFF1F5D3A),
              size: 26,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
