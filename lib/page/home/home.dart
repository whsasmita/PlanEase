import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:plan_ease/page/notula/notula.dart';
import 'package:plan_ease/page/polling/polling.dart';
import 'package:plan_ease/page/schedule/schedule.dart';
import 'package:plan_ease/widget/home/home.dart';
import 'package:plan_ease/widget/component/appbar.dart';
import 'package:plan_ease/widget/component/bottombar.dart';
import 'package:plan_ease/service/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _pageController;
  int _currentPage = 1;

  final List<Widget> _slides =
      List.generate(3, (i) => i + 1).map((i) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              'Slide $i',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList();

  // Variabel untuk menyimpan role pengguna
  String _userRole = '';
  // Instance dari ApiService
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1);
    // Panggil fungsi untuk memuat role pengguna saat initState
    _loadUserRole();
  }

  // Fungsi untuk memuat role pengguna dari SharedPreferences
  Future<void> _loadUserRole() async {
    String? role = await _apiService.getUserRole();
    setState(() {
      _userRole = role ?? ''; // Set role, default ke string kosong jika null
    });
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
      appBar: const CustomAppBar(),
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
            const SectionCard(
              title: 'Polling berjalan',
              items: [
                'Lorem ipsum dorriolar',
                'Lorem ipsum dolor',
                'Kegiatan terbaru',
              ],
            ),
            const SizedBox(height: 12),
            const SectionCard(
              title: 'Kegiatan terbaru',
              items: [],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomBar(currentIndex: 0),
    );
  }
}