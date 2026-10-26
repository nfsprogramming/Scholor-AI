import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'theme.dart';
import 'screens/splash_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'services/app_state.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint("Firebase init failed: $e");
      // Optionally report to a crash reporting service here
      // For example: FirebaseCrashlytics.instance.recordError(e, st);
    }
    
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Text(
              "CRITICAL ERROR:\n\n${details.exception}\n\n${details.stack}",
              style: const TextStyle(color: Colors.red, fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
      );
    };
    
    runApp(const AiTutorApp());
  }, (error, stackTrace) {
    debugPrint("GLOBAL CRASH: $error");
    debugPrint(stackTrace.toString());
    // Optionally report to a crash reporting service here
    // For example: FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}

class AiTutorApp extends StatelessWidget {
  const AiTutorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scholor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
