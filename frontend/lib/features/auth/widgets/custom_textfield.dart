import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final TextEditingController? controller;
  final Widget? suffixIcon;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String)? onChanged;
  final TextInputType? keyboardType;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.controller,
    this.suffixIcon,
    this.maxLength,
    this.inputFormatters,
    this.onChanged,
    this.keyboardType,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

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
        controller: widget.controller,
        obscureText: _isObscured,
        maxLength: widget.maxLength,
        onChanged: widget.onChanged,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        style: const TextStyle(fontSize: 13),
        textAlignVertical: TextAlignVertical.center, // ✅ center text
        decoration: InputDecoration(
          counterText: "", // Hide the character counter for cleaner look
          prefixIcon: Icon(widget.prefixIcon, size: 18, color: Colors.grey),
          suffixIcon: widget.obscureText
              ? IconButton(
                  icon: Icon(
                    _isObscured ? Icons.visibility_off : Icons.visibility,
                    size: 18,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                )
              : widget.suffixIcon,
          hintText: widget.hintText,
          hintStyle: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
          border: InputBorder.none,
          isDense: true, // ✅ compact + centered
          contentPadding: const EdgeInsets.symmetric(vertical: 12), // ✅ balance
        ),
      ),
    );
  }
}