// page/polling/form_polling.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'dart:io'; // Untuk File
import 'package:image_picker/image_picker.dart'; // Untuk ImagePicker

import 'package:plan_ease/service/auth_service.dart';
import 'package:plan_ease/service/polling_service.dart';
import 'package:plan_ease/model/polling.dart' as PollingModel; // Alias untuk PollingOption

// Enum untuk memudahkan pengelolaan jenis polling
enum PollingType {
  tema,
  baju,
  jadwalKegiatan,
  lainnya,
}

class CreatePollingScreen extends StatefulWidget {
  const CreatePollingScreen({super.key});

  @override
  State<CreatePollingScreen> createState() => _CreatePollingScreenState();
}

class _CreatePollingScreenState extends State<CreatePollingScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController(); // Untuk deskripsi
  final TextEditingController _deadlineController = TextEditingController(); // Untuk deadline
  DateTime? _selectedDeadline; // Untuk menyimpan objek DateTime deadline

  PollingType? _selectedPollingType; // State untuk dropdown jenis polling

  // Lists untuk mengelola input dinamis
  final List<TextEditingController> _temaControllers = [];
  final List<File?> _bajuImageFiles = []; // Untuk menyimpan File gambar baju
  final List<TextEditingController> _jadwalDateControllers = [];
  final List<DateTime?> _jadwalSelectedDates = [];
  final List<TextEditingController> _lainnyaControllers = [];

  File? _pickedImage; // Untuk gambar polling utama
  bool _isLoading = false; // State untuk indikator loading saat submit

  late final AuthService _authService;
  late final PollingService _pollingService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _pollingService = PollingService(_authService);
    // Inisialisasi satu field untuk setiap jenis secara default jika diperlukan
    // _addTemaField(); // Contoh: langsung munculkan 1 field tema
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _deadlineController.dispose();
    for (var controller in _temaControllers) {
      controller.dispose();
    }
    // _bajuImageFiles tidak perlu dispose controller
    for (var controller in _jadwalDateControllers) {
      controller.dispose();
    }
    for (var controller in _lainnyaControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // --- Fungsi untuk menambah field dinamis ---

  void _addTemaField() {
    setState(() {
      _temaControllers.add(TextEditingController());
    });
  }

  void _addBajuField() {
    setState(() {
      _bajuImageFiles.add(null); // Tambahkan placeholder untuk upload
    });
    // Panggil _pickFile secara otomatis setelah menambahkan field jika diinginkan
    // _pickFileForOption(_bajuImageFiles.length - 1);
  }

  void _addJadwalField() {
    setState(() {
      _jadwalDateControllers.add(TextEditingController());
      _jadwalSelectedDates.add(null);
    });
  }

  void _addLainnyaField() {
    setState(() {
      _lainnyaControllers.add(TextEditingController());
    });
  }

  // --- Fungsi untuk memilih tanggal deadline polling utama ---
  Future<void> _selectDeadlineDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now().add(const Duration(days: 1)), // Default besok
      firstDate: DateTime.now(), // Tidak bisa memilih tanggal di masa lalu
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF1E8C7A),
            colorScheme: const ColorScheme.light(primary: Color(0xFF1E8C7A)),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDeadline = picked;
        _deadlineController.text = DateFormat('yyyy-MM-dd').format(picked); // Format sesuai API Laravel
      });
    }
  }

  // --- Fungsi untuk memilih tanggal opsi jadwal kegiatan ---
  Future<void> _selectJadwalDate(BuildContext context, int index) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _jadwalSelectedDates[index] ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF1E8C7A),
            colorScheme: const ColorScheme.light(primary: Color(0xFF1E8C7A)),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _jadwalSelectedDates[index] = picked;
        _jadwalDateControllers[index].text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  // --- Fungsi untuk memilih gambar polling utama ---
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gambar utama dipilih: ${pickedFile.name}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pemilihan gambar dibatalkan.')),
      );
    }
  }

  // --- Fungsi untuk memilih gambar opsi baju ---
  Future<void> _pickImageForOption(int index) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _bajuImageFiles[index] = File(pickedFile.path);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gambar baju ${index + 1} dipilih: ${pickedFile.name}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pemilihan gambar baju dibatalkan.')),
      );
    }
  }


  // --- Fungsi untuk membuat polling ---
  void _createPolling() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true; // Mulai loading
      });

      String title = _titleController.text;
      String description = _descriptionController.text;
      String deadline = _selectedDeadline!.toIso8601String(); // Format ke ISO 8601 string untuk API

      List<Map<String, String>> options = [];
      String? pollingImageFilename; // Untuk polling_image di API (nama file)

      // Mengumpulkan opsi berdasarkan jenis polling yang dipilih
      switch (_selectedPollingType) {
        case PollingType.tema:
          for (var controller in _temaControllers) {
            options.add({'option': controller.text});
          }
          break;
        case PollingType.baju:
          for (int i = 0; i < _bajuImageFiles.length; i++) {
            if (_bajuImageFiles[i] != null) {
              // Untuk opsi baju, kita akan mengirim nama file atau path sementara
              // API Laravel Anda menerima 'option' sebagai string.
              // Jika Anda ingin menyimpan path gambar untuk setiap opsi baju,
              // Anda perlu menyesuaikan model PollingOption di Laravel.
              // Untuk saat ini, kita akan mengirim nama file sebagai 'option'.
              options.add({'option': _bajuImageFiles[i]!.path.split('/').last}); // Mengambil nama file
            }
          }
          // Jika Anda ingin mengunggah gambar baju sebagai bagian dari opsi,
          // ini akan menjadi implementasi yang lebih kompleks (misal, multiple file upload)
          // Untuk saat ini, kita hanya mengirim nama file.
          break;
        case PollingType.jadwalKegiatan:
          for (int i = 0; i < _jadwalSelectedDates.length; i++) {
            if (_jadwalSelectedDates[i] != null) {
              options.add({'option': DateFormat('yyyy-MM-dd').format(_jadwalSelectedDates[i]!)});
            }
          }
          break;
        case PollingType.lainnya:
          for (var controller in _lainnyaControllers) {
            options.add({'option': controller.text});
          }
          break;
        case null:
          // Validasi harusnya sudah menangani ini
          break;
      }

      // Pastikan ada minimal 2 opsi
      if (options.length < 2) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Harap tambahkan minimal 2 opsi polling.')),
        );
        return;
      }

      Map<String, dynamic> pollingData = {
        'title': title,
        'description': description,
        'deadline': deadline,
        'options': options,
      };

      try {
        final newPolling = await _pollingService.createPolling(
          pollingData,
          imageFile: _pickedImage, // Kirim gambar polling utama
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Polling "${newPolling.title}" berhasil dibuat!')),
          );
          Navigator.pop(context, true); // Kembali ke halaman sebelumnya dan beri sinyal refresh
        }
      } catch (e) {
        print('Error creating polling: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal membuat polling: ${e.toString().replaceFirst('Exception: ', '')}')),
          );
        }
      } finally {
        setState(() {
          _isLoading = false; // Hentikan loading
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9E5D6),
      appBar: AppBar(
        title: const Text('Buat Polling Baru'),
        backgroundColor: const Color(0xFF1E8C7A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul Polling
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Judul Polling',
                  hintText: 'Misal: Polling Jadwal Rapat',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.title, color: Color(0xFF1E8C7A)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul polling tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Deskripsi Polling
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Deskripsi (Opsional)',
                  hintText: 'Misal: Membahas agenda rapat bulanan',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.description, color: Color(0xFF1E8C7A)),
                ),
              ),
              const SizedBox(height: 15),

              // Deadline Polling
              TextFormField(
                controller: _deadlineController,
                readOnly: true,
                onTap: () => _selectDeadlineDate(context),
                decoration: InputDecoration(
                  labelText: 'Deadline Polling',
                  hintText: 'Pilih tanggal dan waktu berakhir polling',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF1E8C7A)),
                  suffixIcon: const Icon(Icons.arrow_drop_down, color: Color(0xFF1E8C7A)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deadline polling tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Upload Gambar Polling Utama
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.image, color: _pickedImage != null ? Colors.green : Colors.grey),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _pickedImage != null ? _pickedImage!.path.split('/').last : 'Upload Gambar Polling (Opsional)',
                          style: TextStyle(
                            color: _pickedImage != null ? Colors.black87 : Colors.grey[600],
                          ),
                        ),
                      ),
                      if (_pickedImage != null) const Icon(Icons.check_circle, color: Colors.green),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Dropdown Jenis Polling
              DropdownButtonFormField<PollingType>(
                value: _selectedPollingType,
                decoration: InputDecoration(
                  labelText: 'Jenis Polling',
                  hintText: 'Pilih jenis polling',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.category, color: Color(0xFF1E8C7A)),
                ),
                items: const [
                  DropdownMenuItem(
                    value: PollingType.tema,
                    child: Text('Tema'),
                  ),
                  DropdownMenuItem(
                    value: PollingType.baju,
                    child: Text('Baju'),
                  ),
                  DropdownMenuItem(
                    value: PollingType.jadwalKegiatan,
                    child: Text('Jadwal Kegiatan'),
                  ),
                  DropdownMenuItem(
                    value: PollingType.lainnya,
                    child: Text('Lainnya'),
                  ),
                ],
                onChanged: (PollingType? newValue) {
                  setState(() {
                    _selectedPollingType = newValue;
                    // Reset semua field dinamis saat jenis polling berubah
                    _temaControllers.clear();
                    _bajuImageFiles.clear();
                    _jadwalDateControllers.clear();
                    _jadwalSelectedDates.clear();
                    _lainnyaControllers.clear();

                    // Tambahkan satu field awal sesuai jenis yang dipilih
                    if (newValue == PollingType.tema) _addTemaField();
                    if (newValue == PollingType.baju) _addBajuField();
                    if (newValue == PollingType.jadwalKegiatan) _addJadwalField();
                    if (newValue == PollingType.lainnya) _addLainnyaField();
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Jenis polling harus dipilih';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // --- Bagian Dinamis berdasarkan Jenis Polling ---
              if (_selectedPollingType == PollingType.tema) ...[
                const Text('Opsi Tema:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true, // Penting agar ListView dapat bersarang dalam Column/SingleChildScrollView
                  physics: const NeverScrollableScrollPhysics(), // Non-scrollable
                  itemCount: _temaControllers.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: TextFormField(
                        controller: _temaControllers[index],
                        decoration: InputDecoration(
                          labelText: 'Tema ${index + 1}',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Tema ${index + 1} tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _addTemaField,
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Tambah Tema', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E8C7A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],

              if (_selectedPollingType == PollingType.baju) ...[
                const Text('Opsi Baju:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _bajuImageFiles.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: GestureDetector(
                        onTap: () => _pickImageForOption(index),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.upload_file, color: _bajuImageFiles[index] != null ? Colors.green : Colors.grey),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _bajuImageFiles[index] != null ? _bajuImageFiles[index]!.path.split('/').last : 'Upload Baju ${index + 1} (Tap untuk memilih)',
                                  style: TextStyle(
                                    color: _bajuImageFiles[index] != null ? Colors.black87 : Colors.grey[600],
                                  ),
                                ),
                              ),
                              if (_bajuImageFiles[index] != null) const Icon(Icons.check_circle, color: Colors.green),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _addBajuField,
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Tambah Baju', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E8C7A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],

              if (_selectedPollingType == PollingType.jadwalKegiatan) ...[
                const Text('Opsi Jadwal Kegiatan:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _jadwalDateControllers.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: TextFormField(
                        controller: _jadwalDateControllers[index],
                        readOnly: true,
                        onTap: () => _selectJadwalDate(context, index),
                        decoration: InputDecoration(
                          labelText: 'Jadwal ${index + 1}',
                          hintText: 'Pilih tanggal',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF1E8C7A)),
                          suffixIcon: const Icon(Icons.arrow_drop_down, color: Color(0xFF1E8C7A)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Jadwal ${index + 1} tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _addJadwalField,
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Tambah Jadwal', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E8C7A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],

              if (_selectedPollingType == PollingType.lainnya) ...[
                const Text('Opsi Lainnya:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _lainnyaControllers.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: TextFormField(
                        controller: _lainnyaControllers[index],
                        decoration: InputDecoration(
                          labelText: 'Pilihan ${index + 1}',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Pilihan ${index + 1} tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _addLainnyaField,
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Tambah Pilihan', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E8C7A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 30),

              // Tombol Buat Polling
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createPolling, // Nonaktifkan tombol saat loading
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E8C7A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white) // Tampilkan loading
                      : const Text(
                          'Buat Polling',
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
