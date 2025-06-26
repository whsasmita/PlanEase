import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:plan_ease/model/schedule.dart';
import 'package:plan_ease/service/auth_service.dart'; 

class ScheduleService {
  final AuthService _authService; 

  ScheduleService(this._authService);

  Future<List<Schedule>> getSchedules() async {
    final headers = await _authService.getAuthHeaders();
    final url = Uri.parse('${AuthService.apiBaseUrl}/schedule');
    print('Mencoba mengambil schedules dari: $url');

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        if (responseBody.containsKey('data') && responseBody['data'] is List) {
          List<dynamic> schedulesJson = responseBody['data'];
          return schedulesJson
              .map((json) => Schedule.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          List<dynamic> schedulesJson = json.decode(response.body);
          return schedulesJson
              .map((json) => Schedule.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      } else if (response.statusCode == 401) {
        throw Exception(
          'Sesi tidak valid atau kadaluarsa. Harap login kembali.',
        );
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Gagal mengambil schedules. Kode Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error pada proses getSchedules (ScheduleService): $e');
      if (e is FormatException) {
        throw Exception(
          'Kesalahan respons dari server (bukan format JSON yang valid).',
        );
      }
      rethrow;
    }
  }

  Future<Schedule> addSchedule(Schedule schedule) async {
    final headers = await _authService.getAuthHeaders();
    final url = Uri.parse('${AuthService.apiBaseUrl}/schedule');
    print('Mencoba menambahkan schedule ke: $url');
    print('Data: ${json.encode(schedule.toJson())}');

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(schedule.toJson()),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        if (responseBody.containsKey('data') && responseBody['data'] is Map) {
          return Schedule.fromJson(responseBody['data'] as Map<String, dynamic>);
        } else {
          return Schedule.fromJson(responseBody);
        }
      } else if (response.statusCode == 401) {
        throw Exception(
          'Sesi tidak valid atau kadaluarsa. Harap login kembali.',
        );
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        String errorMessage =
            errorData['message'] ?? 'Gagal menambahkan schedule. Kode Status: ${response.statusCode}';
        if (errorData.containsKey('errors')) {
          (errorData['errors'] as Map).forEach((key, value) {
            errorMessage += '\n${(value as List).join(', ')}';
          });
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error pada proses addSchedule (ScheduleService): $e');
      if (e is FormatException) {
        throw Exception(
          'Kesalahan respons dari server (bukan format JSON yang valid).',
        );
      }
      rethrow;
    }
  }

  Future<Schedule> updateSchedule(Schedule schedule) async {
    if (schedule.id == null || schedule.id! <= 0) {
      print('Error: Attempted to update schedule with invalid ID: ${schedule.id}');
      throw Exception('ID Schedule tidak valid untuk operasi pembaruan.');
    }

    final headers = await _authService.getAuthHeaders();
    final url = Uri.parse('${AuthService.apiBaseUrl}/schedule/${schedule.id}');
    print('Mencoba memperbarui schedule di: $url');
    print('Data yang dikirim untuk update: ${json.encode(schedule.toJson())}');

    try {
      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(schedule.toJson()),
      );

      print('Update Schedule Status Code: ${response.statusCode}');
      print('Update Schedule Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        if (responseBody.containsKey('data') && responseBody['data'] is Map) {
          return Schedule.fromJson(responseBody['data'] as Map<String, dynamic>);
        } else {
          return Schedule.fromJson(responseBody);
        }
      } else if (response.statusCode == 401) {
        throw Exception(
          'Sesi tidak valid atau kadaluarsa. Harap login kembali.',
        );
      } else if (response.statusCode == 404) {
        throw Exception(
          'Schedule tidak ditemukan atau endpoint salah. Kode Status: ${response.statusCode}',
        );
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        String errorMessage =
            errorData['message'] ?? 'Gagal memperbarui schedule. Kode Status: ${response.statusCode}';
        if (errorData.containsKey('errors')) {
          (errorData['errors'] as Map).forEach((key, value) {
            errorMessage += '\n${(value as List).join(', ')}';
          });
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error pada proses updateSchedule (ScheduleService): $e');
      if (e is FormatException) {
        throw Exception(
          'Kesalahan respons dari server (bukan format JSON yang valid).',
        );
      }
      rethrow;
    }
  }

  Future<void> deleteSchedule(int? scheduleId) async {
    if (scheduleId == null || scheduleId <= 0) {
      print('Error: Attempted to delete schedule with invalid ID: $scheduleId');
      throw Exception('ID Schedule tidak valid untuk operasi penghapusan.');
    }

    final headers = await _authService.getAuthHeaders();
    final url = Uri.parse('${AuthService.apiBaseUrl}/schedule/$scheduleId');
    print('Mencoba menghapus schedule dengan ID: $scheduleId dari: $url');

    try {
      final response = await http.delete(url, headers: headers);

      print('Delete Schedule Status Code: ${response.statusCode}');
      print('Delete Schedule Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isNotEmpty) {
          try {
            final responseBody = json.decode(response.body);
            if (responseBody.containsKey('message') &&
                responseBody['message'] == 'Schedule deleted successfully') {
              return;
            } else {
              throw Exception(
                'Respons sukses yang tidak diharapkan: ${response.body}',
              );
            }
          } on FormatException {
            print('Peringatan: Respons sukses tidak berformat JSON. Menganggap berhasil.');
            return;
          }
        } else {
          print('Schedule berhasil dihapus (No Content).');
          return;
        }
      } else if (response.statusCode == 401) {
        throw Exception(
          'Sesi tidak valid atau kadaluarsa. Harap login kembali.',
        );
      } else if (response.statusCode == 404) {
        throw Exception(
          'Schedule tidak ditemukan atau endpoint salah. Kode Status: ${response.statusCode}',
        );
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Gagal menghapus schedule. Kode Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error pada proses deleteSchedule (ScheduleService): $e');
      if (e is FormatException) {
        throw Exception(
          'Kesalahan respons dari server (bukan format JSON yang valid): ${e.toString()}',
        );
      }
      rethrow;
    }
  }

  Future<Schedule> getScheduleById(int scheduleId) async {
    final headers = await _authService.getAuthHeaders();
    final url = Uri.parse('${AuthService.apiBaseUrl}/schedule/$scheduleId');
    print('Mencoba mengambil schedule dengan ID: $scheduleId dari: $url');

    try {
      final response = await http.get(url, headers: headers);
      print('Get Schedule By ID Status Code: ${response.statusCode}');
      print('Get Schedule By ID Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        if (responseBody.containsKey('data') && responseBody['data'] is Map) {
          return Schedule.fromJson(responseBody['data'] as Map<String, dynamic>);
        } else {
          return Schedule.fromJson(responseBody);
        }
      } else if (response.statusCode == 401) {
        throw Exception(
          'Sesi tidak valid atau kadaluarsa. Harap login kembali.',
        );
      } else if (response.statusCode == 404) {
        throw Exception(
          'Schedule tidak ditemukan. Kode Status: ${response.statusCode}',
        );
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Gagal mengambil schedule. Kode Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error pada proses getScheduleById (ScheduleService): $e');
      if (e is FormatException) {
        throw Exception(
          'Kesalahan respons dari server (bukan format JSON yang valid).',
        );
      }
      rethrow;
    }
  }
}