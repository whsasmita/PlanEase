// services/polling_service.dart
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:plan_ease/model/polling.dart';
import 'package:plan_ease/service/auth_service.dart';

class PollingService {
  final AuthService _authService;

  PollingService(this._authService);

  // Mengambil daftar semua polling
  Future<List<Polling>> getPollings() async {
    try {
      final headers = await _authService.getAuthHeaders();
      final url = Uri.parse('${AuthService.apiBaseUrl}/polling');
      
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> pollingData = responseData['data'];
        return pollingData.map((json) => Polling.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load pollings: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to load pollings: $e');
    }
  }

  // Mengambil detail polling berdasarkan ID
  Future<Polling> getPollingDetails(int id) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final url = Uri.parse('${AuthService.apiBaseUrl}/polling/$id');

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return Polling.fromJson(responseData['data']);
      } else {
        throw Exception(
          'Failed to load polling details: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to load polling details: $e');
    }
  }

  // Membuat polling baru
  Future<Polling> createPolling(
    Map<String, dynamic> data, {
    File? imageFile,
  }) async {
    try {
      http.Response response;
      final headers = await _authService.getAuthHeaders();

      if (imageFile != null) {
        final url = Uri.parse('${AuthService.apiBaseUrl}/polling');
        final request = http.MultipartRequest('POST', url);
        headers.remove('Content-Type');
        request.headers.addAll(headers);

        // Tambahkan fields dari data yang diberikan
        data.forEach((key, value) {
          if (key == 'options' && value is List) {
            request.fields[key] = jsonEncode(value);
          } else {
            request.fields[key] = value.toString();
          }
        });

        request.files.add(await http.MultipartFile.fromPath(
          'polling_image',
          imageFile.path,
        ));

        final streamedResponse = await request.send();
        response = await http.Response.fromStream(streamedResponse);
      } else {
        final url = Uri.parse('${AuthService.apiBaseUrl}/polling');
        response = await http.post(url, headers: headers, body: jsonEncode(data));
      }

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return Polling.fromJson(responseData['data']);
      } else {
        throw Exception(
          'Failed to create polling: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to create polling: $e');
    }
  }

  // Memperbarui polling yang sudah ada
  Future<Polling> updatePolling(
    int id,
    Map<String, dynamic> data, {
    File? imageFile,
    List<int>? optionsToDelete,
  }) async {
    try {
      http.Response response;
      final headers = await _authService.getAuthHeaders();

      Map<String, dynamic> requestBody = Map.from(data);

      if (optionsToDelete != null && optionsToDelete.isNotEmpty) {
        requestBody['options_to_delete'] = optionsToDelete;
      }

      if (imageFile != null) {
        final url = Uri.parse('${AuthService.apiBaseUrl}/polling/$id');
        final request = http.MultipartRequest('POST', url);

        headers.remove('Content-Type');
        request.headers.addAll(headers);

        request.fields['_method'] = 'PUT'; 

        requestBody.forEach((key, value) {
          if (key == 'options' && value is List) {
            request.fields[key] = jsonEncode(value);
          } else if (key == 'options_to_delete' && value is List) {
            request.fields[key] = jsonEncode(value);
          } else {
            request.fields[key] = value.toString();
          }
        });

        request.files.add(await http.MultipartFile.fromPath(
          'polling_image',
          imageFile.path,
        ));

        final streamedResponse = await request.send();
        response = await http.Response.fromStream(streamedResponse);
      } else {
        final url = Uri.parse('${AuthService.apiBaseUrl}/polling/$id');
        response = await http.put(
          url,
          headers: headers,
          body: jsonEncode(requestBody),
        );
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return Polling.fromJson(responseData['data']);
      } else {
        throw Exception(
          'Failed to update polling: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to update polling: $e');
    }
  }

  // Menghapus polling
  Future<void> deletePolling(int id) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final url = Uri.parse('${AuthService.apiBaseUrl}/polling/$id');

      final response = await http.delete(url, headers: headers);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Failed to delete polling: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to delete polling: $e');
    }
  }

  // Memberikan suara pada polling
  Future<Map<String, dynamic>> votePolling(
    int pollingId,
    int pollingOptionId,
  ) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final url = Uri.parse('${AuthService.apiBaseUrl}/polling/$pollingId/vote');

      final response = await http.post(url, headers: headers, body: jsonEncode({
        'polling_id': pollingId,
        'polling_option_id': pollingOptionId,
      }));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'message': responseData['message']};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to cast vote',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Failed to cast vote: $e'};
    }
  }

  // Mengambil hasil polling
  Future<Map<String, dynamic>> getPollingResults(int id) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final url = Uri.parse('${AuthService.apiBaseUrl}/polling/$id/results');

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Failed to load polling results: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to load polling results: $e');
    }
  }

  // Menghapus gambar polling saja
  Future<void> deletePollingImage(int id) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final url = Uri.parse('${AuthService.apiBaseUrl}/polling/$id/image');

      final response = await http.delete(url, headers: headers);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Failed to delete polling image: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to delete polling image: $e');
    }
  }
}
