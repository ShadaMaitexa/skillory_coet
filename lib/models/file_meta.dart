import 'package:cloud_firestore/cloud_firestore.dart';

class FileMeta {
  final String id;
  final String fileName;
  final String groupId;
  final String uploadedBy;
  final Timestamp timestamp;
  final String? url; // If uploading to Storage
  final String type; // e.g., 'pdf', 'image', 'word'

  FileMeta({
    required this.id,
    required this.fileName,
    required this.groupId,
    required this.uploadedBy,
    required this.timestamp,
    this.url,
    required this.type,
  });

  factory FileMeta.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FileMeta(
      id: doc.id,
      fileName: data['fileName'] ?? 'No name',
      groupId: data['groupId'] ?? '',
      uploadedBy: data['uploadedBy'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      url: data['url'],
      type: data['type'] ?? 'unknown',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fileName': fileName,
      'groupId': groupId,
      'uploadedBy': uploadedBy,
      'timestamp': timestamp,
      'url': url,
      'type': type,
    };
  }
}
