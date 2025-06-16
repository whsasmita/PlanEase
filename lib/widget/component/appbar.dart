import 'package:flutter/material.dart';
import 'package:plan_ease/page/profile/profile.dart';
import 'package:plan_ease/page/notification/notification.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  Route _animatedRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        const begin = Offset(0.0, 1.0); // slide from bottom
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        final tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        final fadeTween = Tween<double>(begin: 0.0, end: 1.0);

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(180),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background lengkung hijau
          Container(
            height: 150,
            decoration: const BoxDecoration(
              color: Color(0xFF1E8C7A),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(100),
                bottomRight: Radius.circular(100),
              ),
            ),
          ),

          // Konten AppBar
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar user
                GestureDetector(
                  child: const CircleAvatar(
                    radius: 18,
                    backgroundImage: AssetImage('assets/images/user.jpg'),
                  ),
                ),

                // Judul tengah
                const Expanded(
                  child: Center(
                    child: Text(
                      'Plan Ease',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // Ikon notifikasi
                IconButton(
                  icon: const Icon(Icons.notifications_none, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).push(_animatedRoute(const NotificationScreen()));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(180);
}
