import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/guide_provider.dart';
import '../../models/group.dart';
import '../../models/file_meta.dart';

class GuideViewFilesScreen extends StatelessWidget {
  const GuideViewFilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Group Files')),
      body: StreamBuilder<List<GroupModel>>(
        stream: context.watch<GuideProvider>().myGroupsStream,
        builder: (context, snapshot) {
          final groups = snapshot.data ?? [];
          if (groups.isEmpty) {
            return const Center(child: Text('No groups assigned.'));
          }

          return ListView.builder(
            itemCount: groups.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final group = groups[index];
              return ExpansionTile(
                title: Text(group.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                children: [
                  StreamBuilder<List<FileMeta>>(
                    stream: context.read<GuideProvider>().filesForGroup(group.id),
                    builder: (context, fileSnap) {
                      final files = fileSnap.data ?? [];
                      if (files.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('No files uploaded yet.'),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: files.length,
                        itemBuilder: (context, fIndex) {
                          final file = files[fIndex];
                          return ListTile(
                            leading: const Icon(Icons.insert_drive_file, color: AppTheme.primary),
                            title: Text(file.fileName),
                            subtitle: Text('Type: ${file.type}'),
                            trailing: const Icon(Icons.download),
                            onTap: () {
                               // Download logic
                            },
                          );
                        },
                      );
                    },
                  )
                ],
              );
            },
          );
        },
      ),
    );
  }
}
