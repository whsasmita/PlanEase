// lib/service/notula_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:plan_ease/model/notula.dart';
import 'package:plan_ease/service/auth_service.dart';

class NotulaService {
  final AuthService _authService;

  NotulaService(this._authService);

  Future<List<Notula>> getNotula() async {
    final headers = await _authService.getAuthHeaders();
    final url = Uri.parse('${AuthService.apiBaseUrl}/notula');
    print('Mencoba mengambil notula dari: $url');

    try {
      final response = await http.get(url, headers: headers);
      print('Get Notula Status Code: ${response.statusCode}');
      print('Get Notula Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        if (responseBody.containsKey('data') && responseBody['data'] is List) {
          List<dynamic> notulaJson = responseBody['data'];
          return notulaJson
              .map((json) => Notula.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          List<dynamic> notulaJson = json.decode(response.body);
          return notulaJson
              .map((json) => Notula.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      } else if (response.statusCode == 401) {
        throw Exception(
          'Sesi tidak valid atau kadaluarsa. Harap login kembali.',
        );
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Gagal mengambil notula. Kode Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error pada proses getNotula (NotulaService): $e');
      if (e is FormatException) {
        throw Exception(
          'Kesalahan respons dari server (bukan format JSON yang valid).',
        );
      }
      rethrow;
    }
  }

  Future<Notula> addNotula(Notula notula) async {
    final headers = await _authService.getAuthHeaders();
    final url = Uri.parse('${AuthService.apiBaseUrl}/notula');
    print('Mencoba menambahkan notula ke: $url');
    print('Data: ${json.encode(notula.toJson())}');

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(notula.toJson()),
      );

      print('Add Notula Status Code: ${response.statusCode}');
      print('Add Notula Response Body: ${response.body}');

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        if (responseBody.containsKey('data') && responseBody['data'] is Map) {
          return Notula.fromJson(responseBody['data'] as Map<String, dynamic>);
        } else {
          return Notula.fromJson(responseBody);
        }
      } else if (response.statusCode == 401) {
        throw Exception(
          'Sesi tidak valid atau kadaluarsa. Harap login kembali.',
        );
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        String errorMessage =
            errorData['message'] ?? 'Gagal menambahkan notula. Kode Status: ${response.statusCode}';
        if (errorData.containsKey('errors')) {
          (errorData['errors'] as Map).forEach((key, value) {
            errorMessage += '\n${(value as List).join(', ')}';
          });
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error pada proses addNotula (NotulaService): $e');
      if (e is FormatException) {
        throw Exception(
          'Kesalahan respons dari server (bukan format JSON yang valid).',
        );
      }
      rethrow;
    }
  }

  Future<Notula> updateNotula(Notula notula) async {
    if (notula.id == null || notula.id!.isEmpty) {
      throw Exception('ID Notula diperlukan untuk operasi pembaruan.');
    }
    final headers = await _authService.getAuthHeaders();
    final url = Uri.parse('${AuthService.apiBaseUrl}/notula/${notula.id}');
    print('Mencoba memperbarui notula di: $url');
    print('Data: ${json.encode(notula.toJson())}');

    try {
      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(notula.toJson()),
      );

      print('Update Notula Status Code: ${response.statusCode}');
      print('Update Notula Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        if (responseBody.containsKey('data') && responseBody['data'] is Map) {
          return Notula.fromJson(responseBody['data'] as Map<String, dynamic>);
        } else {
          return Notula.fromJson(responseBody);
        }
      } else if (response.statusCode == 401) {
        throw Exception(
          'Sesi tidak valid atau kadaluarsa. Harap login kembali.',
        );
      } else if (response.statusCode == 404) {
        throw Exception(
          'Notula tidak ditemukan atau endpoint salah. Kode Status: ${response.statusCode}',
        );
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        String errorMessage =
            errorData['message'] ?? 'Gagal memperbarui notula. Kode Status: ${response.statusCode}';
        if (errorData.containsKey('errors')) {
          (errorData['errors'] as Map).forEach((key, value) {
            errorMessage += '\n${(value as List).join(', ')}';
          });
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error pada proses updateNotula (NotulaService): $e');
      if (e is FormatException) {
        throw Exception(
          'Kesalahan respons dari server (bukan format JSON yang valid).',
        );
      }
      rethrow;
    }
  }

  Future<void> deleteNotula(String notulaId) async {
    final headers = await _authService.getAuthHeaders();
    final url = Uri.parse('${AuthService.apiBaseUrl}/notula/$notulaId');
    print('Mencoba menghapus notula dengan ID: $notulaId dari: $url');

    try {
      final response = await http.delete(url, headers: headers);

      print('Delete Notula Status Code: ${response.statusCode}');
      print('Delete Notula Response Body: ${response.body}');

      if (response.statusCode == 204) {
        return;
      } else if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody.containsKey('message') &&
            responseBody['message'] == 'Notula deleted successfully') {
          return;
        } else {
          throw Exception(
            responseBody['message'] ?? 'Respons 200 OK yang tidak diharapkan.',
          );
        }
      } else if (response.statusCode == 401) {
        throw Exception(
          'Sesi tidak valid atau kadaluarsa. Harap login kembali.',
        );
      } else if (response.statusCode == 404) {
        throw Exception(
          'Notula tidak ditemukan atau endpoint salah. Kode Status: ${response.statusCode}',
        );
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Gagal menghapus notula. Kode Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error pada proses deleteNotula (NotulaService): $e');
      if (e is FormatException) {
        throw Exception(
          'Kesalahan respons dari server (bukan format JSON yang valid).',
        );
      }
      rethrow;
    }
  }
}