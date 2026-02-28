import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/feedback.dart';

class FeedbackRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FeedbackRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Stream<List<FeedbackModel>> getFeedbackForGroup(String groupId) {
    return _firestore
        .collection('feedback')
        .where('groupId', isEqualTo: groupId)
        .orderBy('timestamp', descending: true)
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
