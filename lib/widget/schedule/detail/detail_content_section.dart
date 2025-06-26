// lib/widget/schedule/detail/detail_content_section.dart
import 'package:flutter/material.dart';
import 'package:plan_ease/model/schedule.dart';
import 'package:plan_ease/widget/schedule/detail/schedule_status_widget.dart'; // Import ScheduleStatusWidget

class DetailContentSection extends StatelessWidget {
  final Schedule schedule;

  const DetailContentSection({
    super.key,
    required this.schedule,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          schedule.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),

        // Date and Status Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              schedule.getFormattedDateRange(),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            ScheduleStatusWidget(schedule: schedule), // Menggunakan ScheduleStatusWidget
          ],
        ),
        const SizedBox(height: 16),

        // Description
        if (schedule.description.isNotEmpty)
          Text(
            schedule.description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
      ],
    );
  }
}