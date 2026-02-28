import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'providers/admin_provider.dart';
import 'providers/coordinator_provider.dart';
import 'providers/guide_provider.dart';
import 'providers/student_provider.dart';
import 'providers/shared_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SkilloryApp());
}

class SkilloryApp extends StatelessWidget {
  const SkilloryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AdminProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CoordinatorProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => GuideProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => StudentProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SharedProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Skillory',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const OnboardingScreen(),
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
      backgroundColor: AppTheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.school_rounded, size: 100, color: Colors.white),
            SizedBox(height: 24),
            Text(
              'Skillory',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -1,
              ),
            ),
            SizedBox(height: 8),
            const Text(
              'Perfect Project Partners',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
