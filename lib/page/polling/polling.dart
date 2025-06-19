import 'package:flutter/material.dart';
import 'package:plan_ease/page/history/history.dart';
import 'package:plan_ease/page/polling/form_polling.dart';
import 'package:plan_ease/widget/polling/polling.dart'; // Ini sudah mencakup PollingItem, PollingOptionBar, dan PollingOption
import 'package:plan_ease/service/api_service.dart'; // Import ApiService Anda

class PollingScreen extends StatefulWidget {
  const PollingScreen({super.key});

  @override
  State<PollingScreen> createState() => _PollingScreenState();
}

class _PollingScreenState extends State<PollingScreen> {
  int? expandedIndex;

  // Cukup tentukan berapa banyak PollingItem yang ingin ditampilkan.
  // Setiap PollingItem akan menampilkan data statisnya masing-masing.
  final int _numberOfStaticPolls = 3; // Contoh: akan menampilkan 3 polling yang sama persis

  // NEW: State untuk manajemen role dan loading
  bool _isLoadingRole = true;
  bool isAdmin = false;
  final ApiService _apiService = ApiService(); // Instance ApiService Anda

  @override
  void initState() {
    super.initState();
    _checkUserRole(); // Panggil fungsi untuk cek role saat inisialisasi
  }

  // NEW: Fungsi untuk mengecek peran pengguna
  Future<void> _checkUserRole() async {
    setState(() {
      _isLoadingRole = true; // Mulai loading
    });
    try {
      String? role = await _apiService.getUserRole();
      setState(() {
        isAdmin = (role == 'ADMIN');
        print('PollingScreen: User role is $role, isAdmin is $isAdmin'); // Untuk debugging
      });
    } catch (e) {
      print('Error checking user role in PollingScreen: $e');
      // Anda bisa menampilkan pesan error ke pengguna jika diperlukan
    } finally {
      setState(() {
        _isLoadingRole = false; // Hentikan loading terlepas dari sukses/gagal
      });
    }
  }

  // NEW: Fungsi untuk navigasi ke CreatePollingScreen
  void _navigateToCreatePollingScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePollingScreen()),
    );
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
      body: _isLoadingRole // Tampilkan indikator loading saat mengecek role
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E8C7A)))
          : Column(
              children: [
                // Filter bar
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RiwayatPollingScreen(),
                            ),
                          );
                        },
                        child: Row(
                          children: const [
                            Icon(Icons.history, color: Color(0xFF1E8C7A)),
                            SizedBox(width: 8),
                            Text(
                              "Riwayat",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F6EC),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: const [
                            Text("Pilih kategori polling"),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),

                // List polling
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _numberOfStaticPolls,
                    itemBuilder: (context, index) {
                      return PollingItem(
                        isExpanded: expandedIndex == index,
                        onToggle: () {
                          setState(() {
                            expandedIndex = expandedIndex == index ? null : index;
                          });
                        },
                      );
                    },
                  ),
                ),

                // Footer pagination
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          // Logic for previous page
                        },
                        icon: const Icon(Icons.arrow_left),
                      ),
                      Text('1/$_numberOfStaticPolls'),
                      IconButton(
                        onPressed: () {
                          // Logic for next page
                        },
                        icon: const Icon(Icons.arrow_right),
                      ),
                    ],
                  ),
                )
              ],
            ),
      // NEW: Floating Action Button (hanya terlihat jika isAdmin adalah true)
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: _navigateToCreatePollingScreen,
              backgroundColor: const Color(0xFF1E8C7A),
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            )
          : null, // Jika bukan admin, FAB adalah null (tidak ditampilkan)
    );
  }
}