// lib/service/profile_service.dart
import 'package:plan_ease/model/profile.dart';
import 'package:plan_ease/service/auth_service.dart';

class ProfileService {
  final String _apiBaseUrl = 'http://10.0.2.2:8000/api';
  final AuthService _authService;

  ProfileService(this._authService);

  // Placeholder method for getting user profile
  Future<Profile> getProfile(int userId) async {
    // Implementasi API call untuk mengambil profil
    // final headers = await _authService.getAuthHeaders();
    // final url = Uri.parse('$_apiBaseUrl/profile/$userId');
    // ...
    throw UnimplementedError('getProfile() has not been implemented yet.');
  }

  // Placeholder method for updating user profile
  Future<Profile> updateProfile(Profile profile) async {
    // Implementasi API call untuk memperbarui profil
    throw UnimplementedError('updateProfile() has not been implemented yet.');
  }
}