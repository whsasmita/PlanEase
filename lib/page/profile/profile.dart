import 'package:flutter/material.dart';
import 'package:plan_ease/widget/component/appbar.dart';
import 'package:plan_ease/widget/component/bottombar.dart';
import 'package:plan_ease/widget/profile/profile.dart';
import 'package:plan_ease/page/login/login.dart';
import 'package:plan_ease/model/profile.dart';
import 'package:plan_ease/service/auth_service.dart';
import 'package:plan_ease/service/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Profile> _profileFuture;
  late ProfileService _profileService;
  late AuthService _authService;

  // NEW: Add a nullable Profile variable to hold the fetched profile
  Profile? _currentProfile;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _profileService = ProfileService(_authService);

    // Initial call to fetch profile data
    _profileFuture = _fetchProfileData();
  }

  Future<Profile> _fetchProfileData() async {
    try {
      final int? currentUserId = await _authService.getCurrentUserId();

      if (currentUserId != null && currentUserId > 0) {
        final fetchedProfile = await _profileService.getProfileUser(currentUserId);
        // NEW: Update the _currentProfile state variable
        if (mounted) {
          setState(() {
            _currentProfile = fetchedProfile;
          });
        }
        return fetchedProfile;
      } else {
        throw Exception('ID Pengguna tidak ditemukan atau tidak valid. Harap login kembali.');
      }
    } catch (e) {
      print('Error fetching profile data: $e');
      rethrow;
    }
  }

  Route _slideOnlyToLogin(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
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
      // NEW: Pass the _currentProfile to CustomAppBar
      // It might be null initially while loading, which CustomAppBar handles.
      appBar: CustomAppBar(userProfile: _currentProfile),
      body: FutureBuilder<Profile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _profileFuture = _fetchProfileData(); // Re-fetch data on retry
                        });
                      },
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasData) {
            final Profile profile = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ProfileCard(profile: profile),
                const SizedBox(height: 20),
                const MenuTile(icon: Icons.settings, text: 'Pengaturan'),
                MenuTile(
                  icon: Icons.logout,
                  text: 'Keluar',
                  onTap: () async {
                    await _authService.clearAuthData();
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pushAndRemoveUntil(
                      _slideOnlyToLogin(const LoginScreen()),
                      (route) => false,
                    );
                  },
                ),
                const MenuTile(icon: Icons.info_outline, text: 'V 1.0'),
              ],
            );
          } else {
            return const Center(child: Text('Tidak ada data profil.'));
          }
        },
      ),
      bottomNavigationBar: const CustomBottomBar(currentIndex: 2),
    );
  }
}

class MenuTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  const MenuTile({
    super.key,
    required this.icon,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F6EC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(text),
        onTap: onTap,
      ),
    );
  }
}