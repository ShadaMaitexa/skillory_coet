import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String id;
  final String groupId;
  final String facultyId;
  final String facultyName;
  final String text;
  final Timestamp timestamp;

  FeedbackModel({
    required this.id,
    required this.groupId,
    required this.facultyId,
    required this.facultyName,
    required this.text,
    required this.timestamp,
  });

  factory FeedbackModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FeedbackModel(
      id: doc.id,
      groupId: data['groupId'] ?? '',
      facultyId: data['facultyId'] ?? '',
      facultyName: data['facultyName'] ?? '',
      text: data['text'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'facultyId': facultyId,
      'facultyName': facultyName,
      'text': text,
      'timestamp': timestamp,
    };
  }
}
