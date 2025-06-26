// lib/page/notula/form_notula.dart
import 'package:flutter/material.dart';
import 'package:plan_ease/model/notula.dart';
// PERBAIKAN: Ganti import ApiService lama dengan NotulaService dan AuthService
import 'package:plan_ease/service/notula_service.dart';
import 'package:plan_ease/service/auth_service.dart'; // Import AuthService karena dibutuhkan oleh NotulaService

class TambahNotulaScreen extends StatefulWidget {
  final Function(Notula) onAddNotula;
  final Notula? notulaToEdit;

  const TambahNotulaScreen({
    super.key,
    required this.onAddNotula,
    this.notulaToEdit,
  });

  @override
  State<TambahNotulaScreen> createState() => _TambahNotulaScreenState();
}

class _TambahNotulaScreenState extends State<TambahNotulaScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  // PERBAIKAN: Ganti ApiService dengan NotulaService
  // Inisialisasi AuthService sebagai dependency untuk NotulaService
  late final AuthService _authService;
  late final NotulaService _notulaService;

  @override
  void initState() {
    super.initState();
    // Inisialisasi service di initState
    _authService = AuthService(); // AuthService tidak punya dependency
    _notulaService = NotulaService(_authService); // NotulaService butuh AuthService

    if (widget.notulaToEdit != null) {
      _titleController.text = widget.notulaToEdit!.title;
      _descriptionController.text = widget.notulaToEdit!.description;
      _contentController.text = widget.notulaToEdit!.content;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final String title = _titleController.text;
        final String description = _descriptionController.text;
        final String content = _contentController.text;

        if (widget.notulaToEdit == null) {
          final Notula newNotula = Notula(
            id: null,
            title: title,
            description: description,
            content: content,
          );
          // PERBAIKAN: Panggil method dari _notulaService
          await _notulaService.addNotula(newNotula);
          widget.onAddNotula(newNotula); // Callback ke NotulaScreen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notula berhasil ditambahkan!')),
          );
        } else {
          final Notula updatedNotula = Notula(
            id: widget.notulaToEdit!.id,
            title: title,
            description: description,
            content: content,
          );
          // PERBAIKAN: Panggil method dari _notulaService
          await _notulaService.updateNotula(updatedNotula);
          widget.onAddNotula(updatedNotula); // Callback ke NotulaScreen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notula berhasil diperbarui!')),
          );
        }
        Navigator.pop(context); // Kembali ke halaman NotulaScreen
      } catch (e) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.notulaToEdit != null;
    return Scaffold(
      backgroundColor: const Color(0xFFD9E5D6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E8C7A),
        title: Text(isEditing ? 'Edit Notula' : 'Tambah Notula Baru'),
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Judul',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
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
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Deskripsi Singkat',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
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
                decoration: InputDecoration(
                  labelText: 'Isi Lengkap Notula',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
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
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    'Error: $_errorMessage',
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E8C7A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isEditing ? 'Simpan Perubahan' : 'Tambahkan Notula',
                          style: const TextStyle(fontSize: 18),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}