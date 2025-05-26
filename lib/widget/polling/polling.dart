import 'package:flutter/material.dart';

class PollingItem extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;

  const PollingItem({
    super.key,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F6EC),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            leading: Container(
              width: 28,
              height: 28,
              color: const Color(0xFF1E8C7A),
            ),
            title: const Text("Pilih jadwal rapat"),
            subtitle: const Text("12 Mei 2025"),
            trailing: IconButton(
              icon: Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
              ),
              onPressed: onToggle,
            ),
          ),
          if (isExpanded)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  PollingOptionBar(
                    title: '24 Agustus 2025',
                    percentage: 0.8,
                    color: Color(0xFF1E8C7A),
                  ),
                  SizedBox(height: 8),
                  PollingOptionBar(
                    title: '30 Agustus 2025',
                    percentage: 0.1,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class PollingOptionBar extends StatelessWidget {
  final String title;
  final double percentage;
  final Color color;

  const PollingOptionBar({
    super.key,
    required this.title,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        const SizedBox(height: 4),
        Stack(
          children: [
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Container(
              height: 10,
              width: MediaQuery.of(context).size.width * 0.7 * percentage,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text('${(percentage * 100).toInt()}%'),
      ],
    );
  }
}