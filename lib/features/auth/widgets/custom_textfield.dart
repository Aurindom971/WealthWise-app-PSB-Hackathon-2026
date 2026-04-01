import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        obscureText: obscureText,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          icon: Icon(prefixIcon, size: 18, color: Colors.grey),
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}