import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/shared_provider.dart';
import '../../providers/coordinator_provider.dart';
import '../../providers/guide_provider.dart';
import '../../models/group.dart';
import '../../widgets/custom_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  String? _selectedGroupId;
  final _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedGroupId == null || _feedbackController.text.trim().isEmpty) return;
    await context.read<SharedProvider>().sendFeedback(
          _selectedGroupId!,
          _feedbackController.text.trim(),
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feedback submitted!')));
      _feedbackController.clear();
      setState(() => _selectedGroupId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Feedback')),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(user?.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final userData = snapshot.data?.data() as Map<String, dynamic>?;
          final isCoordinator = (userData?['specificRole'] == 'Coordinator');

          final groupsStream = isCoordinator
              ? context.watch<CoordinatorProvider>().allGroupsStream
              : context.watch<GuideProvider>().myGroupsStream;

          return StreamBuilder<List<GroupModel>>(
            stream: groupsStream,
            builder: (context, snap) {
              final groups = snap.data ?? [];

              return SingleChildScrollView(
                padding: EdgeInsets.all(24.r),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedGroupId,
                      style: TextStyle(fontSize: 14.sp, color: AppTheme.text),
                      decoration: InputDecoration(
                        labelText: 'Select Team',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      items: groups.map((g) => DropdownMenuItem(value: g.id, child: Text(g.name))).toList(),
                      onChanged: (val) => setState(() => _selectedGroupId = val),
                    ),
                    SizedBox(height: 16.h),
                    CustomTextField(
                      label: 'Feedback',
                      hint: 'Type your feedback here...',
                      controller: _feedbackController,
                      maxLines: 5,
                    ),
                    SizedBox(height: 24.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit, 
                        child: Text('Submit Feedback', style: TextStyle(fontSize: 16.sp)),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
