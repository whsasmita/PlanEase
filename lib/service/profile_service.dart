import 'dart:convert';
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
}
