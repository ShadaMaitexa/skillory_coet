import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import '../../theme/app_theme.dart';
import '../../providers/student_provider.dart';
import '../../models/group.dart';
import '../../models/file_meta.dart';
import '../../providers/guide_provider.dart';
import '../../utils/cloudinary_helper.dart';

class UploadFilesScreen extends StatefulWidget {
  const UploadFilesScreen({super.key});

  @override
  State<UploadFilesScreen> createState() => _UploadFilesScreenState();
}

class _UploadFilesScreenState extends State<UploadFilesScreen> {
  bool _isUploading = false;

  Future<void> _pickAndUpload(String groupId) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result == null || result.files.isEmpty) return;

      setState(() => _isUploading = true);

      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;
      
      // 1. Upload to Cloudinary
      final url = await CloudinaryHelper.uploadFile(file);
      
      if (url == null) {
        throw Exception('Failed to upload file to storage');
      }

      // 2. Save meta to Firestore
      if (!mounted) return;
      await context.read<StudentProvider>().uploadFile(
            fileName: fileName,
            groupId: groupId,
            type: fileName.split('.').last.toUpperCase(),
            url: url,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File uploaded successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('My Project Files')),
      body: StreamBuilder<GroupModel?>(
        stream: context.watch<StudentProvider>().myGroupStream,
        builder: (context, snapshot) {
          final group = snapshot.data;
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (group == null) {
            return const Center(
              child: Text('Not assigned to any group yet.'),
            );
          }

          return Column(
            children: [
              _buildUploadHeader(group),
              Expanded(
                child: _buildFileList(group.id),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUploadHeader(GroupModel group) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.cloud_upload_outlined,
            size: 48,
            color: _isUploading ? AppTheme.primary : AppTheme.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            'Upload documents for ${group.name}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (_isUploading)
            const LinearProgressIndicator()
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _pickAndUpload(group.id),
                icon: const Icon(Icons.add),
                label: const Text('Pick PDF or Document'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFileList(String groupId) {
    // Reusing the stream from guide_provider or shared if available
    return StreamBuilder<List<FileMeta>>(
      stream: context.watch<GuideProvider>().filesForGroup(groupId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final files = snapshot.data ?? [];
        
        if (files.isEmpty) {
          return const Center(
            child: Text('No files uploaded yet.', style: TextStyle(color: AppTheme.textLight)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: files.length,
          itemBuilder: (context, index) {
            final file = files[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.picture_as_pdf, color: AppTheme.primary),
                ),
                title: Text(
                  file.fileName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: Text('Type: ${file.type}', style: const TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.open_in_new, size: 20),
                onTap: () {
                  if (file.url != null && file.url!.isNotEmpty) {
                    OpenFile.open(file.url);
                  } else {
                     ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No URL associated with this file.')),
                    );
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}
