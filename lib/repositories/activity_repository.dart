import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class ActivityModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type; // e.g., 'group_formed', 'faculty_approved', 'feedback_received'
  final DateTime timestamp;
  final bool isRead;

  ActivityModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });

  factory ActivityModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ActivityModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: data['type'] ?? 'general',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': isRead,
    };
  }
}

class ActivityRepository {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  Stream<List<ActivityModel>> getActivities(String userId) {
    return _firestore
        .collection('activities')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => ActivityModel.fromDocument(doc)).toList());
  }

  Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
  }) async {
    await _firestore.collection('activities').add({
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  Future<void> markAsRead(String activityId) async {
    await _firestore.collection('activities').doc(activityId).update({'isRead': true});
  }
}
