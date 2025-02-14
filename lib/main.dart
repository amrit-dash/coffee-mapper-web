import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:coffee_mapper_web/services/maps_service.dart';
import 'package:logging/logging.dart';
import 'package:coffee_mapper_web/config/firebase_config.dart';

// import 'firebase_options.dart';  // We'll use our new config instead
import 'package:coffee_mapper_web/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: FirebaseConfig.currentConfig,
  );

  // Initialize logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  // Initialize Google Maps
  await MapsService.initialize();

  runApp(
    const ProviderScope(
      child: CoffeeMapperWebApp(),
    ),
  );
}

class CoffeeMapperWebApp extends StatelessWidget {
  const CoffeeMapperWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFFc09366),
        scaffoldBackgroundColor: const Color(0xFFD5B799),
        cardColor: const Color(0xFFEADCC8),
        dialogBackgroundColor: const Color(0xFFFAEEE6),
        unselectedWidgetColor: const Color(0xff402200),
        highlightColor: const Color(0xFF632D00),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFc09366),
          primary: const Color(0xFFc09366),
          secondary: const Color(0xFF964600),
          error: const Color(0xFF1e0f00),
          surface: const Color(0xFFEDE2D6),
          tertiary: const Color(0xFFF4EEEA),
          secondaryContainer: const Color(0xFFB0875E),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: 'Gilroy-Medium'),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFc09366),
            textStyle: const TextStyle(
              fontFamily: 'Gilroy-SemiBold',
            ),
          ),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          // Always return DashboardScreen, auth state will be handled within
          return const DashboardScreen();
        }
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
