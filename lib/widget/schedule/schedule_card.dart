// lib/widget/schedule/schedule_card.dart
import 'package:flutter/material.dart';
import 'package:plan_ease/model/schedule.dart';

class ScheduleCard extends StatelessWidget {
  final Schedule schedule;
  final bool isOngoing;
  final VoidCallback? onTap;
  final bool isAdmin; // NEW: Add isAdmin property
  final VoidCallback? onEdit; // NEW: Add onEdit callback
  final VoidCallback? onDelete; // NEW: Add onDelete callback

  const ScheduleCard({
    super.key,
    required this.schedule,
    required this.isOngoing,
    this.onTap,
    this.isAdmin = false, // NEW: Default to false
    this.onEdit, // NEW: Add to the constructor
    this.onDelete, // NEW: Add to the constructor
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isOngoing ? const Color(0xFFE8F5E8) : const Color(0xFFF0F6EC),
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(
              width: 4,
              color: isOngoing ? Colors.green : const Color(0xFF1E8C7A),
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              schedule.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              schedule.description,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.schedule, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  schedule.getFormattedDateRange(),
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                const Spacer(),
                if (schedule.isPast()) ...[
                  _buildStatusChip('Selesai', Colors.redAccent),
                ] else if (schedule.isActive()) ...[
                  _buildStatusChip('Aktif', Colors.green),
                ] else if (schedule.isUpcoming()) ...[
                  Text(
                    '${schedule.getDaysUntilStart()} hari lagi',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                // NEW: Add Edit and Delete buttons for admin
                if (isAdmin) ...[
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: onEdit,
                    child: const Icon(Icons.edit, size: 18, color: Colors.blue),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: onDelete,
                    child: const Icon(Icons.delete, size: 18, color: Colors.red),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}