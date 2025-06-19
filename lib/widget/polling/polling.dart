import 'package:flutter/material.dart';

// PollingOption class tetap di sini untuk struktur data opsi statis
// meskipun tidak lagi digunakan sebagai parameter eksternal
class PollingOption {
  final String id;
  final String title;
  int votes;

  PollingOption({required this.id, required this.title, this.votes = 0});

  // Helper untuk membuat daftar opsi dummy
  static List<PollingOption> dummyOptions() {
    return [
      PollingOption(id: '1', title: '24 Juni 2025', votes: 15),
      PollingOption(id: '2', title: '28 Juni 2025', votes: 8),
      PollingOption(id: '3', title: '30 Juni 2025', votes: 3),
      PollingOption(id: '4', title: '2 Juli 2025', votes: 0),
    ];
  }
}

class PollingItem extends StatefulWidget { // Kembali ke StatefulWidget
  final bool isExpanded;
  final VoidCallback onToggle;

  const PollingItem({
    super.key,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  State<PollingItem> createState() => _PollingItemState();
}

class _PollingItemState extends State<PollingItem> {
  // Data Polling statis untuk PollingItem ini
  // Ini adalah data yang akan ditampilkan oleh satu PollingItem
  final String _pollTitle = 'Pilih Jadwal Rapat Bulanan';
  final DateTime _pollEndDate = DateTime(2025, 6, 24); // Tanggal berakhir statis

  // Data opsi polling statis
  final List<PollingOption> _staticOptions = PollingOption.dummyOptions();

  // NEW: State untuk menyimpan indeks opsi yang dipilih
  int? _selectedOptionIndex;

  @override
  void initState() {
    super.initState();
    // Di aplikasi nyata, Anda bisa memuat pilihan pengguna sebelumnya dari API
  }

  // NEW: Fungsi untuk menangani saat opsi polling ditekan
  void _handleOptionTap(int index) {
    setState(() {
      // Jika opsi yang sama ditekan lagi, batalkan pilihan (optional)
      // _selectedOptionIndex = _selectedOptionIndex == index ? null : index;
      // Atau, untuk memastikan hanya SATU yang terpilih:
      _selectedOptionIndex = index;
    });

    // Simulasi aksi setelah memilih (misalnya, mengirim pilihan ke server)
    final selectedOption = _staticOptions[index];
    print('Pilihan Anda: ${selectedOption.title}');
    // Anda bisa menambahkan logika untuk mengirim pilihan ke backend di sini
    // (misalnya: ApiService().castVote(selectedOption.id, selectedOption.title));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Anda memilih: ${selectedOption.title}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int totalVotes = _staticOptions.fold(0, (sum, option) => sum + option.votes);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F6EC),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            leading: Container(
              width: 28,
              height: 28,
              color: const Color(0xFF1E8C7A),
            ),
            title: Text(_pollTitle),
            subtitle: Text("Berakhir: ${_pollEndDate.day}/${_pollEndDate.month}/${_pollEndDate.year}"),
            trailing: IconButton(
              icon: Icon(
                widget.isExpanded ? Icons.expand_less : Icons.expand_more,
              ),
              onPressed: widget.onToggle,
            ),
          ),
          if (widget.isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ..._staticOptions.asMap().entries.map((entry) {
                    int idx = entry.key;
                    PollingOption option = entry.value;
                    double percentage = totalVotes == 0 ? 0.0 : option.votes / totalVotes;
                    bool isSelected = _selectedOptionIndex == idx; // NEW: cek apakah opsi ini dipilih

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: PollingOptionBar(
                        title: option.title,
                        percentage: percentage,
                        color: const Color(0xFF1E8C7A),
                        isSelected: isSelected, // NEW: teruskan state pilihan
                        onTap: () => _handleOptionTap(idx), // NEW: teruskan fungsi onTap
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 8),
                  // Opsional: Tampilkan teks "Anda telah memilih..." jika sudah ada pilihan
                  if (_selectedOptionIndex != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Anda telah memilih: "${_staticOptions[_selectedOptionIndex!].title}"',
                        style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.green),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class PollingOptionBar extends StatelessWidget {
  final String title;
  final double percentage;
  final Color color;
  final bool isSelected; // NEW: Indikator apakah opsi ini terpilih
  final VoidCallback onTap; // NEW: Callback saat opsi ditekan

  const PollingOptionBar({
    super.key,
    required this.title,
    required this.percentage,
    required this.color,
    required this.isSelected, // Harus disediakan
    required this.onTap,      // Harus disediakan
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector( // Wrapper untuk membuatnya bisa ditekan
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent, // Background highlight saat terpilih
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : Colors.transparent, // Border saat terpilih
            width: isSelected ? 1.5 : 0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row( // Menggunakan Row untuk judul dan centang
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                ),
                if (isSelected) // NEW: Tampilkan ikon centang jika terpilih
                  Icon(Icons.check_circle, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 4),
            Stack(
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      height: 10,
                      width: constraints.maxWidth * percentage,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 2),
            Align(
              alignment: Alignment.topRight,
              child: Text(
                '${(percentage * 100).toInt()}%',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}