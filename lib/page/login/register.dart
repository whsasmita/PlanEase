import 'package:flutter/material.dart';
import 'package:plan_ease/widget/login/register.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E8C7A),
      body: const Center(
        child: RegisterForm(),
      ),
    );
  }
}
