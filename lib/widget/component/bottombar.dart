import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:plan_ease/page/profile/profile.dart';
import 'package:plan_ease/page/home/home.dart';

class CustomBottomBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == 0 && currentIndex != 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else if (index == 2 && currentIndex != 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        }
      },
      backgroundColor: const Color(0xFF1E8C7A),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white54,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.home), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.calendar), label: 'Kegiatan'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
