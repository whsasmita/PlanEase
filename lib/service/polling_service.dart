import 'package:plan_ease/model/polling.dart';
import 'package:plan_ease/service/auth_service.dart';

class PollingService {
  final AuthService _authService;

  PollingService(this._authService);

  Future<List<Polling>> getPollings() async {
    // Implementasi API call untuk mengambil polling
    throw UnimplementedError('getPollings() has not been implemented yet.');
  }

  // Placeholder method for adding a vote
  Future<void> addVote(PollingVote vote) async {
    throw UnimplementedError('addVote() has not been implemented yet.');
  }
}