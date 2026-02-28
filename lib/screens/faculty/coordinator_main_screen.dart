import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'coordinator_monitoring_screen.dart';
import 'assign_guide_screen.dart';
import 'add_questionnaire_screen.dart';
import 'feedback_screen.dart';
import '../shared/profile_screen.dart';

class CoordinatorMainScreen extends StatefulWidget {
  const CoordinatorMainScreen({super.key});

  @override
  State<CoordinatorMainScreen> createState() => _CoordinatorMainScreenState();
}

class _CoordinatorMainScreenState extends State<CoordinatorMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const CoordinatorMonitoringScreen(),
    const AssignGuideScreen(),
    const AddQuestionnaireScreen(),
    const FeedbackScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AppTheme.primary,
            unselectedItemColor: AppTheme.textLight,
            showSelectedLabels: true,
            showUnselectedLabels: false,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.analytics_outlined),
                activeIcon: Icon(Icons.analytics_rounded),
                label: 'Stats',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people_outline),
                activeIcon: Icon(Icons.people_rounded),
                label: 'Guides',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.library_add_outlined),
                activeIcon: Icon(Icons.library_add_rounded),
                label: 'Quiz',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.reviews_outlined),
                activeIcon: Icon(Icons.reviews_rounded),
                label: 'Feedback',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_circle_outlined),
                activeIcon: Icon(Icons.account_circle_rounded),
                label: 'Me',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
