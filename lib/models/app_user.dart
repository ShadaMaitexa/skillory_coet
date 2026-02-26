import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final String status;
  final String? specificRole;
  final String? department;
  final String? semester;
  final String? groupId;
  final String? technicalSkills;
  final String? interests;
  final bool? hasExperience;
  final Timestamp? createdAt;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    this.specificRole,
    this.department,
    this.semester,
    this.groupId,
    this.technicalSkills,
    this.interests,
    this.hasExperience,
    this.createdAt,
  });

  factory AppUser.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return AppUser(
      id: doc.id,
      name: (data['name'] as String?) ?? 'Unnamed',
      email: (data['email'] as String?) ?? '',
      role: (data['role'] as String?) ?? 'Student',
      status: (data['status'] as String?) ?? 'pending',
      specificRole: data['specificRole'] as String?,
      department: data['department'] as String?,
      semester: data['semester'] as String?,
      groupId: data['groupId'] as String?,
      technicalSkills: data['technicalSkills'] as String?,
      interests: data['interests'] as String?,
      hasExperience: data['hasExperience'] as bool?,
      createdAt: data['createdAt'] as Timestamp?,
    );
  }
}

