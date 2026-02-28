import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/group.dart';
import '../../models/feedback.dart';
import 'package:provider/provider.dart';
import '../../providers/shared_provider.dart';

class ProjectDetailsScreen extends StatelessWidget {
  final GroupModel group;

  const ProjectDetailsScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: Text(group.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text('Department: ${group.department}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Semester: ${group.semester}'),
            const SizedBox(height: 24),
            const Text('Feedback History',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(),
            StreamBuilder<List<FeedbackModel>>(
              stream: context.read<SharedProvider>().feedbackForGroup(group.id),
              builder: (context, snapshot) {
                final feedbacks = snapshot.data ?? [];
                if (feedbacks.isEmpty) return const Text('No feedback yet.');

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: feedbacks.length,
                  itemBuilder: (context, index) {
                    final fb = feedbacks[index];
                    return Card(
                      margin: const EdgeInsets.only(top: 8),
                      child: ListTile(
                        title: Text(fb.facultyName,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(fb.text),
                        trailing: Text(fb.timestamp.toString().substring(0, 10)),
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
