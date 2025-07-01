import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:plan_ease/page/profile/profile.dart';
import 'package:plan_ease/page/home/home.dart';
import 'package:plan_ease/page/schedule/schedule.dart';

class CustomBottomBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomBar({super.key, required this.currentIndex});

  Route _animatedRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        final slideTween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        final fadeTween = Tween<double>(begin: 0.0, end: 1.0);

        return SlideTransition(
          position: animation.drive(slideTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget destination;
    switch (index) {
      case 0:
        destination = const HomeScreen();
        break;
      case 1:
        destination = const JadwalScreen();
        break;
      case 2:
      default:
        destination = const ProfileScreen();
        break;
    }

    Navigator.push(context, _animatedRoute(destination));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      margin: const EdgeInsets.only(bottom: 16, left: 60, right: 60),
      decoration: BoxDecoration(
        color: const Color(0xFF1E8C7A),
        borderRadius: BorderRadius.circular(40),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(
              FontAwesomeIcons.home,
              color: currentIndex == 0 ? Colors.white : Colors.white54,
            ),
            onPressed: () => _onItemTapped(context, 0),
          ),
          IconButton(
            icon: Icon(
              FontAwesomeIcons.calendar,
              color: currentIndex == 1 ? Colors.white : Colors.white54,
            ),
            onPressed: () => _onItemTapped(context, 1),
          ),
          IconButton(
            icon: Icon(
              Icons.person,
              color: currentIndex == 2 ? Colors.white : Colors.white54,
            ),
            onPressed: () => _onItemTapped(context, 2),
          ),
        ],
      ),
    );
  }
}
