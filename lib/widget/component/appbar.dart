import 'package:flutter/material.dart';
import 'package:plan_ease/page/profile/profile.dart';
import 'package:plan_ease/page/notification/notification.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF1E8C7A),
      title: const Text('Plan Ease'),
      centerTitle: true,
      leading: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        },
        child: const CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(Icons.person, color: Colors.grey),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationScreen()),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
