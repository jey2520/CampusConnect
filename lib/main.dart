import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Note: Firebase.initializeApp() will be configured via flutterfire configure in production.
  // We wrap in a try-catch for standalone testing environments.
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase initialization skipped or already running: $e");
  }

  runApp(
    const ProviderScope(
      child: CampusConnectApp(),
    ),
  );
}

class CampusConnectApp extends ConsumerWidget {
  const CampusConnectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'CampusConnect',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light, // Configurable via preferences
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0x6C4CF700), // #6C4CF7
          primary: const Color(0xFF6C4CF7),
          secondary: const Color(0xFF8B7CFF),
          tertiary: const Color(0xFF00D4A6), // Accent
          background: const Color(0xFFF8F9FD),
          surface: Colors.white,
          error: const Color(0xFFFF5E36),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 2,
          shadowColor: const Color(0x6C4CF70F), // Soft purple shadow
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF1F2F6),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0x6C4CF700),
          primary: const Color(0xFF6C4CF7),
          secondary: const Color(0xFF8B7CFF),
          tertiary: const Color(0xFF00D4A6),
          background: const Color(0xFF101114),
          surface: const Color(0xFF17181D),
          error: const Color(0xFFFF5E36),
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF17181D),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1D1F26),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      routerConfig: router,
    );
  }
}
