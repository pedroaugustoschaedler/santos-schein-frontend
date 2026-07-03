import 'package:flutter/material.dart';
import 'core/di/injection_container.dart';
import 'features/auth/login_screen.dart';
import 'core/theme/app_theme.dart';

void main() {
  setupDependencies();
  runApp(const SantosApp());
}

class SantosApp extends StatelessWidget {
  const SantosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Santos e Schein',
      theme: AppTheme.darkTheme,
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
