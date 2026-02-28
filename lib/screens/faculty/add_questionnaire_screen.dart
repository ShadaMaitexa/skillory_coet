import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/coordinator_provider.dart';

class AddQuestionnaireScreen extends StatefulWidget {
  const AddQuestionnaireScreen({super.key});

  @override
  State<AddQuestionnaireScreen> createState() => _AddQuestionnaireScreenState();
}

class _AddQuestionnaireScreenState extends State<AddQuestionnaireScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final List<TextEditingController> _questionControllers = [TextEditingController()];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    for (var c in _questionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addQuestionField() {
    setState(() {
      _questionControllers.add(TextEditingController());
    });
  }

  Future<void> _publish() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final questions = _questionControllers
        .map((c) => c.text.trim())
        .where((q) => q.isNotEmpty)
        .toList();

    if (questions.isEmpty) return;

    await context.read<CoordinatorProvider>().addQuestionnaire(
          title: title,
          description: _descController.text.trim(),
          questions: questions,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Questionnaire published!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Add Questionnaire')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 32),
            const Text('Questions', style: TextStyle(fontWeight: FontWeight.bold)),
            ..._questionControllers.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextField(
                  controller: entry.value,
                  decoration: InputDecoration(labelText: 'Question ${entry.key + 1}'),
                ),
              );
            }),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _addQuestionField,
              icon: const Icon(Icons.add),
              label: const Text('Add Question'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _publish,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              child: const Text('Publish'),
            ),
          ],
        ),
      ),
    );
  }
}
