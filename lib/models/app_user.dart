import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final String status;
  final String? specificRole;
  final String? proofUrl;
  
  // Student Specific Fields
  final String? rollNumber;
  final String? department;
  final String? semester;
  final String? groupId;
  
  // Section 2: Technical Skills
  final List<String>? programmingLanguages;
  final String? codingProficiency;
  
  // Section 3: Domain Knowledge
  final List<String>? domainInterests;
  final bool? hasWorkedOnProject;
  final List<String>? previousProjectRoles;
  
  // Section 4: Soft Skills
  final String? teamComfort;
  final List<String>? preferredTeamRoles;
  final String? communicationSkills;
  
  // Section 5: Tools
  final List<String>? toolsUsed;
  final bool? openToLearningNewTools;

  final Timestamp? createdAt;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    this.specificRole,
    this.proofUrl,
    this.rollNumber,
    this.department,
    this.semester,
    this.groupId,
    this.programmingLanguages,
    this.codingProficiency,
    this.domainInterests,
    this.hasWorkedOnProject,
    this.previousProjectRoles,
    this.teamComfort,
    this.preferredTeamRoles,
    this.communicationSkills,
    this.toolsUsed,
    this.openToLearningNewTools,
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
      proofUrl: data['proofUrl'] as String?,
      rollNumber: data['rollNumber'] as String?,
      department: data['department'] as String?,
      semester: data['semester'] as String?,
      groupId: data['groupId'] as String?,
      programmingLanguages: (data['programmingLanguages'] as List?)?.map((e) => e.toString()).toList(),
      codingProficiency: data['codingProficiency'] as String?,
      domainInterests: (data['domainInterests'] as List?)?.map((e) => e.toString()).toList(),
      hasWorkedOnProject: data['hasWorkedOnProject'] as bool?,
      previousProjectRoles: (data['previousProjectRoles'] as List?)?.map((e) => e.toString()).toList(),
      teamComfort: data['teamComfort'] as String?,
      preferredTeamRoles: (data['preferredTeamRoles'] as List?)?.map((e) => e.toString()).toList(),
      communicationSkills: data['communicationSkills'] as String?,
      toolsUsed: (data['toolsUsed'] as List?)?.map((e) => e.toString()).toList(),
      openToLearningNewTools: data['openToLearningNewTools'] as bool?,
      createdAt: data['createdAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'status': status,
      'specificRole': specificRole,
      'proofUrl': proofUrl,
      'rollNumber': rollNumber,
      'department': department,
      'semester': semester,
      'groupId': groupId,
      'programmingLanguages': programmingLanguages,
      'codingProficiency': codingProficiency,
      'domainInterests': domainInterests,
      'hasWorkedOnProject': hasWorkedOnProject,
      'previousProjectRoles': previousProjectRoles,
      'teamComfort': teamComfort,
      'preferredTeamRoles': preferredTeamRoles,
      'communicationSkills': communicationSkills,
      'toolsUsed': toolsUsed,
      'openToLearningNewTools': openToLearningNewTools,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}
