import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/feedback.dart';

class FeedbackRepository {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  FeedbackRepository();

  Stream<List<FeedbackModel>> getFeedbackForGroup(String groupId) {
    return _firestore
        .collection('feedback')
        .where('groupId', isEqualTo: groupId)
     
        .snapshots()
        .map((snap) => snap.docs.map((doc) => FeedbackModel.fromDocument(doc)).toList());
  }

  Future<void> saveFeedback({
    required String groupId,
    required String text,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final name = user.displayName ?? user.email ?? 'Faculty';

    await _firestore.collection('feedback').add({
      'groupId': groupId,
      'facultyId': user.uid,
      'facultyName': name,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
