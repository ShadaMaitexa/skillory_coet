import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../utils/cloudinary_helper.dart';
import '../../utils/departments_helper.dart';
import '../../models/app_user.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedRole = 'Student';
  final _roles = ['Faculty', 'Student'];

  // Basics
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _rollNumberController = TextEditingController();

  // Department / Semester Dropdowns
  String? _selectedDept;
  String? _selectedSem;
  List<Map<String, dynamic>> _allDepartments = [];
  StreamSubscription<List<Map<String, dynamic>>>? _deptSub;

  // Section 2: Technical Skills
  final List<String> _programmingLanguages = [
    'C',
    'C++',
    'Java',
    'Python',
    'JavaScript'
  ];
  final List<String> _selectedLanguages = [];
  final _othersLanguageController = TextEditingController();
  String? _codingProficiency; // Beginner, Intermediate, Advanced

  // Section 3: Domain Knowledge
  final List<String> _domains = [
    'Web Development',
    'Mobile App Development',
    'Data Science / AI',
    'Cyber Security',
    'IoT',
    'Cloud Computing'
  ];
  final List<String> _selectedDomains = []; // Limit to 2
  bool? _hasWorkedOnProject;
  final List<String> _prevProjectRoles = [
    'Programmer',
    'Designer',
    'Team Leader',
    'Documentation',
    'Testing'
  ];
  final List<String> _selectedPrevRoles = [];

  // Section 4: Soft Skills
  String? _teamComfort; // Not comfortable, Comfortable, Very comfortable
  final List<String> _preferredTeamRoles = [
    'Team Leader',
    'Developer',
    'Designer',
    'Researcher',
    'Documentation'
  ];
  final List<String> _selectedPreferredRoles = [];
  String? _commSkills; // Poor, Average, Good

  // Section 5: Tools
  final List<String> _tools = [
    'VS Code',
    'Git/GitHub',
    'MySQL',
    'Figma',
    'None'
  ];
  final List<String> _selectedTools = [];
  bool? _openToLearningNewTools;

  File? _proofFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _deptSub = departmentsStream().listen((data) {
      if (mounted) setState(() => _allDepartments = data);
    });
  }

  @override
  void dispose() {
    _deptSub?.cancel();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _rollNumberController.dispose();
    _othersLanguageController.dispose();
    super.dispose();
  }

  Future<void> _pickProof() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _proofFile = File(picked.path));
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRole == 'Student') {
      if (_selectedDept == null) {
        _showError('Please select your department.');
        return;
      }
      if (_selectedSem == null) {
        _showError('Please select your semester.');
        return;
      }
      if (_selectedLanguages.isEmpty &&
          _othersLanguageController.text.isEmpty) {
        _showError('Please select at least one programming language.');
        return;
      }
      if (_codingProficiency == null) {
        _showError('Please select your coding proficiency level.');
        return;
      }
      if (_selectedDomains.isEmpty) {
        _showError('Please select at least one domain of interest.');
        return;
      }
      if (_hasWorkedOnProject == null) {
        _showError('Please specify if you have worked on a project before.');
        return;
      }
      if (_teamComfort == null) {
        _showError('Please specify your team working comfort level.');
        return;
      }
      if (_commSkills == null) {
        _showError('Please rate your communication skills.');
        return;
      }
      if (_openToLearningNewTools == null) {
        _showError('Please specify if you are comfortable learning new tools.');
        return;
      }

      // ── Check semester capacity ──────────────────────────
      try {
        final deptDoc = await FirebaseFirestore.instance
            .collection('departments')
            .doc(_selectedDept)
            .get();
        if (deptDoc.exists) {
          final rawLimits =
              deptDoc.data()?['semesterLimits'] as Map<String, dynamic>?;
          if (rawLimits != null && rawLimits.containsKey(_selectedSem)) {
            final limit = (rawLimits[_selectedSem] as num).toInt();
            final countSnap = await FirebaseFirestore.instance
                .collection('users')
                .where('role', isEqualTo: 'Student')
                .where('department', isEqualTo: _selectedDept)
                .where('semester', isEqualTo: _selectedSem)
                .get();
            if (countSnap.docs.length >= limit) {
              _showError(
                'Registration closed: $_selectedSem in $_selectedDept has reached '
                'its maximum capacity of $limit students.',
              );
              return;
            }
          }
        }
      } catch (_) {
        // If capacity check fails, allow registration to proceed
      }
    } else {
      if (_proofFile == null) {
        _showError('Proof document is required for faculty registration.');
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      String? proofUrl;
      if (_selectedRole == 'Faculty') {
        proofUrl = await CloudinaryHelper.uploadFile(_proofFile!);
        if (proofUrl == null) throw 'Cloudinary upload failed.';
      }

      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final List<String> finalLanguages = List.from(_selectedLanguages);
      if (_othersLanguageController.text.isNotEmpty) {
        finalLanguages.add(_othersLanguageController.text.trim());
      }

      final appUser = AppUser(
        id: cred.user!.uid,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        role: _selectedRole,
        status: _selectedRole == 'Student' ? 'approved' : 'pending',
        proofUrl: proofUrl,
        rollNumber: _rollNumberController.text.trim(),
        department: _selectedDept,
        semester: _selectedSem,
        programmingLanguages: finalLanguages,
        codingProficiency: _codingProficiency,
        domainInterests: _selectedDomains,
        hasWorkedOnProject: _hasWorkedOnProject,
        previousProjectRoles: _selectedPrevRoles,
        teamComfort: _teamComfort,
        preferredTeamRoles: _selectedPreferredRoles,
        communicationSkills: _commSkills,
        toolsUsed: _selectedTools,
        openToLearningNewTools: _openToLearningNewTools,
        createdAt: Timestamp.now(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set(appUser.toMap());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_selectedRole == 'Faculty'
              ? 'Registration successful. Awaiting admin approval.'
              : 'Registration successful!'),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('New Registration'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                SizedBox(height: 32.h),
                _buildRoleSelector(),
                SizedBox(height: 24.h),
                _buildSectionHeader('Section 1: Basic Information'),
                SizedBox(height: 16.h),
                _buildBasics(),
                if (_selectedRole == 'Faculty') ...[
                  const SizedBox(height: 24),
                  _buildFacultyProof(),
                ],
                if (_selectedRole == 'Student') ...[
                  const SizedBox(height: 32),
                  _buildSectionHeader('Section 2: Technical Skills'),
                  _buildTechnicalSkills(),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Section 3: Domain Knowledge'),
                  _buildDomainKnowledge(),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Section 4: Soft Skills'),
                  _buildSoftSkills(),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Section 5: Tools & Learning'),
                  _buildToolsSection(),
                ],
                const SizedBox(height: 48),
                CustomButton(
                  text: 'Register',
                  isLoading: _isLoading,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
        Divider(color: AppTheme.primary, thickness: 1.h),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Join Skillory',
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.dark,
            letterSpacing: -1,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Complete details for smart grouping',
          style: TextStyle(
            color: AppTheme.textLight,
            fontSize: 14.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Registering as:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          value: _selectedRole,
          style: TextStyle(fontSize: 14.sp, color: AppTheme.text),
          decoration: InputDecoration(
            fillColor: AppTheme.surface,
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
          ),
          items: _roles
              .map((r) => DropdownMenuItem(value: r, child: Text(r)))
              .toList(),
          onChanged: (v) => setState(() => _selectedRole = v!),
        ),
      ],
    );
  }

  Widget _buildBasics() {
    return Column(
      children: [
        CustomTextField(
          label: 'Full Name',
          hint: 'e.g. John Doe',
          controller: _nameController,
          prefixIcon: Icons.person,
          textInputAction: TextInputAction.next,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Name required';
            if (v.trim().length < 3) return 'Name is too short';
            return null;
          },
        ),
        if (_selectedRole == 'Student' || _selectedRole == 'Faculty') ...[
          SizedBox(height: 16.h),
          // Department Dropdown
          DropdownButtonFormField<String>(
            value: _selectedDept,
            style: TextStyle(fontSize: 14.sp, color: AppTheme.text),
            decoration: InputDecoration(
              labelText: 'Department / Branch',
              prefixIcon: Icon(Icons.business, size: 20.sp),
              fillColor: AppTheme.surface,
              filled: true,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            hint: _allDepartments.isEmpty
                ? const Text('Loading departments...')
                : const Text('Select Department'),
            items: _allDepartments
                .map((d) => (d['name'] ?? '').toString())
                .where((name) => name.isNotEmpty)
                .toSet() // Ensure unique names
                .map((name) => DropdownMenuItem(
                      value: name,
                      child: Text(name),
                    ))
                .toList(),
            onChanged: (v) => setState(() {
              _selectedDept = v;
              _selectedSem = null; // reset semester
            }),
            validator: (v) => v == null ? 'Department required' : null,
          ),
        ],
        if (_selectedRole == 'Student') ...[
          SizedBox(height: 16.h),
          CustomTextField(
            label: 'Roll Number / ID',
            hint: 'e.g. 21CS001',
            controller: _rollNumberController,
            prefixIcon: Icons.badge,
            textInputAction: TextInputAction.next,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Roll number required';
              if (v.length < 5) return 'Invalid roll number format';
              return null;
            },
          ),
          SizedBox(height: 16.h),
          // Semester Dropdown (depends on dept)
          Builder(builder: (context) {
            final deptData = _allDepartments.firstWhere(
              (d) => d['name']?.toString() == _selectedDept?.toString(),
              orElse: () => {},
            );
            final semesters = (deptData['semesters'] as Iterable? ?? [])
                .map((e) => e.toString())
                .toList();
            return DropdownButtonFormField<String>(
              value: semesters.contains(_selectedSem) ? _selectedSem : null,
              style: TextStyle(fontSize: 14.sp, color: AppTheme.text),
              decoration: InputDecoration(
                labelText: 'Year / Semester',
                prefixIcon: Icon(Icons.calendar_today, size: 20.sp),
                fillColor: AppTheme.surface,
                filled: true,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              hint: _selectedDept == null
                  ? const Text('Select department first')
                  : const Text('Select Semester'),
              items: semesters
                  .toSet() // Ensure unique semesters
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: _selectedDept == null
                  ? null
                  : (v) => setState(() => _selectedSem = v),
              validator: (v) => v == null ? 'Semester required' : null,
            );
          }),
        ],
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Email',
          hint: 'e.g. john@example.com',
          controller: _emailController,
          prefixIcon: Icons.email,
          textInputAction: TextInputAction.next,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Email required';
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
              return 'Enter a valid email address';
            }
            return null;
          },
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          label: 'Password',
          hint: 'Min 6 characters',
          controller: _passwordController,
          isPassword: true,
          prefixIcon: Icons.lock,
          textInputAction: TextInputAction.next,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Password required';
            if (v.length < 6) return 'Password must be at least 6 characters';
            return null;
          },
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          label: 'Confirm Password',
          hint: 'Re-enter password',
          controller: _confirmPasswordController,
          isPassword: true,
          prefixIcon: Icons.lock_reset,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _handleRegister(),
          validator: (v) {
             if (v == null || v.isEmpty) return 'Please confirm your password';
             if (v != _passwordController.text) return 'Passwords do not match';
             return null;
          },
        ),
      ],
    );
  }

  Widget _buildFacultyProof() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Verification Proof',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp)),
        SizedBox(height: 8.h),
        if (_proofFile != null) Image.file(_proofFile!, height: 100.h),
        ElevatedButton.icon(
          onPressed: _pickProof,
          icon: Icon(Icons.upload_file, size: 20.sp),
          label: Text(_proofFile == null ? 'Upload ID/Docs' : 'Change Docs', style: TextStyle(fontSize: 14.sp)),
        ),
      ],
    );
  }

  Widget _buildTechnicalSkills() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.h),
        Text('Programming Languages Familiar With:',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp)),
        ..._programmingLanguages.map((lang) => CheckboxListTile(
              title: Text(lang, style: TextStyle(fontSize: 14.sp)),
              value: _selectedLanguages.contains(lang),
              onChanged: (v) {
                setState(() {
                  v!
                      ? _selectedLanguages.add(lang)
                      : _selectedLanguages.remove(lang);
                });
              },
            )),
        CustomTextField(
          label: 'Others (Separate by comma)',
          hint: 'e.g. Swift, Go, Kotlin',
          controller: _othersLanguageController,
        ),
        SizedBox(height: 24.h),
        Text('Rate your proficiency in programming:',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp)),
        ...['Beginner', 'Intermediate', 'Advanced']
            .map((level) => RadioListTile<String>(
                  title: Text(level, style: TextStyle(fontSize: 14.sp)),
                  value: level,
                  groupValue: _codingProficiency,
                  onChanged: (v) => setState(() => _codingProficiency = v),
                )),
      ],
    );
  }

  Widget _buildDomainKnowledge() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.h),
        Text('Domains Interested In (Select up to 2):',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp)),
        ..._domains.map((domain) => CheckboxListTile(
              title: Text(domain, style: TextStyle(fontSize: 14.sp)),
              value: _selectedDomains.contains(domain),
              onChanged: (v) {
                if (v! && _selectedDomains.length >= 2) return;
                setState(() {
                  v
                      ? _selectedDomains.add(domain)
                      : _selectedDomains.remove(domain);
                });
              },
            )),
        SizedBox(height: 24.h),
        Text('Have you worked on any project before?',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp)),
        Row(
          children: [
            Expanded(
              child: RadioListTile<bool>(
                title: Text('Yes', style: TextStyle(fontSize: 14.sp)),
                value: true,
                groupValue: _hasWorkedOnProject,
                onChanged: (v) => setState(() => _hasWorkedOnProject = v),
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                title: Text('No', style: TextStyle(fontSize: 14.sp)),
                value: false,
                groupValue: _hasWorkedOnProject,
                onChanged: (v) => setState(() => _hasWorkedOnProject = v),
              ),
            ),
          ],
        ),
        if (_hasWorkedOnProject == true) ...[
          SizedBox(height: 16.h),
          Text('Your role in the project(s):',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp)),
          ..._prevProjectRoles.map((role) => CheckboxListTile(
                title: Text(role, style: TextStyle(fontSize: 14.sp)),
                value: _selectedPrevRoles.contains(role),
                onChanged: (v) {
                  setState(() {
                    v!
                        ? _selectedPrevRoles.add(role)
                        : _selectedPrevRoles.remove(role);
                  });
                },
              )),
        ],
      ],
    );
  }

  Widget _buildSoftSkills() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.h),
        Text('Comfortable working in a team?',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp)),
        ...['Not comfortable', 'Comfortable', 'Very comfortable']
            .map((val) => RadioListTile<String>(
                  title: Text(val, style: TextStyle(fontSize: 14.sp)),
                  value: val,
                  groupValue: _teamComfort,
                  onChanged: (v) => setState(() => _teamComfort = v),
                )),
        SizedBox(height: 24.h),
        Text('Which role do you prefer in a team?',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp)),
        ..._preferredTeamRoles.map((role) => CheckboxListTile(
              title: Text(role, style: TextStyle(fontSize: 14.sp)),
              value: _selectedPreferredRoles.contains(role),
              onChanged: (v) {
                setState(() {
                  v!
                      ? _selectedPreferredRoles.add(role)
                      : _selectedPreferredRoles.remove(role);
                });
              },
            )),
        SizedBox(height: 24.h),
        Text('Communication and presentation skills:',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp)),
        ...['Poor', 'Average', 'Good'].map((val) => RadioListTile<String>(
              title: Text(val, style: TextStyle(fontSize: 14.sp)),
              value: val,
              groupValue: _commSkills,
              onChanged: (v) => setState(() => _commSkills = v),
            )),
      ],
    );
  }

  Widget _buildToolsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.h),
        Text('Tools used before:',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp)),
        ..._tools.map((tool) => CheckboxListTile(
              title: Text(tool, style: TextStyle(fontSize: 14.sp)),
              value: _selectedTools.contains(tool),
              onChanged: (v) {
                setState(() {
                  v! ? _selectedTools.add(tool) : _selectedTools.remove(tool);
                });
              },
            )),
        SizedBox(height: 24.h),
        Text('Comfortable learning new tools?',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp)),
        Row(
          children: [
            Expanded(
              child: RadioListTile<bool>(
                title: Text('Yes', style: TextStyle(fontSize: 14.sp)),
                value: true,
                groupValue: _openToLearningNewTools,
                onChanged: (v) => setState(() => _openToLearningNewTools = v),
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                title: Text('No', style: TextStyle(fontSize: 14.sp)),
                value: false,
                groupValue: _openToLearningNewTools,
                onChanged: (v) => setState(() => _openToLearningNewTools = v),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
