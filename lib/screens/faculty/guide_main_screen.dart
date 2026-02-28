import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'guide_monitoring_screen.dart';
import 'guide_view_files_screen.dart';
import '../shared/chat_list_screen.dart';
import 'feedback_screen.dart';
import '../shared/profile_screen.dart';

class GuideMainScreen extends StatefulWidget {
  const GuideMainScreen({super.key});

  @override
  State<GuideMainScreen> createState() => _GuideMainScreenState();
}

class _GuideMainScreenState extends State<GuideMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const GuideMonitoringScreen(),
    const GuideViewFilesScreen(),
    const ChatListScreen(),
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
                icon: Icon(Icons.assignment_outlined),
                activeIcon: Icon(Icons.assignment_rounded),
                label: 'Groups',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.folder_copy_outlined),
                activeIcon: Icon(Icons.folder_copy_rounded),
                label: 'Files',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                activeIcon: Icon(Icons.chat_bubble_rounded),
                label: 'Chat',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.rate_review_outlined),
                activeIcon: Icon(Icons.rate_review_rounded),
                label: 'Review',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_pin_outlined),
                activeIcon: Icon(Icons.person_pin_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
