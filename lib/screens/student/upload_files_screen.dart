import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/student_provider.dart';
import '../../models/group.dart';

class UploadFilesScreen extends StatefulWidget {
  const UploadFilesScreen({super.key});

  @override
  State<UploadFilesScreen> createState() => _UploadFilesScreenState();
}

class _UploadFilesScreenState extends State<UploadFilesScreen> {
  final _fileNameController = TextEditingController();

  @override
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
  }

  Future<void> _uploadSimulation(String groupId) async {
    final name = _fileNameController.text.trim();
    if (name.isEmpty) return;

    await context.read<StudentProvider>().uploadFile(
          fileName: name,
          groupId: groupId,
          type: 'PDF', // Simulating PDF
        );
    
    if (mounted) {
      _fileNameController.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File meta uploaded!')));
      Navigator.pop(context);
    }
  }

  void _showUploadDialog(String groupId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Simulate File Upload'),
        content: TextField(
          controller: _fileNameController,
          decoration: const InputDecoration(labelText: 'File Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => _uploadSimulation(groupId), child: const Text('Upload')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('My Files')),
      body: StreamBuilder<GroupModel?>(
        stream: context.watch<StudentProvider>().myGroupStream,
        builder: (context, snapshot) {
          final group = snapshot.data;
          if (group == null) return const Center(child: Text('Not in a group.'));

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_upload_outlined, size: 80, color: AppTheme.primary),
                const SizedBox(height: 16),
                Text('Upload for Group: ${group.name}'),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => _showUploadDialog(group.id),
                  icon: const Icon(Icons.add),
                  label: const Text('Add File Meta'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
