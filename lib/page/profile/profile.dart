import 'package:flutter/material.dart';
import 'package:plan_ease/widget/component/appbar.dart';
import 'package:plan_ease/widget/component/bottombar.dart';
import 'package:plan_ease/widget/profile/profile.dart';
import 'package:plan_ease/page/login/login.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Fungsi animasi slide + fade ke LoginScreen
  Route _slideOnlyToLogin(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0); // dari bawah
        const end = Offset.zero;
        const curve = Curves.easeOut;

        final tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 600),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9E5D6),
      appBar: const CustomAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ProfileCard(),
          const SizedBox(height: 20),
          const MenuTile(icon: Icons.settings, text: 'Pengaturan'),
          MenuTile(
            icon: Icons.logout,
            text: 'Keluar',
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                _slideOnlyToLogin(const LoginScreen()),
                (route) => false,
              );
            },
          ),
          const MenuTile(icon: Icons.info_outline, text: 'V 1.0'),
        ],
      ),
      bottomNavigationBar: const CustomBottomBar(currentIndex: 2),
    );
  }
}
