// lib/widget/schedule/detail/detail_actions_menu.dart
import 'package:flutter/material.dart';
import 'package:plan_ease/model/schedule.dart'; // Import model Schedule

class DetailActionsMenu extends StatelessWidget {
  final Schedule schedule;
  final bool isAdmin;
  final VoidCallback onEdit;
  final Function(int?) onDelete; // ID bisa null

  const DetailActionsMenu({
    super.key,
    required this.schedule,
    required this.isAdmin,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (!isAdmin) {
      return const SizedBox(); // Tidak tampilkan apa-apa jika bukan admin
    }

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      onSelected: (String result) async {
        if (result == 'edit') {
          onEdit(); // Panggil callback edit
        } else if (result == 'delete') {
          // Lakukan pengecekan ID di sini juga untuk jaga-jaga
          if (schedule.id == null || schedule.id! <= 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('ID jadwal tidak valid dan tidak bisa dihapus.'),
              ),
            );
            return;
          }

          // Tampilkan dialog konfirmasi
          final bool? confirmDelete = await showDialog<bool>(
            context: context,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                title: const Text('Konfirmasi Hapus'),
                content: const Text('Apakah Anda yakin ingin menghapus jadwal ini?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: const Text('Batal'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Hapus'),
                  ),
                ],
              );
            },
          );

          if (confirmDelete == true) {
            try {
              await onDelete(schedule.id); // Panggil callback delete
              // Pop halaman ini setelah penghapusan berhasil
              if (context.mounted) {
                Navigator.pop(context, true); // Kembali dengan hasil 'true'
              }
            } catch (e) {
              // Error akan ditangani di JadwalScreen melalui SnackBar
              print('Error during delete from DetailScreen menu: $e');
            }
          }
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'edit',
          child: ListTile(
            leading: Icon(Icons.edit, color: Colors.blue),
            title: Text('Edit'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text('Hapus'),
          ),
        ),
      ],
    );
  }
}