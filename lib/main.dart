import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/themes/app_theme.dart';
import 'features/dashboard/presentation/pages/home_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: CraneProManagerApp(),
    ),
  );
}

class CraneProManagerApp extends StatelessWidget {
  const CraneProManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CranePro Manager',
      themeMode: ThemeMode.light,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
