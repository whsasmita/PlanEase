// lib/page/jadwal/tambah_kegiatan_screen.dart
import 'package:flutter/material.dart';

class TambahKegiatanScreen extends StatefulWidget {
  const TambahKegiatanScreen({super.key});

  @override
  State<TambahKegiatanScreen> createState() => _TambahKegiatanScreenState();
}

class _TambahKegiatanScreenState extends State<TambahKegiatanScreen> {
  final _formKey = GlobalKey<FormState>(); // Key to validate the form
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController =
      TextEditingController(); // Controller for date text field

  DateTime? _selectedDate; // Stores the actual selected date

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  // Function to show the date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDate ?? DateTime.now(), // Use selected date or current date
      firstDate: DateTime(2000), // Start selectable date range
      lastDate: DateTime(2101), // End selectable date range
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF1E8C7A), // Header background color
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E8C7A),
            ), // Selected date color
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // Format the date for display in the text field
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  // Function to handle saving the activity
  void _saveActivity() {
    if (_formKey.currentState!.validate()) {
      // If the form is valid, proceed with saving
      final String title = _titleController.text;
      final String description = _descriptionController.text;
      final DateTime? date = _selectedDate;

      if (date == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tanggal kegiatan harus dipilih!')),
        );
        return;
      }

      // Here you would typically send this data to your API or database.
      // For now, let's just print it and pop the screen.
      print('New Activity:');
      print('Title: $title');
      print('Description: $description');
      print('Date: $date');

      // You can pass the new activity data back to the previous screen (JadwalScreen)
      // For example: Navigator.pop(context, {'title': title, 'description': description, 'date': date});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kegiatan berhasil ditambahkan!')),
      );

      Navigator.pop(context); // Go back to the previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9E5D6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E8C7A),
        title: const Text('Tambah Jadwal Kegiatan'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        // Use SingleChildScrollView for scrollability
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Assign the form key
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul Kegiatan
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Judul Kegiatan',
                  hintText: 'Misal: Rapat Proyek Tahunan',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.title, color: Color(0xFF1E8C7A)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Deskripsi Kegiatan
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Deskripsi Kegiatan',
                  hintText: 'Detail atau catatan tentang kegiatan ini...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(
                    Icons.description,
                    color: Color(0xFF1E8C7A),
                  ),
                ),
                maxLines: 3, // Allow multiple lines for description
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Tanggal Kegiatan
              TextFormField(
                controller: _dateController,
                readOnly:
                    true, // Make text field read-only to prevent manual input
                onTap: () => _selectDate(context), // Open date picker on tap
                decoration: InputDecoration(
                  labelText: 'Tanggal Kegiatan',
                  hintText: 'Pilih tanggal',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(
                    Icons.calendar_today,
                    color: Color(0xFF1E8C7A),
                  ),
                  suffixIcon: const Icon(
                    Icons.arrow_drop_down,
                    color: Color(0xFF1E8C7A),
                  ), // Dropdown icon
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tanggal tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // Save Button
              SizedBox(
                width: double.infinity, // Make button full width
                child: ElevatedButton(
                  onPressed: _saveActivity,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF1E8C7A,
                    ), // Button background color
                    foregroundColor: Colors.white, // Button text color
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Simpan Kegiatan',
                    style: TextStyle(fontSize: 18),
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
