import '../../theme/app_theme.dart';
import '../../providers/coordinator_provider.dart';
import '../../models/group.dart';
import 'package:provider/provider.dart';

class CoordinatorMonitoringScreen extends StatelessWidget {
  const CoordinatorMonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Overall Monitoring'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'All Registered Teams',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.dark,
              ),
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<GroupModel>>(
              stream: context.watch<CoordinatorProvider>().allGroupsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final groups = snapshot.data ?? [];
                if (groups.isEmpty) {
                  return const Center(child: Text('No groups yet.'));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    final hasGuide = group.guideId.isNotEmpty;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: ListTile(
                        title: Text(group.name),
                        subtitle: Text(
                          hasGuide ? 'Guide assigned' : 'No Guide Assigned',
                        ),
                        trailing: Icon(
                          hasGuide
                              ? Icons.check_circle_outline
                              : Icons.warning_amber_rounded,
                          color: hasGuide ? Colors.green : Colors.orange,
                        ),
                        onTap: () {},
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
