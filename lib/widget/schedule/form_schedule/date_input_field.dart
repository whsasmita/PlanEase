import 'package:flutter/material.dart';

class DateInputField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData prefixIcon;
  final VoidCallback onTap;
  final bool enabled;
  final String? Function(String?)? validator;

  const DateInputField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.prefixIcon,
    required this.onTap,
    this.enabled = true,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      enabled: enabled,
      onTap: enabled ? onTap : null,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF1E8C7A)),
        suffixIcon: const Icon(
          Icons.calendar_today,
          color: Color(0xFF1E8C7A),
        ),
      ),
      validator: validator,
    );
  }
}