import 'package:flutter/material.dart';

class ActivityTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData icon;
  final int maxLines;
  final bool enabled;
  final String? Function(String?)? validator;

  const ActivityTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.icon,
    this.maxLines = 1,
    this.enabled = true,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(icon, color: const Color(0xFF1E8C7A)),
      ),
      validator: validator,
    );
  }
}