import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const SapuLidiApp());
}

class SapuLidiApp extends StatelessWidget {
  const SapuLidiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SapuLidi SuperApp RT',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const OnboardingPage(),
    );
  }
}
