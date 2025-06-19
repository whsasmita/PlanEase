import 'package:intl/intl.dart';
class Notula {
  String? id; // Can be nullable if backend generates it on creation
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
      // CRITICAL FIX HERE: Explicitly cast to String or convert to String
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
      data['id'] = id; // Include ID only if it exists (for updates)
    }
    return data;
  }
}

// User Model (Updated based on PHP Model)
class User {
  final int id;
  final String fullName;
  final String email;
  final String? emailVerifiedAt; // Nullable as per PHP model
  final String? phone; // Nullable as per PHP model
  final String role;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    this.emailVerifiedAt,
    this.phone,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id_user'] as int? ?? 0, // Assuming 'id_user' from PHP model
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      emailVerifiedAt: json['email_verified_at'] as String?,
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_user': id,
      'full_name': fullName,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'phone': phone,
      'role': role,
    };
  }
}

// LoginApiResponse Model
class LoginApiResponse {
  final String message;
  final User? user;
  final String? accessToken;
  final String? tokenType;
  final int? expiresIn;

  LoginApiResponse({
    required this.message,
    this.user,
    this.accessToken,
    this.tokenType,
    this.expiresIn,
  });

  factory LoginApiResponse.fromJson(Map<String, dynamic> json) {
    return LoginApiResponse(
      message: json['message'] as String? ?? 'Unknown message',
      user: json['user'] != null
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      accessToken: json['access_token'] as String?,
      tokenType: json['token_type'] as String?,
      expiresIn: json['expires_in'] as int?,
    );
  }
}

// Polling Model
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
    return {
      'id_option': id,
      'polling_id': pollingId,
      'option': option,
    };
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

// Profile Model
class Profile {
  final int id;
  final int userId;
  final String? photoProfile; // Nullable
  final String? position; // Nullable
  final String? organisation; // Nullable

  Profile({
    required this.id,
    required this.userId,
    this.photoProfile,
    this.position,
    this.organisation,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id_profile'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      photoProfile: json['photo_profile'] as String?,
      position: json['position'] as String?,
      organisation: json['organisation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_profile': id,
      'user_id': userId,
      'photo_profile': photoProfile,
      'position': position,
      'organisation': organisation,
    };
  }
}

// Schedule Model
class Schedule {
  final int id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;

  Schedule({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id_schedule'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_schedule': id,
      'title': title,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    };
  }

  /// Checks if the schedule is currently active.
  bool isActive() {
    final today = DateTime.now();
    return today.isAfter(startDate.subtract(Duration(days: 1))) &&
        today.isBefore(endDate.add(Duration(days: 1)));
  }

  /// Checks if the schedule is upcoming.
  bool isUpcoming() {
    return DateTime.now().isBefore(startDate);
  }

  /// Checks if the schedule is in the past.
  bool isPast() {
    return DateTime.now().isAfter(endDate);
  }

  /// Gets the duration of the schedule in days.
  int getDurationInDays() {
    return endDate.difference(startDate).inDays + 1;
  }

  /// Gets a formatted date range for display.
  String getFormattedDateRange() {
    final DateFormat formatter = DateFormat('dd MMM yyyy');
    if (startDate.year == endDate.year &&
        startDate.month == endDate.month &&
        startDate.day == endDate.day) {
      return formatter.format(startDate);
    }
    return '${formatter.format(startDate)} - ${formatter.format(endDate)}';
  }

  /// Gets the number of days until the schedule starts.
  int getDaysUntilStart() {
    return startDate.difference(DateTime.now()).inDays;
  }

  /// Gets the number of days until the schedule ends.
  int getDaysUntilEnd() {
    return endDate.difference(DateTime.now()).inDays;
  }

  /// Checks if a notification should be triggered for a specific number of days before the start.
  bool shouldNotifyIn(int days) {
    final targetDate = DateTime.now().add(Duration(days: days));
    return startDate.year == targetDate.year &&
        startDate.month == targetDate.month &&
        startDate.day == targetDate.day;
  }
}