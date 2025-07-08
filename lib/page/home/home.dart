import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:plan_ease/page/notula/notula.dart';
import 'package:plan_ease/page/polling/polling.dart';
import 'package:plan_ease/page/schedule/schedule.dart';
import 'package:plan_ease/widget/home/home.dart';
import 'package:plan_ease/widget/component/appbar.dart';
import 'package:plan_ease/widget/component/bottombar.dart';
import 'package:plan_ease/service/auth_service.dart';
import 'package:plan_ease/service/polling_service.dart';
import 'package:plan_ease/service/schedule_service.dart';
import 'package:plan_ease/service/profile_service.dart'; // Import ProfileService
import 'package:plan_ease/model/polling.dart' as PollingModel;
import 'package:plan_ease/model/schedule.dart' as ScheduleModel;
import 'package:plan_ease/model/profile.dart'; // Import Profile model

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _pageController;
  int _currentPage = 1;

  final List<Widget> _slides = [
    'assets/images/carousel1.webp',
    'assets/images/carousel2.webp',
    'assets/images/carousel3.jpeg',
  ].map((imagePath) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.broken_image,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Image not found',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }).toList();

  String _userRole = '';
  late final AuthService _authService;
  late final PollingService _pollingService;
  late final ScheduleService _scheduleService;
  late final ProfileService _profileService; // Declare ProfileService
  Profile? _userProfile; // Declare _userProfile to store profile data

  // State untuk data terbaru
  List<PollingModel.Polling> _recentPollings = [];
  List<ScheduleModel.Schedule> _recentSchedules = [];
  bool _isLoadingRecentPollings = true;
  bool _isLoadingRecentSchedules = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1);
    _authService = AuthService();
    _pollingService = PollingService(_authService);
    _scheduleService = ScheduleService(_authService);
    _profileService = ProfileService(_authService); // Initialize ProfileService

    _loadUserDataAndRecentItems();
  }

  // Fungsi untuk memuat role pengguna, item terbaru, dan profil pengguna
  Future<void> _loadUserDataAndRecentItems() async {
    await _loadUserRole();
    await _fetchRecentPollings();
    await _fetchRecentSchedules();
    await _fetchUserProfile(); // Call to fetch user profile
  }

  // Fungsi untuk memuat role pengguna dari AuthService
  Future<void> _loadUserRole() async {
    String? role = await _authService.getUserRole();
    setState(() {
      _userRole = role ?? '';
    });
  }

  // CORRECTED: Function to fetch user profile
  Future<void> _fetchUserProfile() async {
    try {
      // Assuming _authService.getCurrentUserId() returns Future<int?>
      final int? userId = await _authService.getCurrentUserId();

      if (userId != null) {
        // Pass the int userId directly to getProfileUser
        final profile = await _profileService.getProfileUser(userId);
        setState(() {
          _userProfile = profile;
        });
      } else {
        // Handle the case where userId is null (e.g., user not logged in)
        print('User ID is null. Cannot fetch profile.');
        // Optionally, set _userProfile to a default/empty profile or show a message
      }
    } catch (e) {
      print('Error fetching user profile for AppBar: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat profil pengguna: ${e.toString().replaceFirst('Exception: ', '')}')),
        );
      }
    }
  }

  // Fungsi untuk mengambil 3 polling terbaru
  Future<void> _fetchRecentPollings() async {
    setState(() {
      _isLoadingRecentPollings = true;
    });
    try {
      final pollings = await _pollingService.getPollings();
      setState(() {
        _recentPollings = pollings.take(3).toList();
      });
    } catch (e) {
      print('Error fetching recent pollings: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat polling terbaru: ${e.toString().replaceFirst('Exception: ', '')}')),
        );
      }
    } finally {
      setState(() {
        _isLoadingRecentPollings = false;
      });
    }
  }

  // Fungsi untuk mengambil 3 jadwal terbaru
  Future<void> _fetchRecentSchedules() async {
    setState(() {
      _isLoadingRecentSchedules = true;
    });
    try {
      final schedules = await _scheduleService.getSchedules();
      setState(() {
        _recentSchedules = schedules.take(3).toList();
      });
    } catch (e) {
      print('Error fetching recent schedules: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat jadwal terbaru: ${e.toString().replaceFirst('Exception: ', '')}')),
        );
        }
    } finally {
      setState(() {
        _isLoadingRecentSchedules = false;
      });
    }
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    if (index == 0) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _pageController.jumpToPage(_slides.length);
      });
    } else if (index == _slides.length + 1) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _pageController.jumpToPage(1);
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Route _createFancyRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
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
      transitionDuration: const Duration(milliseconds: 600),
    );
  }

  Widget _buildLoopingCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _slides.length + 2,
            itemBuilder: (context, index) {
              if (index == 0) return _slides.last;
              if (index == _slides.length + 1) return _slides.first;
              return _slides[index - 1];
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_slides.length, (i) {
            int effectivePage =
                _currentPage == 0
                    ? _slides.length - 1
                    : _currentPage == _slides.length + 1
                        ? 0
                        : _currentPage - 1;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: effectivePage == i ? 12 : 8,
              height: effectivePage == i ? 12 : 8,
              decoration: BoxDecoration(
                color:
                    effectivePage == i ? const Color(0xFF1E8C7A) : Colors.grey,
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9E5D6),
      // Pass the fetched _userProfile to CustomAppBar
      appBar: CustomAppBar(userProfile: _userProfile),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  MenuIcon(
                    icon: FontAwesomeIcons.fileLines,
                    label: 'Notula',
                    onTap: () {
                      Navigator.push(
                        context,
                        _createFancyRoute(const NotulaScreen()),
                      );
                    },
                  ),
                  MenuIcon(
                    icon: FontAwesomeIcons.pollH,
                    label: 'Polling',
                    onTap: () {
                      Navigator.push(
                        context,
                        _createFancyRoute(const PollingScreen()),
                      );
                    },
                  ),
                  MenuIcon(
                    icon: FontAwesomeIcons.calendarDays,
                    label: 'Jadwal',
                    onTap: () {
                      Navigator.push(
                        context,
                        _createFancyRoute(const JadwalScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildLoopingCarousel(),
            const SizedBox(height: 20),
            SectionCard(
              title: 'Polling berjalan',
              items: _recentPollings.map((p) => p.title).toList(),
              isLoading: _isLoadingRecentPollings,
            ),
            const SizedBox(height: 12),
            SectionCard(
              title: 'Kegiatan terbaru',
              items: _recentSchedules.map((s) => s.title).toList(),
              isLoading: _isLoadingRecentSchedules,
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomBar(currentIndex: 0),
    );
  }
}