// lib/page/schedule/detail_schedule.dart
import 'package:flutter/material.dart';
import 'package:plan_ease/model/schedule.dart';
import 'package:plan_ease/widget/schedule/detail/detail_actions_menu.dart'; // Import DetailActionsMenu
import 'package:plan_ease/widget/schedule/detail/detail_content_section.dart'; // Import DetailContentSection

class DetailScheduleScreen extends StatelessWidget {
  final Schedule schedule;
  final bool isAdmin;
  final VoidCallback onEdit;
  final Function(int?) onDelete;

  const DetailScheduleScreen({
    super.key,
    required this.schedule,
    required this.isAdmin,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9E5D6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E8C7A),
        title: const Text(
          'Detail Kegiatan',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        // Menggunakan widget DetailActionsMenu baru
        actions: [
          DetailActionsMenu(
            schedule: schedule,
            isAdmin: isAdmin,
            onEdit: onEdit,
            onDelete: onDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        // Menggunakan widget DetailContentSection baru
        child: DetailContentSection(schedule: schedule),
      ),
    );
  }
}