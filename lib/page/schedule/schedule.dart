import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:plan_ease/service/api_service.dart'; // Make sure this path is correct
import 'package:plan_ease/page/schedule/form_schedule.dart'; // Make sure this path is correct

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key});

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // This map stores your activities.
  final Map<DateTime, List<String>> _activities = {
    DateTime.utc(2025, 6, 19): ['Meeting Proyek A', 'Presentasi Klien'],
    DateTime.utc(2025, 6, 20): ['Rapat Tim', 'Diskusi Desain UI/UX'],
    DateTime.utc(2025, 6, 22): ['Kuliah Pemrograman Mobile', 'Tugas Akhir'],
    DateTime.utc(2025, 6, 25): ['Acara Kampus', 'Rapat Himpunan'],
    DateTime.utc(2025, 7, 1): ['Liburan Bersama'],
  };

  bool _isLoadingRole = true; // New state to track role loading
  bool isAdmin = false; // New state for admin role
  final ApiService _apiService = ApiService(); // Instantiate ApiService

  @override
  void initState() {
    super.initState();
    _checkUserRole(); // Call the function to check user role
  }

  // Function to check the user's role
  Future<void> _checkUserRole() async {
    setState(() {
      _isLoadingRole = true; // Start loading
    });
    try {
      String? role = await _apiService.getUserRole();
      setState(() {
        isAdmin = (role == 'ADMIN');
        print('JadwalScreen: User role is $role, isAdmin is $isAdmin'); // For debugging
      });
    } catch (e) {
      print('Error checking user role in JadwalScreen: $e');
      // Optionally show an error message to the user
    } finally {
      setState(() {
        _isLoadingRole = false; // Stop loading regardless of success/failure
      });
    }
  }

  // Function to navigate to the Add Activity screen
  void _navigateToTambahKegiatanScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TambahKegiatanScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9E5D6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E8C7A),
        title: const Text('Jadwal Kegiatan'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoadingRole // Show loading indicator while checking role
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E8C7A)))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Calendar Widget
                  TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    calendarStyle: CalendarStyle(
                      todayDecoration: const BoxDecoration(
                        color: Color(0xFF1E8C7A),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: Colors.black87,
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                    ),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                      _showActivitiesForDay(selectedDay);
                    },
                    calendarFormat: CalendarFormat.month,
                    eventLoader: (day) {
                      return _getEventsForDay(day);
                    },
                  ),
                  const SizedBox(height: 24),
                  // Section for Ongoing Activities
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F6EC),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kegiatan Berlangsung',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ..._getOngoingActivities(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      // **Floating Action Button (only visible if isAdmin is true)**
      floatingActionButton: isAdmin // Only show FAB if user is admin
          ? FloatingActionButton(
              onPressed: _navigateToTambahKegiatanScreen,
              backgroundColor: const Color(0xFF1E8C7A),
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            )
          : null, // If not admin, the FAB is null (not shown)
    );
  }

  // --- Helper Functions (unchanged) ---
  List<String> _getEventsForDay(DateTime day) {
    DateTime normalizedDay = DateTime.utc(day.year, day.month, day.day);
    return _activities[normalizedDay] ?? [];
  }

  void _showActivitiesForDay(DateTime day) {
    final events = _getEventsForDay(day);
    if (events.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Kegiatan pada ${day.day}/${day.month}/${day.year}'),
            content: SingleChildScrollView(
              child: ListBody(
                children: events.map((event) => Text('- $event')).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  List<Widget> _getOngoingActivities() {
    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);
    final todayActivities = _activities[today] ?? [];

    if (todayActivities.isEmpty) {
      return [const Text('Tidak ada kegiatan berlangsung hari ini.')];
    }

    return todayActivities.map((activity) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Text('- $activity'),
      );
    }).toList();
  }
}