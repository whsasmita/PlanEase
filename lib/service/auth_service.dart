import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plan_ease/model/auth.dart';
import 'package:plan_ease/model/profile.dart';
import 'package:plan_ease/model/notula.dart';
import 'package:plan_ease/model/schedule.dart';
import 'package:plan_ease/model/polling.dart';


class AuthService {
  static const String apiBaseUrl = 'http://10.0.2.2:8000/api';

  Future<void> _saveAuthData(String token, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
    await prefs.setString('userRole', role);
    await prefs.setBool('is_logged_in', true);
    print('Token disimpan: $token');
    print('Role disimpan: $role');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userRole');
  }

  Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    await prefs.remove('userRole');
    await prefs.setBool('is_logged_in', false);
    print('Data otentikasi dihapus.');
  }

  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token otentikasi tidak ditemukan. Harap login kembali.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<LoginApiResponse?> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$apiBaseUrl/login');
    print('Mencoba login ke: $url');
    print('Data login: $email, $password');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      print('Login Status Code: ${response.statusCode}');
      print('Login Response Body: ${response.body}');

      if (response.statusCode == 404) {
        throw Exception('Endpoint login tidak ditemukan. Periksa URL API.');
      } else if (response.statusCode >= 500) {
        throw Exception(
          'Server mengalami kesalahan internal. Coba lagi nanti.',
        );
      }

      final responseBody = json.decode(response.body);
      final loginApiResponse = LoginApiResponse.fromJson(responseBody);

      if (response.statusCode == 200 &&
          loginApiResponse.user != null &&
          loginApiResponse.accessToken != null) {
        await _saveAuthData(
          loginApiResponse.accessToken!,
          loginApiResponse.user!.role,
        );
        return loginApiResponse;
      } else {
        if (responseBody.containsKey('errors')) {
          String errorMessage = '';
          (responseBody['errors'] as Map).forEach((key, value) {
            errorMessage += (value as List).join('\n') + '\n';
          });
          throw Exception(errorMessage.trim());
        } else if (loginApiResponse.message.isNotEmpty) {
          throw Exception(loginApiResponse.message);
        } else {
          throw Exception(
            'Gagal masuk. Kode Status: ${response.statusCode}. Silakan coba lagi.',
          );
        }
      }
    } catch (e) {
      print('Error pada proses login (AuthService): $e');
      if (e is FormatException) {
        throw Exception(
          'Kesalahan respons dari server (bukan format JSON yang valid).',
        );
      }
      rethrow;
    }
  }

  Future<String?> signup({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    // PERBAIKAN: Gunakan apiBaseUrl yang static
    final url = Uri.parse('$apiBaseUrl/register');
    print('Mencoba daftar ke: $url');
    print('Data daftar: $fullName, $email, $phone, $password, $passwordConfirmation');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'full_name': fullName,
          'email': email,
          'phone': phone,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      print('Daftar Status Code: ${response.statusCode}');
      print('Daftar Response Body: ${response.body}');

      if (response.statusCode == 404) {
        return 'Endpoint pendaftaran tidak ditemukan. Periksa URL API.';
      } else if (response.statusCode >= 500) {
        return 'Server mengalami kesalahan internal. Coba lagi nanti.';
      }

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return null; 
      } else {
        if (responseBody.containsKey('errors')) {
          String errorMessage = '';
          (responseBody['errors'] as Map).forEach((key, value) {
            errorMessage += (value as List).join('\n') + '\n';
          });
          return errorMessage.trim();
        } else if (responseBody.containsKey('message')) {
          return responseBody['message'];
        } else {
          return 'Gagal mendaftar. Kode Status: ${response.statusCode}. Silakan coba lagi.';
        }
      }
    } catch (e) {
      print('Error pada proses daftar (AuthService): $e');
      if (e is FormatException) {
        return 'Kesalahan respons dari server (bukan format JSON yang valid).';
      }
      return 'Terjadi kesalahan jaringan atau server. Silakan coba lagi.';
    }
  }

  Future<String?> recoverPassword(String email) async {
    // PERBAIKAN: Gunakan apiBaseUrl yang static
    final url = Uri.parse('$apiBaseUrl/forgot-password');
    print('Mencoba pulihkan password untuk: $email');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      print('Pulihkan Password Status Code: ${response.statusCode}');
      print('Pulihkan Password Response Body: ${response.body}');

      if (response.statusCode == 404) {
        return 'Endpoint pemulihan password tidak ditemukan. Periksa URL API.';
      } else if (response.statusCode >= 500) {
        return 'Server mengalami kesalahan internal. Coba lagi nanti.';
      }

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseBody.containsKey('message')) {
          return responseBody['message'];
        }
        return 'Link reset password telah dikirim ke email Anda.';
      } else {
        if (responseBody.containsKey('errors')) {
          String errorMessage = '';
          (responseBody['errors'] as Map).forEach((key, value) {
            errorMessage += (value as List).join('\n') + '\n';
          });
          return errorMessage.trim();
        } else if (responseBody.containsKey('message')) {
          return responseBody['message'];
        } else {
          return 'Gagal memulihkan password. Kode Status: ${response.statusCode}. Silakan coba lagi.';
        }
      }
    } catch (e) {
      print('Error pada proses pemulihan password (AuthService): $e');
      if (e is FormatException) {
        return 'Kesalahan respons dari server (bukan format JSON yang valid).';
      }
      return 'Terjadi kesalahan jaringan atau server. Silakan coba lagi.';
    }
  }
}