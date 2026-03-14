import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/app_user.dart';
import '../../providers/admin_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/departments_helper.dart';
import '../auth/login_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.dark),
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (ctx) {
                  return AlertDialog(
                    title: const Text('Confirm Logout'),
                    content: const Text(
                      'Are you sure you want to log out from the admin account?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text(
                          'Logout',
                          style: TextStyle(color: AppTheme.primary),
                        ),
                      ),
                    ],
                  );
                },
              );

              if (shouldLogout == true) {
                if (!context.mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textLight,
          indicatorColor: AppTheme.primary,
          tabs: const [
            Tab(icon: Icon(Icons.people_outline), text: 'Users'),
            Tab(icon: Icon(Icons.school_outlined), text: 'Departments'),
            Tab(icon: Icon(Icons.group_add_outlined), text: 'Groups'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _UsersTab(),
          _DepartmentsTab(),
          _GroupsTab(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// TAB 1 — Users (Faculty approvals + All Users)
// ─────────────────────────────────────────────────────────
class _UsersTab extends StatelessWidget {
  const _UsersTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;
          final horizontalPadding = isWide ? constraints.maxWidth * 0.15 : 24.0;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width:
                          isWide ? (constraints.maxWidth * 0.7 - 16) / 2 : null,
                      child: _buildStatCard(
                        'Total Users',
                        Icons.people_outline,
                        Colors.blue,
                        context.watch<AdminProvider>().totalUsersCountStream,
                      ),
                    ),
                    SizedBox(
                      width:
                          isWide ? (constraints.maxWidth * 0.7 - 16) / 2 : null,
                      child: _buildStatCard(
                        'Pending Faculty',
                        Icons.hourglass_bottom_rounded,
                        Colors.orange,
                        context
                            .watch<AdminProvider>()
                            .pendingFacultyCountStream,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Text(
                  'Pending Faculty Approvals',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.dark,
                  ),
                ),
                const SizedBox(height: 12),
                StreamBuilder<List<AppUser>>(
                  stream: context.watch<AdminProvider>().pendingFacultyStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'Failed to load pending faculty: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }
                    final users = snapshot.data ?? <AppUser>[];
                    if (users.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'No faculty pending approval.',
                          style: TextStyle(
                              color: AppTheme.textLight, fontSize: 14),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            title: Text(
                              user.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.text,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  user.email,
                                  style: const TextStyle(
                                    color: AppTheme.textLight,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Department: ${user.department ?? 'N/A'}',
                                  style: const TextStyle(
                                    color: AppTheme.textLight,
                                    fontSize: 13,
                                  ),
                                ),
                                if (user.proofUrl != null)
                                  TextButton.icon(
                                    onPressed: () async {
                                      final url = Uri.parse(user.proofUrl!);
                                      if (await canLaunchUrl(url)) {
                                        await launchUrl(url);
                                      }
                                    },
                                    icon: const Icon(
                                        Icons.file_present_outlined,
                                        size: 14),
                                    label: const Text(
                                      'View Proof Document',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(0, 30),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (role) {
                                _handleApproveFaculty(
                                  context,
                                  userId: user.id,
                                  specificRole: role,
                                  facultyName: user.name,
                                  facultyEmail: user.email,
                                );
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: 'Coordinator',
                                  child: Text('Approve as Coordinator'),
                                ),
                                PopupMenuItem(
                                  value: 'Guide',
                                  child: Text('Approve as Guide'),
                                ),
                              ],
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      AppTheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      size: 18,
                                      color: AppTheme.primary,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Approve',
                                      style: TextStyle(
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 32),
                const Text(
                  'All Users',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.dark,
                  ),
                ),
                const SizedBox(height: 12),
                StreamBuilder<List<AppUser>>(
                  stream: context.watch<AdminProvider>().allUsersStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'Failed to load users: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }
                    final users = snapshot.data ?? <AppUser>[];
                    if (users.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'No users found.',
                          style: TextStyle(
                              color: AppTheme.textLight, fontSize: 14),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        final role = user.role;
                        final status = user.status;
                        final specificRole = user.specificRole;

                        Color statusColor;
                        String statusLabel = status;
                        if (status == 'approved') {
                          statusColor = Colors.green;
                          statusLabel = 'Approved';
                        } else if (status == 'pending') {
                          statusColor = Colors.orange;
                          statusLabel = 'Pending';
                        } else {
                          statusColor = Colors.red;
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            title: Text(
                              user.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.text,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 2),
                                Text(
                                  user.email,
                                  style: const TextStyle(
                                    color: AppTheme.textLight,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  specificRole != null && role == 'Faculty'
                                      ? '$role • $specificRole'
                                      : role,
                                  style: const TextStyle(
                                    color: AppTheme.textLight,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                statusLabel,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    IconData icon,
    Color color,
    Stream<int> stream,
  ) {
    return StreamBuilder<int>(
      stream: stream,
      builder: (context, snapshot) {
        final value = snapshot.data?.toString() ??
            (snapshot.connectionState == ConnectionState.waiting ? '...' : '0');

        return Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28.sp),
              ),
              SizedBox(width: 16.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    value,
                    style: TextStyle(
                      color: AppTheme.text,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleApproveFaculty(
    BuildContext context, {
    required String userId,
    required String specificRole,
    required String facultyName,
    required String facultyEmail,
  }) async {
    final adminProvider = context.read<AdminProvider>();

    try {
      await adminProvider.approveFaculty(
        uid: userId,
        specificRole: specificRole,
        facultyName: facultyName,
        facultyEmail: facultyEmail,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Faculty approved as $specificRole')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to approve faculty: $e')),
        );
      }
    }
  }
}

// ─────────────────────────────────────────────────────────
// TAB 2 — Department Management
// ─────────────────────────────────────────────────────────
class _DepartmentsTab extends StatefulWidget {
  const _DepartmentsTab();

  @override
  State<_DepartmentsTab> createState() => _DepartmentsTabState();
}

class _DepartmentsTabState extends State<_DepartmentsTab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── ADD DEPARTMENT ───────────────────────────────────────
  Future<void> _showAddDepartmentDialog() async {
    final nameCtrl = TextEditingController();
    // Each entry: {sem: String, limit: TextEditingController}
    final List<Map<String, dynamic>> semEntries = [];
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: Text('Add Department', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                    decoration: InputDecoration(
                      labelText: 'Department Name',
                      hintText: 'e.g. Computer Science',
                      prefixIcon: Icon(Icons.school_outlined, size: 20.sp),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (v.trim().length < 2) return 'Too short';
                      return null;
                    },
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Semesters & Student Limits',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle,
                            color: AppTheme.primary),
                        tooltip: 'Add Semester',
                        onPressed: () {
                          setDlgState(() {
                            semEntries.add({
                              'semCtrl': TextEditingController(),
                              'limitCtrl': TextEditingController(),
                              'groupLimitCtrl': TextEditingController(),
                            });
                          });
                        },
                      ),
                    ],
                  ),
                  if (semEntries.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Tap + to add semesters',
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 13),
                      ),
                    ),
                  ...semEntries.asMap().entries.map((entry) {
                    final i = entry.key;
                    final e = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: TextFormField(
                                  controller: e['semCtrl'] as TextEditingController,
                                  style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                                  decoration: InputDecoration(
                                    labelText: 'Semester ${i + 1}',
                                    hintText: 'e.g. 1st Sem',
                                    isDense: true,
                                  ),
                                  validator: (v) => v == null || v.trim().isEmpty
                                      ? 'Required'
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller:
                                      e['limitCtrl'] as TextEditingController,
                                  style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                                  decoration: const InputDecoration(
                                    labelText: 'Students',
                                    hintText: '60',
                                    isDense: true,
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'Req';
                                    }
                                    final n = int.tryParse(v);
                                    if (n == null || n < 1) return 'Err';
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller:
                                      e['groupLimitCtrl'] as TextEditingController,
                                  style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                                  decoration: const InputDecoration(
                                    labelText: 'Grp Size',
                                    hintText: '4',
                                    isDense: true,
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'Req';
                                    }
                                    final n = int.tryParse(v);
                                    if (n == null || n < 1) return 'Err';
                                    return null;
                                  },
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline,
                                    color: Colors.red, size: 20),
                                onPressed: () {
                                  setDlgState(() {
                                    (e['semCtrl'] as TextEditingController)
                                        .dispose();
                                    (e['limitCtrl'] as TextEditingController)
                                        .dispose();
                                    (e['groupLimitCtrl'] as TextEditingController)
                                        .dispose();
                                    semEntries.removeAt(i);
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                if (semEntries.isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Add at least one semester.')),
                  );
                  return;
                }
                try {
                  final name = nameCtrl.text.trim();
                  final semesters = semEntries
                      .map((e) =>
                          (e['semCtrl'] as TextEditingController).text.trim())
                      .toList();
                  final semesterLimits = <String, int>{};
                  final semesterGroupLimits = <String, int>{};
                  for (final e in semEntries) {
                    final sem =
                        (e['semCtrl'] as TextEditingController).text.trim();
                    final limitStr = (e['limitCtrl'] as TextEditingController).text.trim();
                    final groupLimitStr = (e['groupLimitCtrl'] as TextEditingController).text.trim();
                    
                    final limit = int.tryParse(limitStr) ?? 0;
                    final groupLimit = int.tryParse(groupLimitStr) ?? 4;
                    
                    semesterLimits[sem] = limit;
                    semesterGroupLimits[sem] = groupLimit;
                  }

                  await _firestore.collection('departments').doc(name).set({
                    'name': name,
                    'semesters': semesters,
                    'semesterLimits': semesterLimits,
                    'semesterGroupLimits': semesterGroupLimits,
                    'createdAt': FieldValue.serverTimestamp(),
                  });

                  // Dispose controllers
                  for (final e in semEntries) {
                    (e['semCtrl'] as TextEditingController).dispose();
                    (e['limitCtrl'] as TextEditingController).dispose();
                    (e['groupLimitCtrl'] as TextEditingController).dispose();
                  }

                  if (ctx.mounted) Navigator.of(ctx).pop();
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  // ── EDIT DEPARTMENT ──────────────────────────────────────
  Future<void> _showEditDepartmentDialog(
    String docId,
    String currentName,
    List<String> currentSemesters,
    Map<String, int> currentLimits,
    Map<String, int> currentGroupLimits,
  ) async {
    final nameCtrl = TextEditingController(text: currentName);
    final formKey = GlobalKey<FormState>();

    // Build editable entries from current semesters + limits
    final List<Map<String, dynamic>> semEntries = currentSemesters.map((sem) {
      return {
        'semCtrl': TextEditingController(text: sem),
        'limitCtrl':
            TextEditingController(text: (currentLimits[sem] ?? 60).toString()),
        'groupLimitCtrl': TextEditingController(text: (currentGroupLimits[sem] ?? 4).toString()),
      };
    }).toList();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Edit Department'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                    decoration: const InputDecoration(
                      labelText: 'Department Name',
                      prefixIcon: Icon(Icons.school_outlined),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Semesters & Student Limits',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle,
                            color: AppTheme.primary),
                        tooltip: 'Add Semester',
                        onPressed: () {
                          setDlgState(() {
                            semEntries.add({
                              'semCtrl': TextEditingController(),
                              'limitCtrl': TextEditingController(),
                              'groupLimitCtrl': TextEditingController(),
                            });
                          });
                        },
                      ),
                    ],
                  ),
                  if (semEntries.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Tap + to add semesters',
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 13),
                      ),
                    ),
                  ...semEntries.asMap().entries.map((entry) {
                    final i = entry.key;
                    final e = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: TextFormField(
                                  controller: e['semCtrl'] as TextEditingController,
                                  style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                                  decoration: InputDecoration(
                                    labelText: 'Semester ${i + 1}',
                                    hintText: 'e.g. 1st Sem',
                                    isDense: true,
                                  ),
                                  validator: (v) => v == null || v.trim().isEmpty
                                      ? 'Required'
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller:
                                      e['limitCtrl'] as TextEditingController,
                                  style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                                  decoration: const InputDecoration(
                                    labelText: 'Students',
                                    hintText: '60',
                                    isDense: true,
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'Req';
                                    }
                                    final n = int.tryParse(v);
                                    if (n == null || n < 1) return 'Err';
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller:
                                      e['groupLimitCtrl'] as TextEditingController,
                                  style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                                  decoration: const InputDecoration(
                                    labelText: 'Grp Size',
                                    hintText: '4',
                                    isDense: true,
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'Req';
                                    }
                                    final n = int.tryParse(v);
                                    if (n == null || n < 1) return 'Err';
                                    return null;
                                  },
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline,
                                    color: Colors.red, size: 20),
                                onPressed: () {
                                  setDlgState(() {
                                    (e['semCtrl'] as TextEditingController)
                                        .dispose();
                                    (e['limitCtrl'] as TextEditingController)
                                        .dispose();
                                    (e['groupLimitCtrl'] as TextEditingController)
                                        .dispose();
                                    semEntries.removeAt(i);
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                if (semEntries.isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Add at least one semester.')),
                  );
                  return;
                }
                try {
                  final newName = nameCtrl.text.trim();
                  final semesters = semEntries
                      .map((e) =>
                          (e['semCtrl'] as TextEditingController).text.trim())
                      .toList();
                  final semesterLimits = <String, int>{};
                  final semesterGroupLimits = <String, int>{};
                  for (final e in semEntries) {
                    final sem =
                        (e['semCtrl'] as TextEditingController).text.trim();
                    final limitStr = (e['limitCtrl'] as TextEditingController).text.trim();
                    final groupLimitStr = (e['groupLimitCtrl'] as TextEditingController).text.trim();

                    final limit = int.tryParse(limitStr) ?? 0;
                    final groupLimit = int.tryParse(groupLimitStr) ?? 4;

                    semesterLimits[sem] = limit;
                    semesterGroupLimits[sem] = groupLimit;
                  }

                  if (newName != docId) {
                    await _firestore
                        .collection('departments')
                        .doc(docId)
                        .delete();
                  }
                  await _firestore.collection('departments').doc(newName).set({
                    'name': newName,
                    'semesters': semesters,
                    'semesterLimits': semesterLimits,
                    'semesterGroupLimits': semesterGroupLimits,
                    'updatedAt': FieldValue.serverTimestamp(),
                  });

                  for (final e in semEntries) {
                    (e['semCtrl'] as TextEditingController).dispose();
                    (e['limitCtrl'] as TextEditingController).dispose();
                    (e['groupLimitCtrl'] as TextEditingController).dispose();
                  }

                  if (ctx.mounted) Navigator.of(ctx).pop();
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteDepartment(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Department'),
        content: Text('Are you sure you want to delete "$docId"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _firestore.collection('departments').doc(docId).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Department Management',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.dark,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Manage departments, semesters & student limits.',
                        style:
                            TextStyle(color: AppTheme.textLight, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _showAddDepartmentDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    textStyle: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('departments')
                  .orderBy('name')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red)),
                  );
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.school_outlined,
                            size: 64,
                            color: AppTheme.textLight.withOpacity(0.4)),
                        const SizedBox(height: 16),
                        const Text(
                          'No departments yet.\nTap "Add" to create the first one.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: AppTheme.textLight, fontSize: 15),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final name = data['name'] as String? ?? doc.id;
                    final semesters = (data['semesters'] as List?)
                            ?.map((e) => e.toString())
                            .toList() ??
                        [];
                    final rawLimits =
                        data['semesterLimits'] as Map<String, dynamic>?;
                    final semesterLimits = rawLimits != null
                        ? rawLimits
                            .map((k, v) => MapEntry(k, (v as num).toInt()))
                        : <String, int>{};
                    final rawGroupLimits = data['semesterGroupLimits'] as Map<String, dynamic>?;
                    final semesterGroupLimits = rawGroupLimits != null
                        ? rawGroupLimits.map((k, v) => MapEntry(k, (v as num).toInt()))
                        : <String, int>{};

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color:
                                        AppTheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.school_outlined,
                                    color: AppTheme.primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.text,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined,
                                      color: AppTheme.primary, size: 20),
                                  onPressed: () => _showEditDepartmentDialog(
                                      doc.id, name, semesters, semesterLimits, semesterGroupLimits),
                                  tooltip: 'Edit',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red, size: 20),
                                  onPressed: () => _deleteDepartment(doc.id),
                                  tooltip: 'Delete',
                                ),
                              ],
                            ),
                            if (semesters.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              const Text(
                                'Semesters & Limits:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textLight,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Show each semester with its registered count vs limit
                              ...semesters.map((sem) {
                                final limit = semesterLimits[sem] ?? 0;
                                return _SemesterCapacityRow(
                                  department: name,
                                  semester: sem,
                                  limit: limit,
                                );
                              }),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// A row that shows the live student count vs the limit for a given dept+sem
class _SemesterCapacityRow extends StatelessWidget {
  final String department;
  final String semester;
  final int limit;

  const _SemesterCapacityRow({
    required this.department,
    required this.semester,
    required this.limit,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'Student')
          .where('department', isEqualTo: department)
          .where('semester', isEqualTo: semester)
          .snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;
        final isFull = limit > 0 && count >= limit;
        final progress = limit > 0 ? (count / limit).clamp(0.0, 1.0) : 0.0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isFull
                          ? Colors.red.withOpacity(0.1)
                          : AppTheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isFull
                            ? Colors.red.withOpacity(0.4)
                            : AppTheme.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      semester,
                      style: TextStyle(
                        fontSize: 12,
                        color: isFull ? Colors.red : AppTheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$count / $limit students',
                    style: TextStyle(
                      fontSize: 12,
                      color: isFull ? Colors.red : AppTheme.textLight,
                      fontWeight: isFull ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  if (isFull) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.lock, size: 13, color: Colors.red),
                    const SizedBox(width: 2),
                    const Text(
                      'Full',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.red,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 5,
                  backgroundColor: Colors.grey.shade200,
                  color: isFull ? Colors.red : AppTheme.primary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────
// TAB 3 — Auto-Form Groups
// ─────────────────────────────────────────────────────────
class _GroupsTab extends StatelessWidget {
  const _GroupsTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Auto Form Groups',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.dark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Groups are formed automatically based on student skills and limits when a semester is full.',
              style: TextStyle(color: AppTheme.textLight, fontSize: 13),
            ),
            const SizedBox(height: 32),
            _AutoFormGroupsCard(),
          ],
        ),
      ),
    );
  }
}

class _AutoFormGroupsCard extends StatefulWidget {
  @override
  State<_AutoFormGroupsCard> createState() => _AutoFormGroupsCardState();
}

class _AutoFormGroupsCardState extends State<_AutoFormGroupsCard> {
  String? _selectedDept;
  String? _selectedSem;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: departmentsStream(),
      builder: (context, snapshot) {
        final allDepts = snapshot.data ?? [];
        final depts = allDepts
            .map((d) => (d['name'] ?? '').toString())
            .where((n) => n.isNotEmpty)
            .toList();

        List<String> semesters = [];
        Map<String, int> semesterLimits = {};
        Map<String, int> semesterGroupLimits = {};
        if (_selectedDept != null) {
          final deptData = allDepts.firstWhere(
            (d) => d['name']?.toString() == _selectedDept,
            orElse: () => {},
          );
          semesters = (deptData['semesters'] as Iterable? ?? [])
              .map((e) => e.toString())
              .toList();
          final rawLimits = deptData['semesterLimits'] as Map<String, dynamic>?;
          if (rawLimits != null) {
            semesterLimits =
                rawLimits.map((k, v) => MapEntry(k, (v as num).toInt()));
          }
          final rawGroupLimits = deptData['semesterGroupLimits'] as Map<String, dynamic>?;
          if (rawGroupLimits != null) {
            semesterGroupLimits = rawGroupLimits.map((k,v) => MapEntry(k, (v as num).toInt()));
          }
        }

        // Reset semester if not in new list
        if (_selectedSem != null && !semesters.contains(_selectedSem)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _selectedSem = null);
          });
        }

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Target Group',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedDept,
                decoration: InputDecoration(
                  labelText: 'Department',
                  prefixIcon: const Icon(Icons.school_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                hint: const Text('Select Department'),
                items: depts
                    .toSet() // Ensure unique names
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) => setState(() {
                  _selectedDept = v;
                  _selectedSem = null;
                }),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: semesters.contains(_selectedSem) ? _selectedSem : null,
                decoration: InputDecoration(
                  labelText: 'Semester',
                  prefixIcon: const Icon(Icons.calendar_month_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                hint: const Text('Select Semester'),
                items: semesters
                    .toSet() // Ensure unique semesters
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: depts.isEmpty
                    ? null
                    : (v) => setState(() => _selectedSem = v),
              ),
              const SizedBox(height: 20),

              // ── Capacity status & Generate button ──────────────
              if (_selectedDept != null && _selectedSem != null)
                _GenerateGroupsSection(
                  department: _selectedDept!,
                  semester: _selectedSem!,
                  limit: semesterLimits[_selectedSem] ?? 0,
                  groupLimit: semesterGroupLimits[_selectedSem] ?? 4,
                  isLoading: _isLoading,
                  onGenerate: () => _autoForm(semesterGroupLimits[_selectedSem] ?? 4),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.group_add_rounded),
                    label: const Text('Generate Groups'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _autoForm(int groupLimit) async {
    setState(() => _isLoading = true);
    try {
      await context.read<AdminProvider>().autoFormGroups(
            department: _selectedDept!,
            semester: _selectedSem!,
            groupLimit: groupLimit,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Groups formed successfully based on skills!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to auto-form groups: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

/// Shows live capacity and enables Generate button only when semester is full
class _GenerateGroupsSection extends StatelessWidget {
  final String department;
  final String semester;
  final int limit;
  final int groupLimit;
  final bool isLoading;
  final VoidCallback onGenerate;

  const _GenerateGroupsSection({
    required this.department,
    required this.semester,
    required this.limit,
    required this.groupLimit,
    required this.isLoading,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'Student')
          .where('department', isEqualTo: department)
          .where('semester', isEqualTo: semester)
          .snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;
        final isFull = limit > 0 && count >= limit;
        final progress = limit > 0 ? (count / limit).clamp(0.0, 1.0) : 0.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Capacity card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isFull ? Colors.green.shade50 : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isFull ? Colors.green.shade200 : Colors.orange.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isFull ? Icons.check_circle : Icons.hourglass_top,
                        color: isFull ? Colors.green : Colors.orange,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isFull
                            ? 'Semester is full — ready to generate groups!'
                            : 'Waiting for semester to fill up',
                        style: TextStyle(
                          color: isFull
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 7,
                            backgroundColor: Colors.grey.shade200,
                            color: isFull ? Colors.green : Colors.orange,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$count / $limit',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isFull
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                // Only enabled when semester is full AND not already loading
                onPressed: (isFull && !isLoading) ? onGenerate : null,
                icon: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.group_add_rounded),
                label: Text(isLoading
                    ? 'Forming...'
                    : isFull
                        ? 'Generate Groups ($groupLimit per group)'
                        : 'Generate Groups (Semester not full yet)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFull ? AppTheme.primary : Colors.grey,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
