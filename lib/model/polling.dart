// models/polling.dart
import 'package:intl/intl.dart'; // Pastikan Anda menambahkan intl: ^0.18.0 di pubspec.yaml
import 'package:flutter/material.dart'; // Untuk @required atau @visibleForTesting jika diperlukan

// Model untuk Author (pengguna yang membuat polling)
class Author {
  final int id;
  final String fullName;
  final String email;

  Author({
    required this.id,
    required this.fullName,
    required this.email,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['id'] as int? ?? 0,
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
    };
  }
}

// Model untuk Opsi Polling
class PollingOption {
  final int id;
  // pollingId bisa nullable jika model ini hanya digunakan saat opsi di-embed dalam Polling
  // Jika digunakan untuk PollingOption standalone, ini mungkin required
  final int? pollingId;
  final String optionText; // Sesuai dengan 'option_text' dari API
  final int? voteCount; // Sesuai dengan 'vote_count' dari API, bisa null jika tidak di-load

  PollingOption({
    required this.id,
    this.pollingId,
    required this.optionText,
    this.voteCount,
  });

  factory PollingOption.fromJson(Map<String, dynamic> json) {
    return PollingOption(
      id: json['id'] as int? ?? 0, // 'id' dari PollingResource
      pollingId: json['polling_id'] as int?, // 'polling_id' mungkin tidak ada saat di-embed
      optionText: json['option_text'] as String? ?? '', // 'option_text' dari PollingResource
      voteCount: json['vote_count'] as int?, // 'vote_count' dari PollingResource
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'polling_id': pollingId,
      'option_text': optionText,
      'vote_count': voteCount,
    };
  }
}

// Model untuk Polling Utama
class Polling {
  final int id;
  final int userId;
  final String title;
  final String description;
  final String? pollingImage; // Nama file gambar di storage
  final String? imageUrl; // URL lengkap gambar dari API
  final DateTime deadline;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Author? author; // Relasi Author
  final List<PollingOption> options; // Relasi Options
  final bool isOpen; // is_open dari API
  final String timeRemaining; // time_remaining dari API

  Polling({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    this.pollingImage,
    this.imageUrl,
    required this.deadline,
    required this.createdAt,
    required this.updatedAt,
    this.author,
    required this.options,
    required this.isOpen,
    required this.timeRemaining,
  });

  factory Polling.fromJson(Map<String, dynamic> json) {
    // Parsing daftar opsi
    List<PollingOption> optionsList = [];
    if (json['options'] != null) {
      optionsList = (json['options'] as List)
          .map((i) => PollingOption.fromJson(i))
          .toList();
    }

    // Parsing author
    Author? authorData;
    if (json['author'] != null) {
      authorData = Author.fromJson(json['author']);
    }

    return Polling(
      id: json['id'] as int? ?? 0, // Sesuai dengan 'id' dari PollingResource
      userId: json['user_id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      pollingImage: json['polling_image'] as String?, // Nama file di storage
      imageUrl: json['image_url'] as String?, // URL lengkap gambar
      deadline: DateTime.parse(json['deadline'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      author: authorData,
      options: optionsList,
      isOpen: json['is_open'] as bool? ?? false,
      timeRemaining: json['time_remaining'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'polling_image': pollingImage,
      'image_url': imageUrl,
      'deadline': deadline.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'author': author?.toJson(),
      'options': options.map((e) => e.toJson()).toList(),
      'is_open': isOpen,
      'time_remaining': timeRemaining,
    };
  }
}

// Model untuk PollingVote
class PollingVote {
  final int id;
  final int pollingId;
  final int pollingOptionId;
  final int? userId; // Nullable as per PHP model

  PollingVote({
    required this.id,
    required this.pollingId,
    required this.pollingOptionId,
    this.userId,
  });

  factory PollingVote.fromJson(Map<String, dynamic> json) {
    return PollingVote(
      id: json['id_vote'] as int? ?? 0, // 'id_vote' dari API
      pollingId: json['polling_id'] as int? ?? 0,
      pollingOptionId: json['polling_option_id'] as int? ?? 0,
      userId: json['user_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_vote': id,
      'polling_id': pollingId,
      'polling_option_id': pollingOptionId,
      'user_id': userId,
    };
  }
}
