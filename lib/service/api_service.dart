// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plan_ease/model/model.dart'; // Import model.dart

class ApiService {
  final String _apiBaseUrl = 'http://10.0.2.2:8000/api'; // Pastikan ini URL yang benar

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

  Future<LoginApiResponse?> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$_apiBaseUrl/login');
    print('Mencoba login ke: $url');
    print('Data login: $email, $password');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      print('Login Status Code: ${response.statusCode}');
      print('Login Response Body: ${response.body}');

      if (response.statusCode == 404) {
        throw Exception('Endpoint login tidak ditemukan. Periksa URL API.');
      } else if (response.statusCode >= 500) {
        throw Exception('Server mengalami kesalahan internal. Coba lagi nanti.');
      }

      final responseBody = json.decode(response.body);
      final loginApiResponse = LoginApiResponse.fromJson(responseBody);

      if (response.statusCode == 200 && loginApiResponse.user != null && loginApiResponse.accessToken != null) {
        await _saveAuthData(loginApiResponse.accessToken!, loginApiResponse.user!.role);
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
          throw Exception('Gagal masuk. Kode Status: ${response.statusCode}. Silakan coba lagi.');
        }
      }
    } catch (e) {
      print('Error pada proses login (ApiService): $e');
      if (e is FormatException) {
        throw Exception('Kesalahan respons dari server (bukan format JSON yang valid).');
      }
      rethrow;
    }
  }

  Future<List<Notula>> getNotula() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token otentikasi tidak ditemukan. Harap login kembali.');
    }

    final url = Uri.parse('$_apiBaseUrl/notula');
    print('Mencoba mengambil notula dari: $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Get Notula Status Code: ${response.statusCode}');
      print('Get Notula Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        if (responseBody.containsKey('data') && responseBody['data'] is List) {
          List<dynamic> notulaJson = responseBody['data'];
          return notulaJson.map((json) => Notula.fromJson(json as Map<String, dynamic>)).toList();
        } else {
          // Fallback jika API langsung mengembalikan array (tidak disarankan)
          List<dynamic> notulaJson = json.decode(response.body);
          return notulaJson.map((json) => Notula.fromJson(json as Map<String, dynamic>)).toList();
        }
      } else if (response.statusCode == 401) {
        throw Exception('Sesi tidak valid atau kadaluarsa. Harap login kembali.');
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal mengambil notula. Kode Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error pada proses getNotula (ApiService): $e');
      if (e is FormatException) {
        throw Exception('Kesalahan respons dari server (bukan format JSON yang valid).');
      }
      rethrow;
    }
  }

  // --- NEW: Metode untuk menambahkan Notula ---
  Future<Notula> addNotula({
    required String title,
    required String description,
    required String content,
  }) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token otentikasi tidak ditemukan. Harap login kembali.');
    }

    final url = Uri.parse('$_apiBaseUrl/notula'); // Asumsi endpoint POST untuk menambah notula
    print('Mencoba menambahkan notula ke: $url');
    print('Data: title=$title, description=$description, content=$content');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Sertakan token otentikasi
        },
        body: json.encode({
          'title': title,
          'description': description,
          'content': content,
        }),
      );

      print('Add Notula Status Code: ${response.statusCode}');
      print('Add Notula Response Body: ${response.body}');

      if (response.statusCode == 201) { // Kode status 201 Created untuk sukses POST
        final Map<String, dynamic> responseBody = json.decode(response.body);
        // Asumsi API mengembalikan objek notula yang baru dibuat di bawah kunci 'data'
        if (responseBody.containsKey('data') && responseBody['data'] is Map) {
          return Notula.fromJson(responseBody['data'] as Map<String, dynamic>);
        } else {
          // Jika API langsung mengembalikan objek notula tanpa kunci 'data'
          return Notula.fromJson(responseBody);
        }
      } else if (response.statusCode == 401) {
        throw Exception('Sesi tidak valid atau kadaluarsa. Harap login kembali.');
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        String errorMessage = errorData['message'] ?? 'Gagal menambahkan notula. Kode Status: ${response.statusCode}';
        if (errorData.containsKey('errors')) { // Handle Laravel validation errors
          (errorData['errors'] as Map).forEach((key, value) {
            errorMessage += '\n${(value as List).join(', ')}';
          });
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error pada proses addNotula (ApiService): $e');
      if (e is FormatException) {
        throw Exception('Kesalahan respons dari server (bukan format JSON yang valid).');
      }
      rethrow;
    }
  }

  // Fungsi signup dan recoverPassword tetap seperti sebelumnya
  Future<String?> signup({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    final url = Uri.parse('$_apiBaseUrl/register');
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
        return null; // Pendaftaran Sukses
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
      print('Error pada proses daftar: $e');
      if (e is FormatException) {
        return 'Kesalahan respons dari server (bukan format JSON yang valid).';
      }
      return 'Terjadi kesalahan jaringan atau server. Silakan coba lagi.';
    }
  }

  Future<String?> recoverPassword(String email) async {
    final url = Uri.parse('$_apiBaseUrl/forgot-password');
    print('Mencoba pulihkan password untuk: $email');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
        }),
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
      print('Error pada proses pemulihan password: $e');
      if (e is FormatException) {
        return 'Kesalahan respons dari server (bukan format JSON yang valid).';
      }
      return 'Terjadi kesalahan jaringan atau server. Silakan coba lagi.';
    }
  }
}