// lib/page/notula/notula.dart
import 'package:flutter/material.dart';
import 'package:plan_ease/model/model.dart';
import 'package:plan_ease/widget/notula/notula.dart';
import 'package:plan_ease/page/notula/form_notula.dart';
import 'package:plan_ease/service/api_service.dart';
import 'package:plan_ease/page/notula/detail_notula.dart'; // NEW: Import DetailNotulaScreen

class NotulaScreen extends StatefulWidget {
  const NotulaScreen({super.key});

  @override
  State<NotulaScreen> createState() => _NotulaScreenState();
}

class _NotulaScreenState extends State<NotulaScreen> {
  List<Notula> _daftarNotula = [];
  bool _isLoading = true;
  String? _errorMessage;

  bool isAdmin = false;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _checkUserRoleAndFetchNotula();
  }

  Future<void> _checkUserRoleAndFetchNotula() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String? role = await _apiService.getUserRole();
      setState(() {
        isAdmin = (role == 'ADMIN');
      });
      print('NotulaScreen: User role is $role, isAdmin is $isAdmin');

      List<Notula> fetchedNotula = await _apiService.getNotula();
      setState(() {
        _daftarNotula = fetchedNotula;
      });
    } catch (e) {
      print('Error fetching data in NotulaScreen: $e');
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _tambahNotulaBaru(Notula newNotula) {
    _checkUserRoleAndFetchNotula();
  }

  Future<void> _editNotula(Notula updatedNotula) async {
    try {
      await _apiService.updateNotula(updatedNotula);
      setState(() {
        final index = _daftarNotula.indexWhere((n) => n.id == updatedNotula.id);
        if (index != -1) {
          _daftarNotula[index] = updatedNotula;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notula berhasil diperbarui!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui notula: ${e.toString().replaceFirst('Exception: ', '')}')),
      );
    }
  }

  Future<void> _deleteNotula(String notulaId) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus notula ini?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
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
        await _apiService.deleteNotula(notulaId);

        setState(() {
          _daftarNotula.removeWhere((notula) => notula.id == notulaId);
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notula berhasil dihapus!')),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus notula: ${e.toString().replaceFirst('Exception: ', '')}')),
        );
      }
    }
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

  void _navigateToDetailNotulaScreen(Notula notula) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HalamanDetailNotula(notula: notula),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E8C7A)))
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 50),
                        const SizedBox(height: 10),
                        Text(
                          'Terjadi kesalahan: $_errorMessage',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _checkUserRoleAndFetchNotula,
                          child: const Text('Coba Lagi'),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E8C7A), foregroundColor: Colors.white),
                        ),
                      ],
                    ),
                  ),
                )
              : _daftarNotula.isEmpty
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
                        return NotulaListItem(
                          notula: notula,
                          isAdmin: isAdmin,
                          onEdit: isAdmin ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TambahNotulaScreen(
                                  notulaToEdit: notula,
                                  onAddNotula: (updatedNotula) {
                                    _editNotula(updatedNotula);
                                  },
                                ),
                              ),
                            );
                          } : null,
                          onDelete: isAdmin ? () => _deleteNotula(notula.id.toString()) : null,
                          onTap: () => _navigateToDetailNotulaScreen(notula), // NEW: Pass the onTap callback
                        );
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