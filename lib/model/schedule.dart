import 'package:intl/intl.dart';

class Schedule {
  final int? id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;

  Schedule({
    this.id, 
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    final dynamic idFromApi = json['id'];
    int? parsedId;

    if (idFromApi is int) {
      parsedId = idFromApi;
    } else if (idFromApi is String) {
      parsedId = int.tryParse(idFromApi);
    }

    return Schedule(
      id: parsedId,
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

  bool isActive() {
    final today = DateTime.now();
    return today.isAfter(startDate.subtract(const Duration(days: 1))) &&
        today.isBefore(endDate.add(const Duration(days: 1)));
  }

  bool isUpcoming() {
    return DateTime.now().isBefore(startDate);
  }

  bool isPast() {
    return DateTime.now().isAfter(endDate);
  }

  int getDurationInDays() {
    return endDate.difference(startDate).inDays + 1;
  }

  String getFormattedDateRange() {
    final DateFormat formatter = DateFormat(
      'dd MMM yyyy',
    ); 
    if (startDate.year == endDate.year &&
        startDate.month == endDate.month &&
        startDate.day == endDate.day) {
      return formatter.format(startDate);
    }
    return '${formatter.format(startDate)} - ${formatter.format(endDate)}';
  }

  int getDaysUntilStart() {
    return startDate.difference(DateTime.now()).inDays;
  }

  int getDaysUntilEnd() {
    return endDate.difference(DateTime.now()).inDays;
  }

  bool shouldNotifyIn(int days) {
    final targetDate = DateTime.now().add(Duration(days: days));
    return startDate.year == targetDate.year &&
        startDate.month == targetDate.month &&
        startDate.day == targetDate.day;
  }
}