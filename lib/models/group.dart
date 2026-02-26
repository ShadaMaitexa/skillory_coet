import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  final String id;
  final String name;
  final String department;
  final String semester;
  final List<String> memberIds;
  final String guideId;
  final String coordinatorId;
  final Timestamp? createdAt;

  const GroupModel({
    required this.id,
    required this.name,
    required this.department,
    required this.semester,
    required this.memberIds,
    required this.guideId,
    required this.coordinatorId,
    this.createdAt,
  });

  factory GroupModel.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return GroupModel(
      id: doc.id,
      name: (data['name'] as String?) ?? 'Unnamed Group',
      department: (data['department'] as String?) ?? 'Unknown',
      semester: (data['semester'] as String?) ?? 'Unknown',
      memberIds: (data['memberIds'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      guideId: (data['guideId'] as String?) ?? '',
      coordinatorId: (data['coordinatorId'] as String?) ?? '',
      createdAt: data['createdAt'] as Timestamp?,
    );
  }
}

