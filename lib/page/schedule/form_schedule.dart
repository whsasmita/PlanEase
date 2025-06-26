import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// PERBAIKAN: Ganti import ApiService dengan service yang baru
import 'package:plan_ease/service/auth_service.dart'; // Import AuthService
import 'package:plan_ease/service/schedule_service.dart'; // Import ScheduleService
import 'package:plan_ease/model/schedule.dart';
import 'package:plan_ease/widget/schedule/form_schedule/activity_text_field.dart';
import 'package:plan_ease/widget/schedule/form_schedule/date_input_field.dart';
import 'package:plan_ease/widget/schedule/form_schedule/end_date_toggle.dart';
import 'package:plan_ease/widget/schedule/form_schedule/save_button.dart';

class TambahKegiatanScreen extends StatefulWidget {
  final Schedule? scheduleToEdit;

  const TambahKegiatanScreen({
    super.key,
    this.scheduleToEdit,
  });

  @override
  State<TambahKegiatanScreen> createState() => _TambahKegiatanScreenState();
}

class _TambahKegiatanScreenState extends State<TambahKegiatanScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  bool _hasEndDate = false;
  bool _isLoading = false;

  // PERBAIKAN: Ganti ApiService dengan instance service yang spesifik
  late final AuthService _authService;
  late final ScheduleService _scheduleService;

  // NEW: Store original schedule ID for updates
  int? _editingScheduleId;

  @override
  void initState() {
    super.initState();
    // INI PENTING: Inisialisasi service di sini
    _authService = AuthService();
    _scheduleService = ScheduleService(_authService);

    if (widget.scheduleToEdit != null) {
      _editingScheduleId = widget.scheduleToEdit!.id;
      print('DEBUG: Editing Schedule ID: $_editingScheduleId'); // Tambahkan ini
      _titleController.text = widget.scheduleToEdit!.title;
      _descriptionController.text = widget.scheduleToEdit!.description;
      _selectedStartDate = widget.scheduleToEdit!.startDate;
      _startDateController.text = DateFormat('dd/MM/yyyy').format(_selectedStartDate!);

      if (widget.scheduleToEdit!.startDate.isAtSameMomentAs(widget.scheduleToEdit!.endDate)) {
        _hasEndDate = false;
      } else {
        _hasEndDate = true;
        _selectedEndDate = widget.scheduleToEdit!.endDate;
        _endDateController.text = DateFormat('dd/MM/yyyy').format(_selectedEndDate!);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF1E8C7A),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E8C7A),
            ),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedStartDate) {
      setState(() {
        _selectedStartDate = picked;
        _startDateController.text = DateFormat('dd/MM/yyyy').format(picked);

        if (_selectedEndDate != null && _selectedEndDate!.isBefore(picked)) {
          _selectedEndDate = null;
          _endDateController.clear();
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    if (_selectedStartDate == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih tanggal mulai terlebih dahulu!')),
        );
      }
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate ?? _selectedStartDate!,
      firstDate: _selectedStartDate!,
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF1E8C7A),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E8C7A),
            ),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedEndDate) {
      setState(() {
        _selectedEndDate = picked;
        _endDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _saveActivity() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String title = _titleController.text.trim();
    final String description = _descriptionController.text.trim();
    final DateTime? startDate = _selectedStartDate;
    final DateTime? endDate = _hasEndDate ? _selectedEndDate : _selectedStartDate;

    if (startDate == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tanggal mulai harus dipilih!')),
        );
      }
      return;
    }

    if (_hasEndDate && endDate == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tanggal selesai harus dipilih!')),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_editingScheduleId != null) {
        // This is an edit operation
        final updatedSchedule = Schedule(
          id: _editingScheduleId, // Use the existing ID, it can be nullable
          title: title,
          description: description,
          startDate: startDate,
          endDate: endDate ?? startDate,
        );
        // PERBAIKAN: Panggil method dari _scheduleService
        await _scheduleService.updateSchedule(updatedSchedule);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Kegiatan "${updatedSchedule.title}" berhasil diperbarui!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        // This is an add operation
        final newSchedule = Schedule(
          id: null, // ID will be assigned by the backend
          title: title,
          description: description,
          startDate: startDate,
          endDate: endDate ?? startDate,
        );
        // PERBAIKAN: Panggil method dari _scheduleService
        final createdSchedule = await _scheduleService.addSchedule(newSchedule);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Kegiatan "${createdSchedule.title}" berhasil ditambahkan!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan kegiatan: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Error saving schedule: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.scheduleToEdit != null;
    return Scaffold(
      backgroundColor: const Color(0xFFD9E5D6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E8C7A),
        title: Text(
          isEditing ? 'Edit Jadwal Kegiatan' : 'Tambah Jadwal Kegiatan',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _isLoading ? null : () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul Kegiatan
              ActivityTextField(
                controller: _titleController,
                labelText: 'Judul Kegiatan',
                hintText: 'Misal: Rapat Proyek Tahunan',
                icon: Icons.title,
                enabled: !_isLoading,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  if (value.trim().length < 3) {
                    return 'Judul minimal 3 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Deskripsi Kegiatan
              ActivityTextField(
                controller: _descriptionController,
                labelText: 'Deskripsi Kegiatan',
                hintText: 'Detail atau catatan tentang kegiatan ini...',
                icon: Icons.description,
                maxLines: 3,
                enabled: !_isLoading,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  if (value.trim().length < 10) {
                    return 'Deskripsi minimal 10 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Tanggal Mulai
              DateInputField(
                controller: _startDateController,
                labelText: 'Tanggal Mulai',
                hintText: 'Pilih tanggal mulai',
                prefixIcon: Icons.event_note,
                onTap: () => _selectStartDate(context),
                enabled: !_isLoading,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tanggal mulai tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Toggle End Date
              EndDateToggle(
                value: _hasEndDate,
                onChanged: (value) {
                  setState(() {
                    _hasEndDate = value;
                    if (!value) {
                      _selectedEndDate = null;
                      _endDateController.clear();
                    }
                  });
                },
                enabled: !_isLoading,
              ),
              const SizedBox(height: 10),

              // Tanggal Selesai (kondisional)
              if (_hasEndDate) ...[
                DateInputField(
                  controller: _endDateController,
                  labelText: 'Tanggal Selesai',
                  hintText: 'Pilih tanggal selesai',
                  prefixIcon: Icons.event_available,
                  onTap: () => _selectEndDate(context),
                  enabled: !_isLoading,
                  validator: (value) {
                    if (_hasEndDate && (value == null || value.isEmpty)) {
                      return 'Tanggal selesai tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
              ],

              // Extra space untuk memberikan ruang agar content tidak tertutup bottom button
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SaveButton(
          isLoading: _isLoading,
          onPressed: _saveActivity,
          // NEW: Change button text based on mode
          buttonText: isEditing ? 'Simpan Perubahan' : 'Simpan Kegiatan',
        ),
      ),
    );
  }
}