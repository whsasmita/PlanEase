import 'package:flutter/material.dart';
import 'package:plan_ease/page/profile/profile.dart';
import 'package:plan_ease/page/notification/notification.dart';
import 'package:plan_ease/model/profile.dart'; // Import your Profile model

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  // 1. Add a Profile parameter
  final Profile? userProfile;

  const CustomAppBar({super.key, this.userProfile});

  Route _animatedRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        const begin = Offset(0.0, 1.0);
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
                  // Navigate to ProfileScreen when avatar is tapped
                  onTap: () {
                    Navigator.of(context).push(_animatedRoute(const ProfileScreen()));
                  },
                  child: CircleAvatar(
                    radius: 18,
                    // 2. Use conditional logic for backgroundImage
                    backgroundImage: (userProfile?.photoProfileUrl != null &&
                            userProfile!.photoProfileUrl!.isNotEmpty)
                        ? NetworkImage(userProfile!.photoProfileUrl!) as ImageProvider<Object>
                        : const AssetImage('assets/images/default_profile.png'), // Fallback image
                    backgroundColor: Colors.grey[200],
                    child: (userProfile?.photoProfileUrl != null &&
                            userProfile!.photoProfileUrl!.isNotEmpty)
                        ? ClipOval(
                            child: Image.network(
                              userProfile!.photoProfileUrl!,
                              width: 36, // Double the radius for width/height
                              height: 36, // Double the radius for width/height
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    strokeWidth: 2,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                print('Error loading profile image in AppBar: $error');
                                return Icon(
                                  Icons.broken_image,
                                  size: 18, // Half the radius for icon size
                                  color: Colors.grey[400],
                                );
                              },
                            ),
                          )
                        : null, // No child if using default asset image
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