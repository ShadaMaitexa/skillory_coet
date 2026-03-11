import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/activity_provider.dart';
import '../../repositories/activity_repository.dart';
import '../../theme/app_theme.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Activity Feed'),
      ),
      body: StreamBuilder<List<ActivityModel>>(
        stream: context.read<ActivityProvider>().myActivitiesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final activities = snapshot.data ?? [];
          if (activities.isEmpty) {
            return const Center(child: Text('No notifications yet.'));
          }

          return ListView.builder(
            itemCount: activities.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final activity = activities[index];
              return Card(
                elevation: activity.isRead ? 0 : 2,
                color: activity.isRead ? AppTheme.surface : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: activity.isRead ? Colors.transparent : AppTheme.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: _getIconColor(activity.type).withOpacity(0.1),
                    child: Icon(_getIcon(activity.type), color: _getIconColor(activity.type)),
                  ),
                  title: Text(
                    activity.title,
                    style: TextStyle(
                      fontWeight: activity.isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(activity.message),
                      const SizedBox(height: 8),
                      Text(
                        _formatDate(activity.timestamp),
                        style: const TextStyle(fontSize: 10, color: AppTheme.textLight),
                      ),
                    ],
                  ),
                  onTap: () {
                    if (!activity.isRead) {
                      context.read<ActivityProvider>().markAsRead(activity.id);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'group_formed': return Icons.group_add;
      case 'faculty_approved': return Icons.verified_user;
      case 'feedback_received': return Icons.feedback;
      default: return Icons.notifications;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'group_formed': return const Color(0xFF3B82F6);
      case 'faculty_approved': return const Color(0xFF10B981);
      case 'feedback_received': return const Color(0xFFF59E0B);
      default: return AppTheme.primary;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
