import 'package:flutter/material.dart';
import 'package:plan_ease/widget/login/splashscreen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E8C7A),
      body: Center(
        child: SplashScreen(), // Tanpa 'const'
      ),
    );
  }
}
