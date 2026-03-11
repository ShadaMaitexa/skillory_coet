import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/group.dart';
import '../../models/feedback.dart';
import 'package:provider/provider.dart';
import '../../providers/shared_provider.dart';
import '../../providers/student_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final GroupModel group;

  const ProjectDetailsScreen({super.key, required this.group});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _techController;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.group.projectTitle);
    _descController = TextEditingController(text: widget.group.projectDescription);
    _techController = TextEditingController(text: widget.group.projectTechStack.join(', '));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _techController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => _isLoading = true);
    try {
      final techStack = _techController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      await context.read<StudentProvider>().updateProjectDetails(
            groupId: widget.group.id,
            title: _titleController.text.trim(),
            description: _descController.text.trim(),
            techStack: techStack,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Project details saved successfully!')),
      );
      setState(() => _isEditing = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(widget.group.name),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProjectInfoCard(),
            const SizedBox(height: 32),
            const Text(
              'Feedback History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.dark,
              ),
            ),
            const SizedBox(height: 16),
            _buildFeedbackList(),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_isEditing) ...[
            Text(
              widget.group.projectTitle.isEmpty
                  ? 'No Project Title Set'
                  : widget.group.projectTitle,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.dark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.group.projectDescription.isEmpty
                  ? 'No description provided yet. Click edit to add details.'
                  : widget.group.projectDescription,
              style: const TextStyle(fontSize: 15, color: AppTheme.text),
            ),
            if (widget.group.projectTechStack.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Tech Stack',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textLight),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: widget.group.projectTechStack.map((tech) {
                  return Chip(
                    label: Text(tech, style: const TextStyle(fontSize: 12)),
                    backgroundColor: AppTheme.primary.withOpacity(0.1),
                    side: BorderSide.none,
                    padding: EdgeInsets.zero,
                  );
                }).toList(),
              ),
            ],
          ] else ...[
            const Text(
              'Edit Project Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Project Title',
              hint: 'Enter project name',
              controller: _titleController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Project Description',
              hint: 'Describe your project goal',
              controller: _descController,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Tech Stack (comma separated)',
              hint: 'Flutter, Firebase, Node.js',
              controller: _techController,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _isEditing = false),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: 'Save Details',
                    isLoading: _isLoading,
                    onPressed: _handleSave,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeedbackList() {
    return StreamBuilder<List<FeedbackModel>>(
      stream: context.read<SharedProvider>().feedbackForGroup(widget.group.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final feedbacks = snapshot.data ?? [];
        if (feedbacks.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                'No feedback from guide or coordinator yet.',
                style: TextStyle(color: AppTheme.textLight),
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: feedbacks.length,
          itemBuilder: (context, index) {
            final fb = feedbacks[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        fb.facultyName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${fb.timestamp.toDate().day}/${fb.timestamp.toDate().month}',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textLight),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(fb.text, style: const TextStyle(color: AppTheme.text)),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
