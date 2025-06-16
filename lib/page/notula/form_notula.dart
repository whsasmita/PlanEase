import 'package:flutter/material.dart';
import 'package:plan_ease/model/model.dart'; // Import model Notula
import 'package:plan_ease/service/api_service.dart'; // Import ApiService

class TambahNotulaScreen extends StatefulWidget {
  final Function(Notula) onAddNotula;

  const TambahNotulaScreen({Key? key, required this.onAddNotula}) : super(key: key);

  @override
  State<TambahNotulaScreen> createState() => _TambahNotulaScreenState();
}

class _TambahNotulaScreenState extends State<TambahNotulaScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  final ApiService _apiService = ApiService(); // Instance ApiService
  bool _isLoading = false; // State untuk indikator loading

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {Color backgroundColor = Colors.green}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _submitNotula() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Mulai loading
      });

      try {
        // Panggil API untuk menambahkan notula
        final Notula addedNotula = await _apiService.addNotula(
          title: _titleController.text,
          description: _descriptionController.text,
          content: _contentController.text,
        );

        _showSnackBar('Notula berhasil ditambahkan!');
        widget.onAddNotula(addedNotula); // Panggil callback dengan notula yang sudah ada ID-nya
        Navigator.pop(context); // Kembali ke halaman sebelumnya
      } catch (e) {
        _showSnackBar('Gagal menambahkan notula: ${e.toString().replaceFirst('Exception: ', '')}', backgroundColor: Colors.red);
      } finally {
        setState(() {
          _isLoading = false; // Selesai loading
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9E5D6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E8C7A),
        title: const Text('Tambah Notula Baru'),
        centerTitle: true,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul Notula',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Singkat',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'Isi Notula',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Isi notula tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _isLoading // Tampilkan CircularProgressIndicator jika sedang loading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E8C7A)))
                  : ElevatedButton(
                      onPressed: _submitNotula,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E8C7A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Simpan Notula',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}