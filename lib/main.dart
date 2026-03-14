import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'providers/admin_provider.dart';
import 'providers/coordinator_provider.dart';
import 'providers/guide_provider.dart';
import 'providers/student_provider.dart';
import 'providers/shared_provider.dart';
import 'providers/activity_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Custom error reporting for release builds to find "Grey Screens"
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              const Text('An error occurred in the UI:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(details.exception.toString(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              Text(details.stack?.toString() ?? 'No stack trace available', style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  };

  try {
    debugPrint("Initializing Firebase...");
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint("Firebase initialized with currentPlatform options.");
    } else {
      debugPrint("Firebase already initialized (apps not empty).");
    }
  } catch (e) {
    debugPrint("First Firebase initialization attempt failed: $e");
    // Fallback: บางครั้งบน Android การใช้ options อาจจะติดปัญหาถ้ามีการประกาศใน native
    if (Firebase.apps.isEmpty) {
      try {
        debugPrint("Attempting secondary Firebase initialization without options...");
        await Firebase.initializeApp();
        debugPrint("Firebase initialized secondary attempt.");
      } catch (innerE) {
        debugPrint("Secondary Firebase initialization failed: $innerE");
      }
    }
  }

  if (Firebase.apps.isEmpty) {
    debugPrint("CRITICAL: Firebase apps list is STILL EMPTY after initialization attempts!");
  } else {
    debugPrint("Firebase apps initialized: ${Firebase.apps.length}");
  }

  runApp(const SkilloryApp());
}

class SkilloryApp extends StatelessWidget {
  const SkilloryApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (Firebase.apps.isEmpty) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 80),
                const SizedBox(height: 24),
                const Text(
                  'Firebase Initialization Failed',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'The application could not connect to Firebase services. This may be due to improper configuration or missing internet access.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    main(); // Attempt to restart the app flow
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => CoordinatorProvider()),
        ChangeNotifierProvider(create: (_) => GuideProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => SharedProvider()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: 'Skillory',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: const OnboardingScreen(),
          );
        },
      ),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icon/logo.png',
              height: 180,
              // Color should be preserved from asset, but let's make sure it's centered
            ),
            const SizedBox(height: 16),
            const Text(
              'FIND YOUR FIT',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textLight,
                letterSpacing: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
