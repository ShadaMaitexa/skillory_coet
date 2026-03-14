import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/questionnaire.dart';

class QuestionnaireRepository {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  QuestionnaireRepository();

  Stream<List<Questionnaire>> getQuestionnaires() {
    return _firestore
        .collection('questionnaires')
    
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
