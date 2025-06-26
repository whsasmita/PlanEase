import 'package:intl/intl.dart';

class Profile {
  final int id;
  final int userId;
  final String? photoProfile; 
  final String? position; 
  final String? organisation;

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