class Notula {
  final int? id; // PERBAIKAN: Buat ID menjadi nullable
  final String title;
  final String description;
  final String content;

  Notula({
    this.id, // PERBAIKAN: Tidak lagi required di konstruktor
    required this.title,
    required this.description,
    required this.content,
  });

  factory Notula.fromJson(Map<String, dynamic> json) {
    return Notula(
      id: json['id'] as int?, // ID sekarang nullable, langsung ambil sebagai int?
      title: json['title'] as String? ?? 'No Title',
      description: json['description'] as String? ?? 'No Description',
      content: json['content'] as String? ?? 'No Content',
    );
  }
}

class User {
  final int id;
  final String fullName;
  final String email;
  final String role;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      // PERBAIKAN DI SINI: Gunakan 'as int? ?? 0' untuk menangani null atau nilai yang tidak ada
      id: json['id'] as int? ?? 0,
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
    );
  }
}

class LoginApiResponse {
  final String message;
  final User? user;
  final String? accessToken;
  final String? tokenType;
  final int? expiresIn; // Ini juga mungkin perlu penanganan null

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
      user: json['user'] != null ? User.fromJson(json['user'] as Map<String, dynamic>) : null,
      accessToken: json['access_token'] as String? ?? '',
      tokenType: json['token_type'] as String? ?? '',
      expiresIn: json['expires_in'] as int?,
    );
  }
}