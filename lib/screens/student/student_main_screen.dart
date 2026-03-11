import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'upload_files_screen.dart';
import '../shared/chat_list_screen.dart';
import '../shared/profile_screen.dart';
import '../../providers/student_provider.dart';
import 'package:provider/provider.dart';
import '../../models/group.dart';
import '../../models/app_user.dart';
import '../shared/project_details_screen.dart';
import '../shared/chat_room_screen.dart';
import '../shared/activity_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/shared_provider.dart';

class StudentMainScreen extends StatefulWidget {
  const StudentMainScreen({super.key});

  @override
  State<StudentMainScreen> createState() => _StudentMainScreenState();
}

class _StudentMainScreenState extends State<StudentMainScreen> {
  int _currentIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      StudentDashboardContent(onTabChange: (index) {
        setState(() {
          _currentIndex = index;
        });
      }),
      const ChatListScreen(),
      const UploadFilesScreen(),
      const ProfileScreen(),
    ];
  }

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
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline_rounded),
                activeIcon: Icon(Icons.chat_bubble_rounded),
                label: 'Chat',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.cloud_upload_outlined),
                activeIcon: Icon(Icons.cloud_upload_rounded),
                label: 'Upload',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Extract content from StudentDashboard for reusability
class StudentDashboardContent extends StatelessWidget {
  final Function(int) onTabChange;
  const StudentDashboardContent({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined, color: AppTheme.dark),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ActivityScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<GroupModel?>(
          stream: context.watch<StudentProvider>().myGroupStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final group = snapshot.data;

            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Section
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: StreamBuilder<AppUser?>(
                          stream: context.read<SharedProvider>().getUserStream(
                                FirebaseAuth.instance.currentUser?.uid ?? '',
                              ),
                          builder: (context, userSnap) {
                            final userName = userSnap.data?.name ?? 'Student';
                            return Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.white.withOpacity(0.2),
                                  child: const Icon(Icons.person,
                                      color: Colors.white, size: 30),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Welcome back,',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        userName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 32),

                      const Text(
                        'Project Information',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.dark,
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (group != null) ...[
                        _buildFeatureCard(
                          title: 'Project Dashboard',
                          subtitle: group.name,
                          icon: Icons.rocket_launch_outlined,
                          color: const Color(0xFF6366F1),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProjectDetailsScreen(group: group),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureCard(
                          title: 'Group Chat',
                          subtitle: 'Connect with your team',
                          icon: Icons.chat_bubble_outline_rounded,
                          color: const Color(0xFF10B981),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatRoomScreen(
                                  groupId: group.id,
                                  groupName: group.name,
                                ),
                              ),
                            );
                          },
                        ),
                      ] else ...[
                        _buildFeatureCard(
                          title: 'Team Formation',
                          subtitle: 'Pending group assignment',
                          icon: Icons.group_add_outlined,
                          color: const Color(0xFFF59E0B),
                          onTap: () {},
                        ),
                      ],

                      const SizedBox(height: 16),
                      _buildFeatureCard(
                        title: 'Upload Work',
                        subtitle: 'Submit your progress',
                        icon: Icons.cloud_upload_outlined,
                        color: const Color(0xFF3B82F6),
                        onTap: () => onTabChange(2), // Switch to upload tab
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.dark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: color.withOpacity(0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
