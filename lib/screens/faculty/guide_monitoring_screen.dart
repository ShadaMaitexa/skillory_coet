import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../providers/guide_provider.dart';
import '../../models/group.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GuideMonitoringScreen extends StatelessWidget {
  const GuideMonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Monitoring & Attendance'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Assigned Teams',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.dark,
              ),
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<GroupModel>>(
              stream: context.watch<GuideProvider>().myGroupsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final groups = snapshot.data ?? [];
                if (groups.isEmpty) {
                  return const Center(child: Text('No groups assigned yet.'));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: ExpansionTile(
                        title: Text(
                          group.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Members: ${group.memberIds.length}'),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Attendance'),
                                    ElevatedButton(
                                      onPressed: () {
                                        // Simple placeholder for attendance marking in Firestore
                                        FirebaseFirestore.instance
                                            .collection('attendance')
                                            .add({
                                          'groupId': group.id,
                                          'guideId': FirebaseAuth
                                              .instance.currentUser?.uid,
                                          'timestamp':
                                              FieldValue.serverTimestamp(),
                                        });
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Attendance marked!')));
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                      ),
                                      child: const Text('Mark Now'),
                                    ),
                                  ],
                                ),
                                const Divider(),
                                const ListTile(
                                  leading: Icon(Icons.check_circle_outline,
                                      color: Colors.green),
                                  title: Text('Project Progress'),
                                  subtitle: Text('Status: Dynamic View Enabled'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
