import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/questionnaire.dart';

class QuestionnaireRepository {
  final FirebaseFirestore _firestore;

  QuestionnaireRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<Questionnaire>> getQuestionnaires() {
    return _firestore
        .collection('questionnaires')
        .orderBy('created', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Questionnaire.fromDocument(doc)).toList());
  }

  Future<void> saveQuestionnaire({
    required String title,
    required String description,
    required List<String> questions,
  }) async {
    await _firestore.collection('questionnaires').add({
      'title': title,
      'description': description,
      'questions': questions,
      'created': FieldValue.serverTimestamp(),
    });
  }
}
