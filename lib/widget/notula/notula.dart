import 'package:flutter/material.dart';
import 'package:plan_ease/model/model.dart';
import 'package:plan_ease/page/notula/detail_notula.dart'; // Perlu diimpor karena kita navigasi ke sana

class NotulaListItem extends StatelessWidget {
  final Notula notula;

  const NotulaListItem({Key? key, required this.notula}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      elevation: 2,
      child: InkWell( // Membuat kartu bisa diketuk
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HalamanDetailNotula(notula: notula),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notula.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                notula.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                maxLines: 2, // Batasi deskripsi hingga 2 baris
                overflow: TextOverflow.ellipsis, // Tambahkan elipsis jika melebihi batas
              ),
            ],
          ),
        ),
      ),
    );
  }
}