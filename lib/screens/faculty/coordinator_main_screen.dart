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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.surface,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.textLight,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor_outlined),
            activeIcon: Icon(Icons.monitor),
            label: 'Monitoring',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_ind_outlined),
            activeIcon: Icon(Icons.assignment_ind),
            label: 'Assign Guide',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz_outlined),
            activeIcon: Icon(Icons.quiz),
            label: 'Add Q',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback_outlined),
            activeIcon: Icon(Icons.feedback),
            label: 'Feedback',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
