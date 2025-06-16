// lib/pages/halaman_detail_notula.dart
import 'package:flutter/material.dart';
import 'package:plan_ease/model/model.dart';

class HalamanDetailNotula extends StatelessWidget {
  final Notula notula;

  const HalamanDetailNotula({Key? key, required this.notula}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9E5D6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E8C7A),
        title: const Text('Detail Notula'),
        centerTitle: true,
        foregroundColor: Colors.white,
        leading: IconButton( // Tombol kembali khusus untuk halaman detail
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notula.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              notula.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontStyle: FontStyle.italic,
              ),
            ),
            const Divider(height: 32, thickness: 1),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  notula.content,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}