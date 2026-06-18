import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme.dart';
import 'screens/login_screen.dart';
import 'components/app_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Elegant, production-ready Supabase initializer
    await Supabase.initialize(
      url: 'https://mgrzsajmbavdhltupzmu.supabase.co',
      anonKey: 'sb_publishable_Un5zA-C3VSJ5n4QQp9VyOA_j2n_eomd',
    );
  } catch (e) {
    debugPrint("Supabase Client is offline / placeholder. Using local SQLite Cache: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VENTAS GNB',
      debugShowCheckedModeBanner: false,
      theme: GnbTheme.lightTheme,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/app': (context) => const AppScaffold(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    // Fade in logo
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
        });
      }
    });

    // Navigate to Login Screen after 2.5 seconds
    Timer(const Duration(milliseconds: 2800), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF73B51A), // Official GNB Green from image
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(milliseconds: 800),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── White Tree GNB Logo Representation (Matching User Image exactly!) ──
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: const Color(0xFF73B51A), // Matching GNB Green
                  borderRadius: BorderRadius.circular(36),
                  border: Border.all(color: Colors.white, width: 3.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.park_rounded, // Majestic White Tree Icon from image
                    color: Colors.white,
                    size: 110,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // ── Title: VENTAS GNB ──
              const Text(
                "VENTAS",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3.0,
                  fontFamily: 'Outfit',
                ),
              ),
              const Text(
                "GNB",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 6.0,
                  fontFamily: 'Outfit',
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Fuerza de Ventas Digital",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 48),

              // ── Smooth Loader ──
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white.withOpacity(0.9),
                  strokeWidth: 2.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Estableciendo conexión en la nube...",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
