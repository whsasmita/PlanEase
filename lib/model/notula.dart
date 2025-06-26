import 'package:intl/intl.dart';

class Notula {
  String? id; 
  final String title;
  final String description;
  final String content;

  Notula({
    this.id,
    required this.title,
    required this.description,
    required this.content,
  });

  factory Notula.fromJson(Map<String, dynamic> json) {
    return Notula(
      id: json['id'] != null ? json['id'].toString() : null,
      title: json['title'] as String,
      description: json['description'] as String,
      content: json['content'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'title': title,
      'description': description,
      'content': content,
    };
    if (id != null) {
      data['id'] = id;
    }
    return data;
  }
}