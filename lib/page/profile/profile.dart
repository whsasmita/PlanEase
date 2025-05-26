import 'package:flutter/material.dart';
import 'package:plan_ease/widget/component/appbar.dart';
import 'package:plan_ease/widget/component/bottombar.dart';
import 'package:plan_ease/widget/profile/profile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9E5D6),
      appBar: const CustomAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ProfileCard(),
          SizedBox(height: 20),
          MenuTile(icon: Icons.settings, text: 'Pengaturan'),
          MenuTile(icon: Icons.logout, text: 'Keluar'),
          MenuTile(icon: Icons.info_outline, text: 'V 1.0'),
        ],
      ),
      bottomNavigationBar: const CustomBottomBar(currentIndex: 2),
    );
  }
}
