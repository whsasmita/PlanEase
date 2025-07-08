import 'package:intl/intl.dart';
import 'package:plan_ease/model/auth.dart'; 

class Profile {
  final int id;
  final int userId;
  final String? photoProfilePath;
  final String? photoProfileUrl;
  final String? division;
  final String? position;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final User? user; 

  Profile({
    required this.id,
    required this.userId,
    this.photoProfilePath,
    this.photoProfileUrl,
    this.division,
    this.position,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic dateString) {
      if (dateString == null) return null;
      try {
        return DateFormat('yyyy-MM-dd').parse(dateString);
      } catch (e) {
        print('Error parsing date: $dateString, Error: $e');
        return null;
      }
    }

    return Profile(
      id: json['id_profile'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      photoProfilePath: json['photo_profile'] as String?,
      photoProfileUrl: json['photo_profile_url'] as String?,
      division: json['division'] as String?,
      position: json['position'] as String?,
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
      user: json['user'] != null ? User.fromJson(json['user'] as Map<String, dynamic>) : null, // Mem-parsing objek user
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_profile': id,
      'user_id': userId,
      'photo_profile': photoProfilePath,
      'division': division,
      'position': position,
    };
  }
}
