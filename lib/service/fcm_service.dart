import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:plan_ease/service/auth_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FCMService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? _fcmToken;
  final AuthService _authService;

  FCMService(this._authService);

  Future<void> initialize() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    _fcmToken = await _firebaseMessaging.getToken();
    print("FCM Token: $_fcmToken");

    // <<< PENTING: Panggilan sendFcmTokenToBackend() DIHAPUS dari sini
    // Karena akan dipanggil secara eksternal setelah login berhasil.

    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      print("FCM Token Refreshed: $_fcmToken");
      // Kirim token yang diperbarui ke backend agar selalu up-to-date
      // Panggil sendFcmTokenToBackend() hanya jika pengguna sudah login
      _authService.getToken().then((token) {
        if (token != null) {
          sendFcmTokenToBackend();
        }
      });
    });
  }

  String? getFcmToken() {
    return _fcmToken;
  }

  Future<void> sendFcmTokenToBackend() async {
    final jwtToken = await _authService.getToken();
    if (_fcmToken == null || jwtToken == null) {
      print("Tidak dapat mengirim FCM token: Token FCM atau JWT tidak tersedia.");
      return;
    }

    final url = Uri.parse('${AuthService.apiBaseUrl}/fcm-token');
    final headers = await _authService.getAuthHeaders();
    headers['Content-Type'] = 'application/json';

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({'fcm_token': _fcmToken}),
      );

      if (response.statusCode == 200) {
        print('FCM Token berhasil dikirim ke backend.');
      } else {
        print('Gagal mengirim FCM Token ke backend: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error mengirim FCM Token ke backend: $e');
    }
  }

  Future<void> deleteFcmTokenFromBackend() async {
    final jwtToken = await _authService.getToken();
    if (_fcmToken == null || jwtToken == null) {
      print("Tidak ada FCM token atau JWT untuk dihapus.");
      return;
    }

    final url = Uri.parse('${AuthService.apiBaseUrl}/fcm-token');
    final headers = await _authService.getAuthHeaders();
    headers['Content-Type'] = 'application/json';

    try {
      final response = await http.delete(
        url,
        headers: headers,
        body: jsonEncode({'fcm_token': _fcmToken}),
      );

      if (response.statusCode == 200) {
        print('FCM Token berhasil dihapus dari backend.');
      } else {
        print('Gagal menghapus FCM Token dari backend: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error menghapus FCM Token dari backend: $e');
    }
  }
}