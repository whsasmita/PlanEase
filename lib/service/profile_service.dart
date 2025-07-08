import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:plan_ease/model/profile.dart';
import 'package:plan_ease/service/auth_service.dart';

class ProfileService {
  final AuthService _authService;

  ProfileService(this._authService);

  Future<Profile> getProfileUser(int profileId) async {
    if (profileId <= 0) {
      print('Error: Attempted to get profile with invalid ID: $profileId');
      throw Exception('ID Profile tidak valid untuk operasi pengambilan.');
    }

    try {
      final headers = await _authService.getAuthHeaders();
      final url = Uri.parse('${AuthService.apiBaseUrl}/profile/$profileId');

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey('profile') && responseData['profile'] != null) {
          return Profile.fromJson(responseData['profile'] as Map<String, dynamic>);
        } else {
          throw Exception('Data profil tidak ditemukan dalam respons.');
        }
      } else {
        print('Gagal mengambil profil. Status Code: ${response.statusCode}');
        print('Respons Body: ${response.body}');
        throw Exception('Gagal mengambil profil. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Terjadi kesalahan saat mengambil profil: $e');
      throw Exception('Terjadi kesalahan saat mengambil profil: $e');
    }
  }

  Future<bool> updateProfilePhoto({
    required int profileId,
    required File imageFile,
  }) async {
    if (profileId <= 0) {
      print('Error: Attempted to update profile with invalid ID: $profileId');
      throw Exception('ID Profile tidak valid untuk operasi update.');
    }

    try {
      final headers = await _authService.getAuthHeaders();
      // IMPORTANT: Change URL to the main profile update endpoint
      final url = Uri.parse('${AuthService.apiBaseUrl}/profile/$profileId');

      // Create multipart request
      final request = http.MultipartRequest('POST', url); // Use POST for multipart, Laravel will handle PUT via _method
      
      // Add headers
      request.headers.addAll(headers);

      // Add _method field for PUT request in Laravel
      request.fields['_method'] = 'PUT';

      // Add image file
      final imageStream = http.ByteStream(imageFile.openRead());
      final imageLength = await imageFile.length();
      final multipartFile = http.MultipartFile(
        'photo_profile', // Sesuaikan dengan field name di API
        imageStream,
        imageLength,
        filename: 'profile_${profileId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      
      request.files.add(multipartFile);

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        print('Foto profil berhasil diupdate');
        return true;
      } else {
        print('Gagal mengupdate foto profil. Status Code: ${response.statusCode}');
        print('Respons Body: ${response.body}');
        throw Exception('Gagal mengupdate foto profil. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Terjadi kesalahan saat mengupdate foto profil: $e');
      throw Exception('Terjadi kesalahan saat mengupdate foto profil: $e');
    }
  }

  Future<Profile> updateProfile({
    required int profileId,
    String? fullName,
    String? phone,
    String? division,
    String? position, // NEW: Add position parameter
  }) async {
    if (profileId <= 0) {
      print('Error: Attempted to update profile with invalid ID: $profileId');
      throw Exception('ID Profile tidak valid untuk operasi update.');
    }

    try {
      final headers = await _authService.getAuthHeaders();
      final url = Uri.parse('${AuthService.apiBaseUrl}/profile/$profileId');

      final Map<String, dynamic> body = {};
      
      if (fullName != null) body['full_name'] = fullName;
      if (phone != null) body['phone'] = phone;
      if (division != null) body['division'] = division;
      if (position != null) body['position'] = position; // NEW: Add position to body

      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey('profile') && responseData['profile'] != null) {
          return Profile.fromJson(responseData['profile'] as Map<String, dynamic>);
        } else {
          throw Exception('Data profil tidak ditemukan dalam respons.');
        }
      } else {
        print('Gagal mengupdate profil. Status Code: ${response.statusCode}');
        print('Respons Body: ${response.body}');
        throw Exception('Gagal mengupdate profil. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Terjadi kesalahan saat mengupdate profil: $e');
      throw Exception('Terjadi kesalahan saat mengupdate profil: $e');
    }
  }

  Future<bool> deleteProfilePhoto(int profileId) async {
    if (profileId <= 0) {
      print('Error: Attempted to delete profile photo with invalid ID: $profileId');
      throw Exception('ID Profile tidak valid untuk operasi hapus foto.');
    }

    try {
      final headers = await _authService.getAuthHeaders();
      final url = Uri.parse('${AuthService.apiBaseUrl}/profile/$profileId/photo'); // This endpoint doesn't exist for DELETE either

      final response = await http.delete(url, headers: headers);

      if (response.statusCode == 200) {
        print('Foto profil berhasil dihapus');
        return true;
      } else {
        print('Gagal menghapus foto profil. Status Code: ${response.statusCode}');
        print('Respons Body: ${response.body}');
        throw Exception('Gagal menghapus foto profil. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Terjadi kesalahan saat menghapus foto profil: $e');
      throw Exception('Terjadi kesalahan saat menghapus foto profil: $e');
    }
  }
}
