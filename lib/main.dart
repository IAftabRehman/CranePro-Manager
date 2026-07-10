import 'package:extend_crane_services/features/auth/presentation/pages/splash_screen_page.dart';
import 'package:extend_crane_services/features/ota/presentation/widgets/ota_update_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/themes/app_theme.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );


    // Pass all uncaught "fatal" errors from the framework to Crashlytics
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (e, stack) {
    debugPrint("App initialization error: $e");
    try {
      FirebaseCrashlytics.instance.recordError(e, stack, fatal: true);
    } catch (_) {}
  }

  runApp(const ProviderScope(child: CraneProManagerApp()));
}

class CraneProManagerApp extends StatelessWidget {
  const CraneProManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CranePro Manager',
      themeMode: ThemeMode.light,
      theme: AppTheme.lightTheme,
      home: const OtaUpdateGate(
        child: SplashScreenPage(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
