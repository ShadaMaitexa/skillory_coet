import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_theme.dart';
import '../../providers/coordinator_provider.dart';
import '../../models/questionnaire.dart';
import 'add_questionnaire_screen.dart';

class ViewQuestionnairesScreen extends StatelessWidget {
  const ViewQuestionnairesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Questionnaires'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppTheme.dark),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddQuestionnaireScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Questionnaire>>(
        stream: context.watch<CoordinatorProvider>().questionnairesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final questionnaires = snapshot.data ?? [];

          if (questionnaires.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.quiz_outlined, size: 60.sp, color: AppTheme.textLight.withOpacity(0.5)),
                  SizedBox(height: 16.h),
                  const Text('No questionnaires added yet.'),
                  SizedBox(height: 24.h),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddQuestionnaireScreen()),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add First Questionnaire'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(20.r),
            itemCount: questionnaires.length,
            itemBuilder: (context, index) {
              final q = questionnaires[index];
              return Container(
                margin: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16.r),
                  title: Text(q.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4.h),
                      Text(q.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                      SizedBox(height: 8.h),
                      Text('${q.questions.length} questions', style: TextStyle(color: AppTheme.primary, fontSize: 12.sp)),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Could add a details/edit view here
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
