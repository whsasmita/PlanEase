import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting

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

  PollingType? _selectedPollingType; // State untuk dropdown jenis polling

  // Lists untuk mengelola input dinamis
  final List<TextEditingController> _temaControllers = [];
  final List<String?> _bajuFileNames = []; // Untuk menyimpan nama file baju
  final List<TextEditingController> _jadwalDateControllers = [];
  final List<DateTime?> _jadwalSelectedDates = [];
  final List<TextEditingController> _lainnyaControllers = [];

  @override
  void initState() {
    super.initState();
    // Inisialisasi satu field untuk setiap jenis secara default jika diperlukan
    // _addTemaField(); // Contoh: langsung munculkan 1 field tema
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (var controller in _temaControllers) {
      controller.dispose();
    }
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
      _bajuFileNames.add(null); // Tambahkan placeholder untuk upload
      // Simulasi pick file jika ingin langsung muncul dialog pickernya
      // _pickFile(context, _bajuFileNames.length - 1);
    });
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

  // --- Fungsi untuk memilih tanggal ---
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

  // --- Fungsi untuk simulasi upload file (perlu package file_picker/image_picker untuk real) ---
  void _pickFile(BuildContext context, int index) async {
    // Implementasi real memerlukan package seperti:
    // import 'package:file_picker/file_picker.dart';
    // FilePickerResult? result = await FilePicker.platform.pickFiles();
    // if (result != null) {
    //   setState(() {
    //     _bajuFileNames[index] = result.files.first.name;
    //   });
    // } else {
    //   // User canceled the picker
    // }

    // Simulasi:
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Simulasi: Dialog upload file muncul...')),
    );
    await Future.delayed(const Duration(seconds: 1)); // Simulasi delay
    setState(() {
      _bajuFileNames[index] = 'baju_${index + 1}_uploaded.png';
    });
  }

  // --- Fungsi untuk membuat polling ---
  void _createPolling() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String title = _titleController.text;
      print('Judul Polling: $title');
      print('Jenis Polling: ${_selectedPollingType?.name}');

      switch (_selectedPollingType) {
        case PollingType.tema:
          for (int i = 0; i < _temaControllers.length; i++) {
            print('Tema ${i + 1}: ${_temaControllers[i].text}');
          }
          break;
        case PollingType.baju:
          for (int i = 0; i < _bajuFileNames.length; i++) {
            print('Baju ${i + 1} File: ${_bajuFileNames[i] ?? "Belum diupload"}');
          }
          break;
        case PollingType.jadwalKegiatan:
          for (int i = 0; i < _jadwalSelectedDates.length; i++) {
            print('Jadwal ${i + 1}: ${_jadwalSelectedDates[i] != null ? DateFormat('dd/MM/yyyy').format(_jadwalSelectedDates[i]!) : "Belum dipilih"}');
          }
          break;
        case PollingType.lainnya:
          for (int i = 0; i < _lainnyaControllers.length; i++) {
            print('Pilihan Lainnya ${i + 1}: ${_lainnyaControllers[i].text}');
          }
          break;
        case null:
          // Should not happen if dropdown is validated
          break;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Polling berhasil dibuat! Data dicetak di konsol.')),
      );

      // Kembali ke halaman sebelumnya
      Navigator.pop(context);
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
                    _bajuFileNames.clear();
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
                  itemCount: _bajuFileNames.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: GestureDetector(
                        onTap: () => _pickFile(context, index),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.upload_file, color: _bajuFileNames[index] != null ? Colors.green : Colors.grey),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _bajuFileNames[index] ?? 'Upload Baju ${index + 1} (Tap untuk memilih)',
                                  style: TextStyle(
                                    color: _bajuFileNames[index] != null ? Colors.black87 : Colors.grey[600],
                                  ),
                                ),
                              ),
                              if (_bajuFileNames[index] != null) const Icon(Icons.check_circle, color: Colors.green),
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
                  onPressed: _createPolling,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E8C7A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
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