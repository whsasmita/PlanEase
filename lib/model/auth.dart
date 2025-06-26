import 'package:intl/intl.dart';

class User {
  final int id;
  final String fullName;
  final String email;
  final String? emailVerifiedAt;
  final String? phone; 
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
      user:
          json['user'] != null
              ? User.fromJson(json['user'] as Map<String, dynamic>)
              : null,
      accessToken: json['access_token'] as String?,
      tokenType: json['token_type'] as String?,
      expiresIn: json['expires_in'] as int?,
    );
  }
}
