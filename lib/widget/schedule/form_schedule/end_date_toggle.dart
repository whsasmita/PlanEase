import 'package:flutter/material.dart';

class EndDateToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enabled;

  const EndDateToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Switch(
          value: value,
          onChanged: enabled ? onChanged : null,
          activeColor: const Color(0xFF1E8C7A),
        ),
        const SizedBox(width: 8),
        const Text(
          'Tambah Tanggal Selesai',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}