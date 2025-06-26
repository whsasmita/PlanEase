// lib/widget/notula/notula.dart
import 'package:flutter/material.dart';
import 'package:plan_ease/model/notula.dart';

class NotulaListItem extends StatelessWidget {
  final Notula notula;
  final bool isAdmin;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap; // NEW: Callback for tapping the item itself

  const NotulaListItem({
    super.key,
    required this.notula,
    this.isAdmin = false,
    this.onEdit,
    this.onDelete,
    this.onTap, // NEW: Add to constructor
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 3,
      child: InkWell( // WRAP with InkWell to make it tappable
        onTap: onTap, // Assign the onTap callback
        borderRadius: BorderRadius.circular(12.0), // Match Card's border radius
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notula.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF1E8C7A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                notula.description,
                style: const TextStyle(fontSize: 16),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              // Edit and Delete Buttons for Admin
              if (isAdmin && (onEdit != null || onDelete != null))
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (onEdit != null)
                        IconButton(
                          icon: const Icon(Icons.edit, color: Color(0xFF1E8C7A)),
                          onPressed: onEdit,
                          tooltip: 'Edit Notula',
                        ),
                      if (onDelete != null)
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: onDelete,
                          tooltip: 'Hapus Notula',
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}