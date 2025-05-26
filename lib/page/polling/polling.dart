import 'package:flutter/material.dart';
import 'package:plan_ease/page/history/history.dart';
import 'package:plan_ease/widget/polling//polling.dart';

class PollingScreen extends StatefulWidget {
  const PollingScreen({super.key});

  @override
  State<PollingScreen> createState() => _PollingScreenState();
}

class _PollingScreenState extends State<PollingScreen> {
  int? expandedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9E5D6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E8C7A),
        title: const Text('Polling'),
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
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const RiwayatPollingScreen(),
                      ),
                    );
                  },
                  child: Row(
                    children: const [
                      Icon(Icons.history, color: Color(0xFF1E8C7A)),
                      SizedBox(width: 8),
                      Text(
                        "Riwayat",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F6EC),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: const [
                      Text("Pilih kategori polling"),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),

          // List polling
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: 10,
              itemBuilder: (context, index) {
                return PollingItem(
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

          // Footer pagination
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.arrow_left),
                ),
                const Text('1/10'),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.arrow_right),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
