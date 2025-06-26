// lib/widget/schedule/detail/schedule_status_widget.dart
import 'package:flutter/material.dart';
import 'package:plan_ease/model/schedule.dart';
import 'package:plan_ease/widget/schedule/detail/status_chip.dart';

class ScheduleStatusWidget extends StatelessWidget {
  final Schedule schedule;

  const ScheduleStatusWidget({
    super.key,
    required this.schedule,
  });

  @override
  Widget build(BuildContext context) {
    if (schedule.isPast()) {
      return StatusChip(text: 'Selesai', color: Colors.redAccent);
    } else if (schedule.isActive()) {
      return StatusChip(text: 'Aktif', color: Colors.green);
    } else if (schedule.isUpcoming()) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '${schedule.getDaysUntilStart()} hari lagi',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    return const SizedBox(); // Return empty widget if no status applies
  }
}