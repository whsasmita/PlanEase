import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
// PERBAIKAN: Ganti import ApiService lama dengan service yang baru
import 'package:plan_ease/service/auth_service.dart';
import 'package:plan_ease/service/schedule_service.dart';
import 'package:plan_ease/page/schedule/form_schedule.dart';
import 'package:plan_ease/model/schedule.dart';
import 'package:plan_ease/widget/schedule/calendar_widget.dart';
import 'package:plan_ease/widget/schedule/schedule_list_section.dart';
import 'package:plan_ease/widget/schedule/schedule_card.dart';
import 'package:plan_ease/page/schedule/detail_schedule.dart';

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key});

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<Schedule> _schedules = [];
  bool _isLoading = true;
  bool isAdmin = false;

  // PERBAIKAN: Ganti ApiService dengan instance service yang spesifik
  late final AuthService _authService;
  late final ScheduleService _scheduleService;

  @override
  void initState() {
    super.initState();
    // INI PENTING: Inisialisasi service di sini
    _authService = AuthService();
    _scheduleService = ScheduleService(_authService);
    _selectedDay = _focusedDay;
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      await Future.wait([_checkUserRole(), _loadSchedules()]);
    } catch (e) {
      print('Error loading initial data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memuat data. Silakan coba refresh.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkUserRole() async {
    try {
      // PERBAIKAN: Panggil method dari AuthService
      String? role = await _authService.getUserRole();
      if (mounted) {
        setState(() {
          isAdmin = (role == 'ADMIN');
          print('JadwalScreen: User role is $role, isAdmin is $isAdmin');
        });
      }
    } catch (e) {
      print('Error checking user role in JadwalScreen: $e');
    }
  }

  Future<void> _loadSchedules() async {
    try {
      // PERBAIKAN: Panggil method dari ScheduleService
      List<Schedule> schedules = await _scheduleService.getSchedules();
      if (mounted) {
        setState(() {
          _schedules = schedules;
        });
      }
    } catch (e) {
      print('Error loading schedules: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat jadwal kegiatan.')),
        );
      }
    }
  }

  Future<void> _addSchedule(Schedule newSchedule) async {
    // Metode ini dipanggil saat form TambahKegiatanScreen disubmit
    await _loadSchedules(); // Muat ulang data setelah menambahkan
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jadwal berhasil ditambahkan!')),
      );
    }
  }

  Future<void> _editSchedule(Schedule updatedSchedule) async {
    if (updatedSchedule.id == null || updatedSchedule.id! <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ID jadwal tidak valid untuk pembaruan.')),
        );
      }
      return;
    }
    try {
      // PERBAIKAN: Panggil method dari ScheduleService
      await _scheduleService.updateSchedule(updatedSchedule);
      await _loadSchedules(); // Reload data after update
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jadwal berhasil diperbarui!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal memperbarui jadwal: ${e.toString().replaceFirst('Exception: ', '')}',
            ),
          ),
        );
      }
    }
  }

  Future<void> _deleteSchedule(int? scheduleId) async {
    if (scheduleId == null || scheduleId <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ID jadwal tidak valid untuk penghapusan.')),
        );
      }
      return;
    }

    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus jadwal ini?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      setState(() {
        _isLoading = true;
      });
      try {
        // PERBAIKAN: Panggil method dari ScheduleService
        await _scheduleService.deleteSchedule(scheduleId);
        await _loadSchedules();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Jadwal berhasil dihapus!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Gagal menghapus jadwal: ${e.toString().replaceFirst('Exception: ', '')}',
              ),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _navigateToTambahKegiatanScreen({
    Schedule? scheduleToEdit,
  }) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TambahKegiatanScreen(scheduleToEdit: scheduleToEdit),
      ),
    );
    if (result == true) {
      await _loadSchedules();
    }
  }

  List<Schedule> _getSchedulesForDay(DateTime day) {
    DateTime normalizedDay = DateTime.utc(day.year, day.month, day.day);
    return _schedules.where((schedule) {
      DateTime startDate = DateTime.utc(
        schedule.startDate.year,
        schedule.startDate.month,
        schedule.startDate.day,
      );
      DateTime endDate = DateTime.utc(
        schedule.endDate.year,
        schedule.endDate.month,
        schedule.endDate.day,
      );
      return normalizedDay.isAtSameMomentAs(startDate) ||
          normalizedDay.isAtSameMomentAs(endDate) ||
          (normalizedDay.isAfter(startDate) && normalizedDay.isBefore(endDate));
    }).toList();
  }

  List<Schedule> _getOngoingSchedules() {
    return _schedules.where((schedule) => schedule.isActive()).toList();
  }

  List<Schedule> _getUpcomingSchedules() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final nextWeek = today.add(const Duration(days: 7));
    return _schedules
        .where((schedule) {
          return schedule.isUpcoming() &&
              (schedule.startDate.isAfter(today) &&
                  schedule.startDate.isBefore(nextWeek));
        })
        .toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
  }

  List<Widget> _buildScheduleList(
    List<Schedule> schedules, {
    required bool isOngoingList,
  }) {
    if (schedules.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            isOngoingList
                ? 'Tidak ada kegiatan berlangsung hari ini.'
                : 'Tidak ada kegiatan mendatang dalam 7 hari ke depan.',
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ];
    }
    return schedules
        .map(
          (schedule) {
            print('Building ScheduleCard for: ${schedule.title} with ID: ${schedule.id}');
            
            return ScheduleCard(
              schedule: schedule,
              isOngoing: isOngoingList,
              // PERBAIKAN: Lengkapi argumen yang diperlukan untuk DetailScheduleScreen
              onTap: () async { 
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailScheduleScreen(
                      schedule: schedule,
                      isAdmin: isAdmin, // ARGUMEN DITAMBAHKAN
                      onEdit: () {
                        // Tidak perlu pop di sini, karena form akan pop sendiri
                        _navigateToTambahKegiatanScreen(scheduleToEdit: schedule);
                      },
                      onDelete: (id) async { // Callback async
                        await _deleteSchedule(id);
                      },
                    ),
                  ),
                );
                // Setelah kembali dari DetailScheduleScreen, perbarui data.
                if (result == true) {
                  await _loadSchedules();
                }
              },
              isAdmin: isAdmin,
              onEdit: isAdmin
                  ? () {
                      if (schedule.id == null || schedule.id! <= 0) {
                        print('ERROR: Edit button pressed for invalid ID: ${schedule.id}');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Jadwal ini tidak memiliki ID valid dan tidak bisa diedit.')),
                        );
                        return;
                      }
                      _navigateToTambahKegiatanScreen(scheduleToEdit: schedule);
                    }
                  : null,
              onDelete: isAdmin
                  ? () {
                      if (schedule.id == null || schedule.id! <= 0) {
                        print('ERROR: Delete button pressed for invalid ID: ${schedule.id}');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Jadwal ini tidak memiliki ID valid dan tidak bisa dihapus.')),
                        );
                        return;
                      }
                      _deleteSchedule(schedule.id);
                    }
                  : null,
            );
          },
        )
        .toList();
  }

  void _showSchedulesForDay(DateTime day) {
    final schedules = _getSchedulesForDay(day);
    if (schedules.isNotEmpty) {
      showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(
              'Kegiatan pada ${DateFormat('dd MMMMenderal').format(day)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: schedules.length,
                itemBuilder: (context, index) {
                  final schedule = schedules[index];
                  return ScheduleCard(
                    schedule: schedule,
                    isOngoing: schedule.isActive(),
                    onTap: () async { // <-- JADIKAN ONTAP INI ASYNC
                      Navigator.of(dialogContext).pop();
                      // PANGGILAN KEDUA DI SINI
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScheduleScreen(
                            schedule: schedule,
                            isAdmin: isAdmin, // ARGUMEN DITAMBAHKAN
                            onEdit: () {
                              _navigateToTambahKegiatanScreen(scheduleToEdit: schedule);
                            },
                            onDelete: (id) async { // Callback async
                              await _deleteSchedule(id);
                            },
                          ),
                        ),
                      );
                      if (result == true) {
                        await _loadSchedules();
                      }
                    },
                    isAdmin: isAdmin,
                    onEdit: isAdmin
                        ? () {
                            if (schedule.id == null || schedule.id! <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Jadwal ini tidak memiliki ID valid dan tidak bisa diedit.')),
                              );
                              return;
                            }
                            Navigator.of(dialogContext).pop();
                            _navigateToTambahKegiatanScreen(scheduleToEdit: schedule);
                          }
                        : null,
                    onDelete: isAdmin
                        ? () {
                            if (schedule.id == null || schedule.id! <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Jadwal ini tidak memiliki ID valid dan tidak bisa dihapus.')),
                              );
                              return;
                            }
                            Navigator.of(dialogContext).pop();
                            _deleteSchedule(schedule.id);
                          }
                        : null,
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text(
                  'Tutup',
                  style: TextStyle(color: Color(0xFF1E8C7A)),
                ),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tidak ada kegiatan pada ${DateFormat('dd MMMMenderal').format(day)}',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9E5D6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E8C7A),
        title: const Text(
          'Jadwal Kegiatan',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadAllData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1E8C7A)),
            )
          : RefreshIndicator(
              onRefresh: _loadAllData,
              color: const Color(0xFF1E8C7A),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Calendar Widget
                    ScheduleCalendar(
                      focusedDay: _focusedDay,
                      selectedDay: _selectedDay,
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                        _showSchedulesForDay(selectedDay);
                      },
                      eventLoader: _getSchedulesForDay,
                    ),
                    const SizedBox(height: 24),

                    // Ongoing Activities Section
                    ScheduleListSection(
                      title: 'Kegiatan Berlangsung',
                      icon: Icons.play_circle_fill,
                      children: _buildScheduleList(
                        _getOngoingSchedules(),
                        isOngoingList: true,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Upcoming Activities Section
                    ScheduleListSection(
                      title: 'Kegiatan Mendatang',
                      icon: Icons.upcoming,
                      children: _buildScheduleList(
                        _getUpcomingSchedules(),
                        isOngoingList: false,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () => _navigateToTambahKegiatanScreen(),
              backgroundColor: const Color(0xFF1E8C7A),
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}