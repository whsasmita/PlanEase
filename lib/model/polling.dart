import 'package:intl/intl.dart';

class Polling {
  final int id;
  final int userId;
  final String title;
  final String description;
  final String? pollingImage; // Nullable
  final DateTime deadline;

  // Relationships (Dart models won't directly have relationship methods like Eloquent)
  // You'd typically fetch these related models separately or include them in the API response
  // and parse them here if they are embedded.

  Polling({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    this.pollingImage,
    required this.deadline,
  });

  factory Polling.fromJson(Map<String, dynamic> json) {
    return Polling(
      id: json['id_polling'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      pollingImage: json['polling_image'] as String?,
      deadline: DateTime.parse(json['deadline'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_polling': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'polling_image': pollingImage,
      'deadline': deadline.toIso8601String(),
    };
  }
}

// PollingOption Model
class PollingOption {
  final int id;
  final int pollingId;
  final String option;

  PollingOption({
    required this.id,
    required this.pollingId,
    required this.option,
  });

  factory PollingOption.fromJson(Map<String, dynamic> json) {
    return PollingOption(
      id: json['id_option'] as int? ?? 0,
      pollingId: json['polling_id'] as int? ?? 0,
      option: json['option'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id_option': id, 'polling_id': pollingId, 'option': option};
  }
}

// PollingVote Model
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
      id: json['id_vote'] as int? ?? 0,
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