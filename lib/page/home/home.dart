import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:plan_ease/page/notification/notification.dart';
import 'package:plan_ease/page/polling/polling.dart';
import 'package:plan_ease/page/profile/profile.dart';
import 'package:plan_ease/page/schedule/schedule.dart';
import 'package:plan_ease/widget/home/home.dart';
import 'package:plan_ease/widget/component/appbar.dart';
import 'package:plan_ease/widget/component/bottombar.dart';

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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }).toList();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1);
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
            // Menu utama
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
                    onTap: () {},
                  ),
                  MenuIcon(
                    icon: FontAwesomeIcons.pollH,
                    label: 'Polling',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PollingScreen(),
                        ),
                      );
                    },
                  ),
                  MenuIcon(
                    icon: FontAwesomeIcons.calendarDays,
                    label: 'Jadwal',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const JadwalScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Carousel
            _buildLoopingCarousel(),
            const SizedBox(height: 20),

            // Section: Polling berjalan
            const SectionCard(
              title: 'Polling berjalan',
              items: [
                'Lorem ipsum dorriolar',
                'Lorem ipsum dolor',
                'Kegiatan terbaru',
              ],
            ),
            const SizedBox(height: 12),

            // Section: Kegiatan terbaru
            const SectionCard(title: 'Kegiatan terbaru', items: []),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomBar(currentIndex: 0),
    );
  }
}
