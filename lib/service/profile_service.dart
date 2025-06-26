// lib/service/profile_service.dart
import 'package:plan_ease/model/profile.dart';
import 'package:plan_ease/service/auth_service.dart';

class ProfileService {
  final AuthService _authService;

  ProfileService(this._authService);

  Future<Profile> getProfile(int userId) async {
    throw UnimplementedError('getProfile() has not been implemented yet.');
  }

  Future<Profile> updateProfile(Profile profile) async {
    throw UnimplementedError('updateProfile() has not been implemented yet.');
  }
}