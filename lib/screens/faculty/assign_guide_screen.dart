import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/coordinator_provider.dart';
import '../../models/group.dart';
import '../../models/app_user.dart';

class AssignGuideScreen extends StatefulWidget {
  const AssignGuideScreen({super.key});

  @override
  State<AssignGuideScreen> createState() => _AssignGuideScreenState();
}

class _AssignGuideScreenState extends State<AssignGuideScreen> {
  String? _selectedGroupId;
  String? _selectedGuideId;

  Future<void> _assign() async {
    if (_selectedGroupId == null || _selectedGuideId == null) return;
    await context.read<CoordinatorProvider>().assignGuideToGroup(
          _selectedGroupId!,
          _selectedGuideId!,
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Guide assigned!')));
      setState(() {
        _selectedGroupId = null;
        _selectedGuideId = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Assign Guide')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            StreamBuilder<List<GroupModel>>(
              stream: context.read<CoordinatorProvider>().allGroupsStream,
              builder: (context, snapshot) {
                final groups = snapshot.data ?? [];
                return DropdownButtonFormField<String>(
                  value: _selectedGroupId,
                  decoration: const InputDecoration(labelText: 'Select Group'),
                  items: groups.map((g) => DropdownMenuItem(value: g.id, child: Text(g.name))).toList(),
                  onChanged: (val) => setState(() => _selectedGroupId = val),
                );
              },
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<AppUser>>(
              stream: context.read<CoordinatorProvider>().approvedFacultyStream,
              builder: (context, snapshot) {
                final faculty = snapshot.data ?? [];
                return DropdownButtonFormField<String>(
                  value: _selectedGuideId,
                  decoration: const InputDecoration(labelText: 'Select Faculty (Guide)'),
                  items: faculty.map((f) => DropdownMenuItem(value: f.id, child: Text(f.name))).toList(),
                  onChanged: (val) => setState(() => _selectedGuideId = val),
                );
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(onPressed: _assign, child: const Text('Confirm Assignment')),
          ],
        ),
      ),
    );
  }
}
