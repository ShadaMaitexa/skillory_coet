import 'package:cloud_firestore/cloud_firestore.dart';

class Questionnaire {
  final String id;
  final String title;
  final String description;
  final List<String> questions;
  final Timestamp created;

  Questionnaire({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    required this.created,
  });

  factory Questionnaire.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Questionnaire(
      id: doc.id,
      title: data['title'] ?? 'No Title',
      description: data['description'] ?? '',
      questions: (data['questions'] as List<dynamic>? ?? []).map((q) => q.toString()).toList(),
      created: data['created'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'questions': questions,
      'created': created,
    };
  }
}
