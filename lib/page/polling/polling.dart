import 'package:flutter/material.dart';
import 'package:plan_ease/page/history/history.dart';
import 'package:plan_ease/page/polling/form_polling.dart';
import 'package:plan_ease/widget/polling/polling.dart';
import 'package:plan_ease/service/auth_service.dart';
import 'package:plan_ease/service/polling_service.dart';
import 'package:plan_ease/model/polling.dart' as PollingModel; 

class PollingScreen extends StatefulWidget {
  const PollingScreen({super.key});

  @override
  State<PollingScreen> createState() => _PollingScreenState();
}

class _PollingScreenState extends State<PollingScreen> {
  int? expandedIndex;

  // State untuk data polling
  List<PollingModel.Polling> _pollings = [];
  bool _isLoadingPolls = true;
  int _currentPage = 1; // Untuk pagination
  int _totalPages = 1; // Untuk pagination

  // State untuk manajemen role dan loading
  bool _isLoadingRole = true;
  bool isAdmin = false;

  late final AuthService _authService;
  late final PollingService _pollingService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _pollingService = PollingService(_authService);
    _initializeScreen(); // Panggil fungsi inisialisasi utama
  }

  // Fungsi inisialisasi utama
  Future<void> _initializeScreen() async {
    await _checkUserRole(); // Cek role dulu
    if (mounted) {
      await _fetchPollings(); // Lalu ambil data polling
    }
  }

  // Fungsi untuk mengecek peran pengguna
  Future<void> _checkUserRole() async {
    setState(() {
      _isLoadingRole = true;
    });
    try {
      String? role = await _authService.getUserRole();
      setState(() {
        isAdmin = (role == 'ADMIN');
        print('PollingScreen: User role is $role, isAdmin is $isAdmin');
      });
    } catch (e) {
      print('Error checking user role in PollingScreen: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat peran pengguna: ${e.toString().replaceFirst('Exception: ', '')}')),
        );
      }
    } finally {
      setState(() {
        _isLoadingRole = false;
      });
    }
  }

  // Fungsi untuk mengambil daftar polling dari API
  Future<void> _fetchPollings({int page = 1}) async {
    setState(() {
      _isLoadingPolls = true;
    });
    try {
      // API Laravel Anda menggunakan paginate, jadi kita perlu menangani respons paginate
      // Metode getPollings di PollingService harus disesuaikan untuk menerima parameter halaman
      // dan mengembalikan data pagination (jika ada).
      // Untuk saat ini, kita asumsikan getPollings mengembalikan List<PollingModel.Polling>
      // dan kita akan mengimplementasikan pagination sederhana di sisi klien jika API tidak mengembalikan metadata halaman.
      // Jika API Anda mengembalikan metadata pagination (current_page, last_page, total, dll.),
      // Anda harus menyesuaikan PollingService.getPollings untuk mengembalikan Map<String, dynamic>
      // yang berisi data dan metadata, lalu mengupdate _currentPage dan _totalPages di sini.

      // Contoh sederhana tanpa metadata pagination dari API:
      // Anda perlu memodifikasi PollingService.getPollings untuk menerima parameter 'page'
      // dan 'per_page' jika ingin menggunakan pagination server-side.
      final fetchedPollings = await _pollingService.getPollings(); // Asumsi ini mengambil semua atau halaman pertama
      setState(() {
        _pollings = fetchedPollings;
        _currentPage = page; // Asumsi halaman saat ini
        // _totalPages = (total_items / items_per_page).ceil(); // Hitung total halaman jika ada metadata
      });
    } catch (e) {
      print('Error fetching pollings: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat polling: ${e.toString().replaceFirst('Exception: ', '')}')),
        );
      }
    } finally {
      setState(() {
        _isLoadingPolls = false;
      });
    }
  }

  // Fungsi untuk memuat ulang polling (misalnya setelah membuat/mengupdate/menghapus/vote)
  Future<void> _refreshPollings() async {
    setState(() {
      expandedIndex = null; // Tutup semua item yang diperluas saat refresh
    });
    await _fetchPollings(page: _currentPage);
  }

  // Fungsi untuk navigasi ke CreatePollingScreen
  void _navigateToCreatePollingScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePollingScreen()),
    ).then((value) {
      // Refresh polling setelah kembali dari CreatePollingScreen (jika ada perubahan)
      if (value == true) {
        _refreshPollings();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9E5D6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E8C7A),
        title: const Text('Polling'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoadingRole || _isLoadingPolls // Tampilkan indikator loading saat mengecek role atau memuat polling
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E8C7A)))
          : Column(
              children: [
                // Filter bar
                // Padding(
                //   padding: const EdgeInsets.all(12.0),
                //   child: Row(
                //     children: [
                //       GestureDetector(
                //         onTap: () {
                //           Navigator.push(
                //             context,
                //             MaterialPageRoute(
                //               builder: (context) => const RiwayatPollingScreen(),
                //             ),
                //           );
                //         },
                //         child: Row(
                //           children: const [
                //             Icon(Icons.history, color: Color(0xFF1E8C7A)),
                //             SizedBox(width: 8),
                //             Text(
                //               "Riwayat",
                //               style: TextStyle(
                //                 fontWeight: FontWeight.bold,
                //                 decoration: TextDecoration.underline,
                //               ),
                //             ),
                //           ],
                //         ),
                //       ),
                //       const Spacer(),
                //       Container(
                //         padding: const EdgeInsets.symmetric(
                //             horizontal: 12, vertical: 6),
                //         decoration: BoxDecoration(
                //           color: const Color(0xFFF0F6EC),
                //           borderRadius: BorderRadius.circular(20),
                //         ),
                //         child: Row(
                //           children: const [
                //             Text("Pilih kategori polling"),
                //             SizedBox(width: 8),
                //             Icon(Icons.arrow_drop_down),
                //           ],
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                const Divider(),

                // List polling
                Expanded(
                  child: _pollings.isEmpty
                      ? const Center(child: Text('Tidak ada polling tersedia.'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _pollings.length, // Menggunakan jumlah polling yang sebenarnya
                          itemBuilder: (context, index) {
                            final polling = _pollings[index];
                            return PollingItem(
                              polling: polling, // Teruskan objek polling yang sebenarnya
                              isExpanded: expandedIndex == index,
                              onToggle: () {
                                setState(() {
                                  expandedIndex = expandedIndex == index ? null : index;
                                });
                              },
                              onPollingUpdated: _refreshPollings, // Callback untuk refresh setelah vote/update
                            );
                          },
                        ),
                ),

                // Footer pagination (sesuaikan dengan logika pagination API Anda)
                // Untuk saat ini, ini masih menggunakan logika statis karena API paginate belum sepenuhnya diintegrasikan
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _currentPage > 1
                            ? () {
                                setState(() {
                                  _currentPage--;
                                  _fetchPollings(page: _currentPage);
                                });
                              }
                            : null, // Nonaktifkan jika di halaman pertama
                        icon: const Icon(Icons.arrow_left),
                      ),
                      Text('$_currentPage/$_totalPages'), // Tampilkan halaman saat ini / total halaman
                      IconButton(
                        onPressed: _currentPage < _totalPages
                            ? () {
                                setState(() {
                                  _currentPage++;
                                  _fetchPollings(page: _currentPage);
                                });
                              }
                            : null, // Nonaktifkan jika di halaman terakhir
                        icon: const Icon(Icons.arrow_right),
                      ),
                    ],
                  ),
                )
              ],
            ),
      // Floating Action Button (hanya terlihat jika isAdmin adalah true)
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: _navigateToCreatePollingScreen,
              backgroundColor: const Color(0xFF1E8C7A),
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}