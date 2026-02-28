import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/student_provider.dart';
import '../../providers/guide_provider.dart';
import '../../providers/coordinator_provider.dart';
import '../../models/group.dart';
import 'chat_room_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text('Login required.'));

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final userData = snapshot.data?.data() as Map<String, dynamic>?;
        final role = userData?['role'] ?? 'Student';
        final specificRole = userData?['specificRole'] as String?;

        if (role == 'Student') {
          return StreamBuilder<GroupModel?>(
            stream: context.read<StudentProvider>().myGroupStream,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final group = snap.data;
              if (group == null) {
                return Scaffold(
                  appBar: AppBar(title: const Text('Chats')),
                  body: const Center(child: Text('Not assigned to any group yet.')),
                );
              }
              return ChatRoomScreen(groupId: group.id, groupName: group.name);
            },
          );
        } else if (role == 'Faculty') {
          final isCoordinator = specificRole == 'Coordinator';
          final stream = isCoordinator
              ? context.read<CoordinatorProvider>().myGroupsStream
              : context.read<GuideProvider>().myGroupsStream;

          return Scaffold(
            appBar: AppBar(title: Text(isCoordinator ? 'All Group Chats' : 'My Group Chats')),
            body: StreamBuilder<List<GroupModel>>(
              stream: stream,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final groups = snap.data ?? [];
                if (groups.isEmpty) {
                  return const Center(child: Text('No groups assigned yet.'));
                }

                return ListView.builder(
                  itemCount: groups.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primary.withOpacity(0.1),
                          child: const Icon(Icons.group, color: AppTheme.primary),
                        ),
                        title: Text(group.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Dept: ${group.department} • Sem: ${group.semester}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatRoomScreen(
                                groupId: group.id,
                                groupName: group.name,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          );
        }

        return const Scaffold(body: Center(child: Text('Role unknown.')));
      },
    );
  }
}
