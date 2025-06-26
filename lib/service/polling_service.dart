// lib/service/polling_service.dart
import 'package:plan_ease/model/polling.dart';
import 'package:plan_ease/service/auth_service.dart';

class PollingService {
  final String _apiBaseUrl = 'http://10.0.2.2:8000/api';
  final AuthService _authService;

  PollingService(this._authService);

  // Placeholder method for getting pollings
  Future<List<Polling>> getPollings() async {
    // Implementasi API call untuk mengambil polling
    throw UnimplementedError('getPollings() has not been implemented yet.');
  }

  // Placeholder method for adding a vote
  Future<void> addVote(PollingVote vote) async {
    // Implementasi API call untuk menambahkan vote
    throw UnimplementedError('addVote() has not been implemented yet.');
  }
}