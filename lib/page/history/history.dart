import 'package:flutter/material.dart';
import 'package:plan_ease/widget/history/history.dart';

class RiwayatPollingScreen extends StatefulWidget {
  const RiwayatPollingScreen({super.key});

  @override
  State<RiwayatPollingScreen> createState() => _RiwayatPollingScreenState();
}

class _RiwayatPollingScreenState extends State<RiwayatPollingScreen> {
  int? expandedIndex;
  String? _selectedKategori;
  final List<String> _kategoriList = ['Semua', 'Rapat', 'Kegiatan', 'Lainnya'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9E5D6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E8C7A),
        title: const Text('Riwayat Polling'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Filter bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                const Text(
                  "Riwayat Polling",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F6EC),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      hint: const Text('Pilih kategori polling'),
                      value: _selectedKategori,
                      onChanged: (value) {
                        setState(() {
                          _selectedKategori = value;
                        });
                      },
                      items: _kategoriList
                          .map((kategori) => DropdownMenuItem<String>(
                                value: kategori,
                                child: Text(kategori),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // List polling
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: 3,
              itemBuilder: (context, index) {
                return HistoryPollingItem(
                  index: index,
                  isExpanded: expandedIndex == index,
                  onToggle: () {
                    setState(() {
                      expandedIndex =
                          expandedIndex == index ? null : index;
                    });
                  },
                );
              },
            ),
          ),

          // Pagination
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_left)),
                const Text('1/10'),
                IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_right)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
