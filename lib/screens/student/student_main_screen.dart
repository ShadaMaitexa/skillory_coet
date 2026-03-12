import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
        margin: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
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
            selectedLabelStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 10.sp,
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
        title: Text(
          'Student Dashboard',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_outlined,
                color: AppTheme.dark, size: 24.sp),
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
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Section
                      Container(
                        padding: EdgeInsets.all(20.r),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
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
                                  radius: 26.r,
                                  backgroundColor: Colors.white.withOpacity(0.2),
                                  child: Icon(Icons.person,
                                      color: Colors.white, size: 26.sp),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Welcome back,',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 13.sp,
                                        ),
                                      ),
                                      Text(
                                        userName,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18.sp,
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

                      SizedBox(height: 28.h),

                      Text(
                        'Project Information',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.dark,
                        ),
                      ),
                      SizedBox(height: 12.h),

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
                        SizedBox(height: 12.h),
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

                      SizedBox(height: 12.h),
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
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24.sp),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.dark,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: color.withOpacity(0.5), size: 20.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
