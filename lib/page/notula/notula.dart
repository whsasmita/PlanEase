// lib/page/notula/notula.dart
import 'package:flutter/material.dart';
import 'package:plan_ease/model/model.dart'; // Import kelas Notula
import 'package:plan_ease/widget/notula/notula.dart'; // Import NotulaListItem
import 'package:plan_ease/page/notula/form_notula.dart'; // Pastikan ini path yang benar untuk TambahNotulaScreen
import 'package:plan_ease/service/api_service.dart'; // Import ApiService

class NotulaScreen extends StatefulWidget {
  const NotulaScreen({super.key});

  @override
  State<NotulaScreen> createState() => _NotulaScreenState();
}

class _NotulaScreenState extends State<NotulaScreen> {
  // Ganti _daftarNotula dengan daftar yang akan diisi dari API
  List<Notula> _daftarNotula = [];
  bool _isLoading = true; // Tambahkan status loading
  String? _errorMessage; // Tambahkan untuk menampilkan pesan error

  bool isAdmin = false; // Akan di-update dari ApiService
  final ApiService _apiService = ApiService(); // Instance ApiService

  @override
  void initState() {
    super.initState();
    _checkUserRoleAndFetchNotula(); // Panggil fungsi gabungan ini
  }

  // Fungsi untuk memeriksa role pengguna DAN mengambil notula
  Future<void> _checkUserRoleAndFetchNotula() async {
    setState(() {
      _isLoading = true; // Mulai loading
      _errorMessage = null; // Reset pesan error
    });

    try {
      // 1. Periksa Role Pengguna
      String? role = await _apiService.getUserRole();
      setState(() {
        isAdmin = (role == 'ADMIN');
      });
      print('NotulaScreen: User role is $role, isAdmin is $isAdmin');

      // 2. Ambil Data Notula
      List<Notula> fetchedNotula = await _apiService.getNotula();
      setState(() {
        _daftarNotula = fetchedNotula;
      });
    } catch (e) {
      print('Error fetching data in NotulaScreen: $e');
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', ''); // Hapus "Exception: "
      });
    } finally {
      setState(() {
        _isLoading = false; // Selesai loading
      });
    }
  }

  void _tambahNotulaBaru(Notula newNotula) {
    setState(() {
      _daftarNotula.add(newNotula);
    });
    _checkUserRoleAndFetchNotula();
  }

  void _navigateToTambahNotulaScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TambahNotulaScreen(
          onAddNotula: _tambahNotulaBaru,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9E5D6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E8C7A),
        title: const Text('Notula'),
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: _isLoading // Tampilkan loading indicator
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E8C7A)))
          : _errorMessage != null // Tampilkan pesan error jika ada
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 50),
                        const SizedBox(height: 10),
                        Text(
                          'Terjadi kesalahan: $_errorMessage',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _checkUserRoleAndFetchNotula, // Coba lagi
                          child: const Text('Coba Lagi'),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E8C7A), foregroundColor: Colors.white),
                        ),
                      ],
                    ),
                  ),
                )
              : _daftarNotula.isEmpty // Tampilkan pesan jika daftar kosong setelah loading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Belum ada notula.',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Anda bisa menambahkan notula baru.',
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: _daftarNotula.length,
                      itemBuilder: (context, index) {
                        final notula = _daftarNotula[index];
                        return NotulaListItem(notula: notula);
                      },
                    ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: _navigateToTambahNotulaScreen,
              backgroundColor: const Color(0xFF1E8C7A),
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}