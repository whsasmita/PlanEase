import 'package:flutter/material.dart';

class LabeledTextField extends StatelessWidget {
  final String label;
  final bool obscureText;

  const LabeledTextField({super.key, required this.label, this.obscureText = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$label :', style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            obscureText: obscureText,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 6),
              border: UnderlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }
}
