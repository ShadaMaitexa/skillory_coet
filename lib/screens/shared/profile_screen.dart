import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;

import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';
import '../../providers/shared_provider.dart';
import '../../models/app_user.dart';
import '../../utils/cloudinary_helper.dart';
import '../../utils/departments_helper.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sharedProvider = context.watch<SharedProvider>();
    // Note: We still need to know which UID to fetch.
    // We can get it from the sharedProvider if we add a getter for currently logged in UID.
    // For now, let's keep it simple but safe via Firebase.apps check.
    
    return StreamBuilder<AppUser?>(
      stream: sharedProvider.getUserStream(null), // Path to get current user uid inside repository
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final appUser = snapshot.data;
        if (appUser == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Profile')),
            body: const Center(child: Text('User details not found')),
          );
        }

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            title: const Text('My Profile'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _navigateToEditProfile(context, appUser),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildProfileHeader(appUser),
                const SizedBox(height: 32),
                _buildSectionHeader('Account Information'),
                const SizedBox(height: 12),
                _buildInfoCard([
                  _buildInfoItem(Icons.email_outlined, 'Email', appUser.email),
                  _buildInfoItem(Icons.badge_outlined, 'Role', appUser.role),
                  if (appUser.department != null)
                    _buildInfoItem(
                        Icons.business_outlined, 'Department', appUser.department!),
                  if (appUser.specificRole != null)
                    _buildInfoItem(
                        Icons.stars_outlined, 'Specialization', appUser.specificRole!),
                ]),
                const SizedBox(height: 24),
                if (appUser.role == 'Student') ...[
                  _buildSectionHeader('Academic Details'),
                  const SizedBox(height: 12),
                  _buildInfoCard([
                    _buildInfoItem(
                        Icons.numbers, 'Roll Number', appUser.rollNumber ?? 'N/A'),
                    _buildInfoItem(
                        Icons.business_outlined, 'Department', appUser.department ?? 'N/A'),
                    _buildInfoItem(
                        Icons.calendar_today_outlined, 'Semester', appUser.semester ?? 'N/A'),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Technical Profile'),
                  const SizedBox(height: 12),
                  _buildInfoCard([
                    _buildInfoItem(Icons.code, 'Skills',
                        appUser.programmingLanguages?.join(', ') ?? 'None'),
                    _buildInfoItem(
                        Icons.trending_up, 'Proficiency', appUser.codingProficiency ?? 'N/A'),
                    _buildInfoItem(Icons.category_outlined, 'Interests',
                        appUser.domainInterests?.join(', ') ?? 'None'),
                  ]),
                ],
                const SizedBox(height: 48),
                _buildLogoutButton(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(AppUser user) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primary, width: 2),
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppTheme.primary.withOpacity(0.1),
                backgroundImage:
                    user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                child: user.photoUrl == null
                    ? const Icon(Icons.person, size: 50, color: AppTheme.primary)
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          user.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.dark,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            user.role,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppTheme.textLight,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppTheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textLight),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.text,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade50,
          foregroundColor: Colors.red,
          elevation: 0,
          side: BorderSide(color: Colors.red.shade100),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Logout'),
              content: const Text('Are you sure you want to log out?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Logout', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );

          if (confirm == true) {
            await context.read<SharedProvider>().signOut();
            if (context.mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            }
          }
        },
      ),
    );
  }

  void _navigateToEditProfile(BuildContext context, AppUser user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(user: user),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Edit Profile Screen — with image upload + dept/sem dropdowns
// ─────────────────────────────────────────────────────────
class EditProfileScreen extends StatefulWidget {
  final AppUser user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _rollController;

  // Photo
  File? _newPhotoFile;
  bool _uploadingPhoto = false;

  // Department / Semester
  String? _selectedDept;
  String? _selectedSem;
  List<Map<String, dynamic>> _allDepartments = [];
  StreamSubscription<List<Map<String, dynamic>>>? _deptSub;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _rollController = TextEditingController(text: widget.user.rollNumber);
    _selectedDept = widget.user.department;
    _selectedSem = widget.user.semester;

    // Load departments from Firestore
    _deptSub = departmentsStream().listen((data) {
      if (mounted) setState(() => _allDepartments = data);
    });
  }

  @override
  void dispose() {
    _deptSub?.cancel();
    _nameController.dispose();
    _rollController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _newPhotoFile = File(picked.path));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.user.role == 'Student') {
      if (_selectedDept == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Please select a department')));
        return;
      }
      if (_selectedSem == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Please select a semester')));
        return;
      }
    }

    setState(() => _isLoading = true);
    try {
      String? photoUrl = widget.user.photoUrl;

      // Upload new photo if chosen
      if (_newPhotoFile != null) {
        setState(() => _uploadingPhoto = true);
        final uploaded = await CloudinaryHelper.uploadFile(_newPhotoFile!);
        setState(() => _uploadingPhoto = false);
        if (uploaded != null) {
          photoUrl = uploaded;
        } else {
          throw 'Photo upload failed. Please try again.';
        }
      }

      final updates = <String, dynamic>{
        'name': _nameController.text.trim(),
        'photoUrl': photoUrl,
        if (widget.user.role == 'Student') ...{
          'rollNumber': _rollController.text.trim(),
          'department': _selectedDept,
          'semester': _selectedSem,
        },
        if (widget.user.role == 'Faculty') ...{
          'department': _selectedDept,
        },
      };

      await context.read<SharedProvider>().updateProfile(widget.user.id, updates);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Current semesters for selected dept
    final deptData = _allDepartments.firstWhere(
      (d) => d['name'] == _selectedDept,
      orElse: () => {},
    );
    final semesters =
        (deptData['semesters'] as List? ?? []).map((e) => e.toString()).toList();

    // Make sure selectedSem is still valid when dept changes
    if (_selectedSem != null && semesters.isNotEmpty && !semesters.contains(_selectedSem)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedSem = null);
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Profile Photo ─────────────────────────────────────
              Center(
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.primary, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 56,
                        backgroundColor: AppTheme.primary.withOpacity(0.08),
                        backgroundImage: _newPhotoFile != null
                            ? FileImage(_newPhotoFile!) as ImageProvider
                            : (widget.user.photoUrl != null
                                ? NetworkImage(widget.user.photoUrl!)
                                : null),
                        child: (_newPhotoFile == null && widget.user.photoUrl == null)
                            ? const Icon(Icons.person, size: 56, color: AppTheme.primary)
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _uploadingPhoto ? null : _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: AppTheme.background, width: 2),
                          ),
                          child: _uploadingPhoto
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Tap camera icon to change photo',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textLight.withOpacity(0.8),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ── Name ─────────────────────────────────────────────
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),

              // ── Student-specific fields ───────────────────────────
              if (widget.user.role == 'Student') ...[
                const SizedBox(height: 20),
                TextFormField(
                  controller: _rollController,
                  decoration: const InputDecoration(
                    labelText: 'Roll Number',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 20),

                // Department dropdown
                DropdownButtonFormField<String>(
                  value: _selectedDept,
                  decoration: InputDecoration(
                    labelText: 'Department / Branch',
                    prefixIcon: const Icon(Icons.business_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  hint: _allDepartments.isEmpty
                      ? const Text('Loading...')
                      : const Text('Select Department'),
                  items: _allDepartments
                      .map((d) => DropdownMenuItem(
                            value: d['name'] as String,
                            child: Text(d['name'] as String),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() {
                    _selectedDept = v;
                    _selectedSem = null;
                  }),
                  validator: (v) => v == null ? 'Department required' : null,
                ),
              ],
              if (widget.user.role == 'Faculty') ...[
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedDept,
                  decoration: InputDecoration(
                    labelText: 'Department / Branch',
                    prefixIcon: const Icon(Icons.business_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  hint: _allDepartments.isEmpty
                      ? const Text('Loading...')
                      : const Text('Select Department'),
                  items: _allDepartments
                      .map((d) => DropdownMenuItem(
                            value: d['name'] as String,
                            child: Text(d['name'] as String),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedDept = v),
                  validator: (v) => v == null ? 'Department required' : null,
                ),
              ],
              if (widget.user.role == 'Student') ...[
                const SizedBox(height: 20),

                // Semester dropdown
                DropdownButtonFormField<String>(
                  value: _selectedSem,
                  decoration: InputDecoration(
                    labelText: 'Year / Semester',
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  hint: _selectedDept == null
                      ? const Text('Select department first')
                      : const Text('Select Semester'),
                  items: semesters
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: _selectedDept == null
                      ? null
                      : (v) => setState(() => _selectedSem = v),
                  validator: (v) => v == null ? 'Semester required' : null,
                ),
              ],

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Save Changes'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
