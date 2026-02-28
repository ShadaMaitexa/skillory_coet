import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../utils/cloudinary_helper.dart';
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
  final _deptController = TextEditingController();
  final _semesterController = TextEditingController();

  // Section 2: Technical Skills
  final List<String> _programmingLanguages = ['C', 'C++', 'Java', 'Python', 'JavaScript'];
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
  final List<String> _prevProjectRoles = ['Programmer', 'Designer', 'Team Leader', 'Documentation', 'Testing'];
  final List<String> _selectedPrevRoles = [];

  // Section 4: Soft Skills
  String? _teamComfort; // Not comfortable, Comfortable, Very comfortable
  final List<String> _preferredTeamRoles = ['Team Leader', 'Developer', 'Designer', 'Researcher', 'Documentation'];
  final List<String> _selectedPreferredRoles = [];
  String? _commSkills; // Poor, Average, Good

  // Section 5: Tools
  final List<String> _tools = ['VS Code', 'Git/GitHub', 'MySQL', 'Figma', 'None'];
  final List<String> _selectedTools = [];
  bool? _openToLearningNewTools;

  File? _proofFile;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _rollNumberController.dispose();
    _deptController.dispose();
    _semesterController.dispose();
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
      if (_selectedLanguages.isEmpty && _othersLanguageController.text.isEmpty) {
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
        department: _deptController.text.trim(),
        semester: _semesterController.text.trim(),
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildRoleSelector(),
                const SizedBox(height: 24),
                
                _buildSectionHeader('Section 1: Basic Information'),
                const SizedBox(height: 16),
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
                  text: 'Complete Registration',
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
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
        const Divider(color: AppTheme.primary, thickness: 1),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Join Skillory',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        Text(
          'Complete details for smart grouping',
          style: TextStyle(color: AppTheme.textLight),
        ),
      ],
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Registering as:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedRole,
          decoration: InputDecoration(
            fillColor: AppTheme.surface,
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
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
          controller: _nameController,
          prefixIcon: Icons.person,
          validator: (v) => v!.isEmpty ? 'Name required' : null,
        ),
        if (_selectedRole == 'Student') ...[
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Roll Number / ID',
            controller: _rollNumberController,
            prefixIcon: Icons.badge,
            validator: (v) => v!.isEmpty ? 'Roll number required' : null,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Department / Branch',
            controller: _deptController,
            prefixIcon: Icons.business,
            validator: (v) => v!.isEmpty ? 'Department required' : null,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Year / Semester',
            controller: _semesterController,
            prefixIcon: Icons.calendar_today,
            validator: (v) => v!.isEmpty ? 'Semester required' : null,
          ),
        ],
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Email',
          controller: _emailController,
          prefixIcon: Icons.email,
          validator: (v) => v!.isEmpty ? 'Email required' : null,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Password',
          controller: _passwordController,
          isPassword: true,
          prefixIcon: Icons.lock,
          validator: (v) => v!.length < 6 ? 'Min 6 chars' : null,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Confirm Password',
          controller: _confirmPasswordController,
          isPassword: true,
          prefixIcon: Icons.lock_reset,
          validator: (v) => v != _passwordController.text ? 'Not matching' : null,
        ),
      ],
    );
  }

  Widget _buildFacultyProof() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Verification Proof', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (_proofFile != null)
           Image.file(_proofFile!, height: 100),
        ElevatedButton.icon(
          onPressed: _pickProof,
          icon: const Icon(Icons.upload_file),
          label: Text(_proofFile == null ? 'Upload ID/Docs' : 'Change Docs'),
        ),
      ],
    );
  }

  Widget _buildTechnicalSkills() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Programming Languages Familiar With:', style: TextStyle(fontWeight: FontWeight.w600)),
        ..._programmingLanguages.map((lang) => CheckboxListTile(
              title: Text(lang),
              value: _selectedLanguages.contains(lang),
              onChanged: (v) {
                setState(() {
                  v! ? _selectedLanguages.add(lang) : _selectedLanguages.remove(lang);
                });
              },
            )),
        CustomTextField(label: 'Others (Separate by comma)', controller: _othersLanguageController),
        const SizedBox(height: 24),
        const Text('Rate your proficiency in programming:', style: TextStyle(fontWeight: FontWeight.w600)),
        ...['Beginner', 'Intermediate', 'Advanced'].map((level) => RadioListTile<String>(
              title: Text(level),
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
        const SizedBox(height: 16),
        const Text('Domains Interested In (Select up to 2):', style: TextStyle(fontWeight: FontWeight.w600)),
        ..._domains.map((domain) => CheckboxListTile(
              title: Text(domain),
              value: _selectedDomains.contains(domain),
              onChanged: (v) {
                if (v! && _selectedDomains.length >= 2) return;
                setState(() {
                  v ? _selectedDomains.add(domain) : _selectedDomains.remove(domain);
                });
              },
            )),
        const SizedBox(height: 24),
        const Text('Have you worked on any project before?', style: TextStyle(fontWeight: FontWeight.w600)),
        Row(
          children: [
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('Yes'),
                value: true,
                groupValue: _hasWorkedOnProject,
                onChanged: (v) => setState(() => _hasWorkedOnProject = v),
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('No'),
                value: false,
                groupValue: _hasWorkedOnProject,
                onChanged: (v) => setState(() => _hasWorkedOnProject = v),
              ),
            ),
          ],
        ),
        if (_hasWorkedOnProject == true) ...[
          const SizedBox(height: 16),
          const Text('Your role in the project(s):', style: TextStyle(fontWeight: FontWeight.w600)),
          ..._prevProjectRoles.map((role) => CheckboxListTile(
                title: Text(role),
                value: _selectedPrevRoles.contains(role),
                onChanged: (v) {
                  setState(() {
                    v! ? _selectedPrevRoles.add(role) : _selectedPrevRoles.remove(role);
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
        const SizedBox(height: 16),
        const Text('Comfortable working in a team?', style: TextStyle(fontWeight: FontWeight.w600)),
        ...['Not comfortable', 'Comfortable', 'Very comfortable'].map((val) => RadioListTile<String>(
              title: Text(val),
              value: val,
              groupValue: _teamComfort,
              onChanged: (v) => setState(() => _teamComfort = v),
            )),
        const SizedBox(height: 24),
        const Text('Which role do you prefer in a team?', style: TextStyle(fontWeight: FontWeight.w600)),
        ..._preferredTeamRoles.map((role) => CheckboxListTile(
              title: Text(role),
              value: _selectedPreferredRoles.contains(role),
              onChanged: (v) {
                setState(() {
                  v! ? _selectedPreferredRoles.add(role) : _selectedPreferredRoles.remove(role);
                });
              },
            )),
        const SizedBox(height: 24),
        const Text('Communication and presentation skills:', style: TextStyle(fontWeight: FontWeight.w600)),
        ...['Poor', 'Average', 'Good'].map((val) => RadioListTile<String>(
              title: Text(val),
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
        const SizedBox(height: 16),
        const Text('Tools used before:', style: TextStyle(fontWeight: FontWeight.w600)),
        ..._tools.map((tool) => CheckboxListTile(
              title: Text(tool),
              value: _selectedTools.contains(tool),
              onChanged: (v) {
                setState(() {
                  v! ? _selectedTools.add(tool) : _selectedTools.remove(tool);
                });
              },
            )),
        const SizedBox(height: 24),
        const Text('Comfortable learning new tools?', style: TextStyle(fontWeight: FontWeight.w600)),
        Row(
          children: [
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('Yes'),
                value: true,
                groupValue: _openToLearningNewTools,
                onChanged: (v) => setState(() => _openToLearningNewTools = v),
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('No'),
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
