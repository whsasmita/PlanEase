// lib/page/notula/form_notula.dart
import 'package:flutter/material.dart';
import 'package:plan_ease/model/model.dart';
import 'package:plan_ease/service/api_service.dart';

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
  final TextEditingController _titleController = TextEditingController();       // Renamed
  final TextEditingController _descriptionController = TextEditingController(); // Renamed
  final TextEditingController _contentController = TextEditingController();     // New
  bool _isLoading = false;
  String? _errorMessage;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
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
          await _apiService.addNotula(newNotula);
          widget.onAddNotula(newNotula);
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
          await _apiService.updateNotula(updatedNotula);
          widget.onAddNotula(updatedNotula);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notula berhasil diperbarui!')),
          );
        }
        Navigator.pop(context);
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
                controller: _titleController, // Changed controller
                decoration: InputDecoration(
                  labelText: 'Judul', // Changed label
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
                controller: _descriptionController, // Changed controller
                maxLines: 3, // Adjust max lines for description
                decoration: InputDecoration(
                  labelText: 'Deskripsi Singkat', // Changed label
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
                controller: _contentController, // New controller
                maxLines: 8, // Adjust max lines for content
                decoration: InputDecoration(
                  labelText: 'Isi Lengkap Notula', // New label
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