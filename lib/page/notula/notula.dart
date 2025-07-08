import 'package:flutter/material.dart';
import 'package:plan_ease/model/notula.dart';
import 'package:plan_ease/widget/notula/notula.dart';
import 'package:plan_ease/page/notula/form_notula.dart';
import 'package:plan_ease/service/auth_service.dart';
import 'package:plan_ease/service/notula_service.dart';
import 'package:plan_ease/page/notula/detail_notula.dart';

class NotulaScreen extends StatefulWidget {
  const NotulaScreen({super.key});

  @override
  State<NotulaScreen> createState() => _NotulaScreenState();
}

class _NotulaScreenState extends State<NotulaScreen> {
  List<Notula> _daftarNotula = [];
  List<Notula> _filteredNotula = []; // New list for filtered results
  bool _isLoading = true;
  String? _errorMessage;

  bool isAdmin = false;
  late final AuthService _authService;
  late final NotulaService _notulaService;

  // New: TextEditingController for the search input
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = ''; // New: State variable to hold the search query

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _notulaService = NotulaService(_authService);
    _checkUserRoleAndFetchNotula();

    // New: Add listener to search controller to filter notes
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // New: Method to handle changes in the search input
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filterNotula();
    });
  }

  // New: Method to filter the notula list based on search query
  void _filterNotula() {
    if (_searchQuery.isEmpty) {
      _filteredNotula = List.from(_daftarNotula);
    } else {
      _filteredNotula = _daftarNotula.where((notula) {
        final query = _searchQuery.toLowerCase();
        // You can customize which fields to search here
        return notula.title.toLowerCase().contains(query) ||
            notula.content.toLowerCase().contains(query);
      }).toList();
    }
  }

  Future<void> _checkUserRoleAndFetchNotula() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String? role = await _authService.getUserRole();
      setState(() {
        isAdmin = (role == 'ADMIN');
      });
      print('NotulaScreen: User role is $role, isAdmin is $isAdmin');

      List<Notula> fetchedNotula = await _notulaService.getNotula();
      setState(() {
        _daftarNotula = fetchedNotula;
        _filterNotula(); // Filter after fetching data
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
    _checkUserRoleAndFetchNotula(); // Panggil ulang untuk refresh daftar
  }

  Future<void> _editNotula(Notula updatedNotula) async {
    try {
      await _notulaService.updateNotula(updatedNotula);
      setState(() {
        final index = _daftarNotula.indexWhere((n) => n.id == updatedNotula.id);
        if (index != -1) {
          _daftarNotula[index] = updatedNotula;
          _filterNotula(); // Re-filter after update
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

  Future<void> _deleteNotula(String? notulaId) async {
    if (notulaId == null || notulaId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID Notula tidak valid untuk penghapusan.')),
      );
      return;
    }

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
        await _notulaService.deleteNotula(notulaId);

        setState(() {
          _daftarNotula.removeWhere((notula) => notula.id == notulaId);
          _filterNotula(); // Re-filter after deletion
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
        title: TextField( // New: Search bar in AppBar
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Cari notula...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: Colors.white),
          ),
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
        ),
        centerTitle: false, // Changed to false to accommodate TextField
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
              : _filteredNotula.isEmpty
                  ? Center( // Display message if no notes or no search results
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _searchQuery.isEmpty ? 'Belum ada notula.' : 'Tidak ada notula yang ditemukan.',
                            style: const TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          const SizedBox(height: 10),
                          if (_searchQuery.isEmpty)
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
                      itemCount: _filteredNotula.length, // Use _filteredNotula here
                      itemBuilder: (context, index) {
                        final notula = _filteredNotula[index]; // Use _filteredNotula here
                        return NotulaListItem(
                          notula: notula,
                          isAdmin: isAdmin,
                          onEdit: isAdmin ? () {
                            if (notula.id == null || notula.id!.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('ID Notula tidak valid untuk edit.')),
                              );
                              return;
                            }
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
                          onDelete: isAdmin ? () => _deleteNotula(notula.id) : null,
                          onTap: () => _navigateToDetailNotulaScreen(notula),
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