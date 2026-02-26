import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<AppUser>> getAllUsersStream() {
    return _firestore.collection('users').snapshots().map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    AppUser.fromDocument(doc as DocumentSnapshot<Map<String, dynamic>>),
              )
              .toList(),
        );
  }

  Stream<List<AppUser>> getPendingFacultyStream() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'Faculty')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    AppUser.fromDocument(doc as DocumentSnapshot<Map<String, dynamic>>),
              )
              .toList(),
        );
  }

  Stream<int> getTotalUsersCountStream() {
    return _firestore.collection('users').snapshots().map(
          (snapshot) => snapshot.docs.length,
        );
  }

  Stream<int> getPendingFacultyCountStream() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'Faculty')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.length,
        );
  }

  Future<void> approveFaculty({
    required String uid,
    required String specificRole,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'status': 'approved',
      'specificRole': specificRole,
    });
  }

  /// Auto-form groups of 5 students within the same department and semester.
  /// Students must have role "Student" and not already be in a group (groupId null/empty).
  Future<void> autoFormGroupsForDepartmentSemester({
    required String department,
    required String semester,
  }) async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'Student')
        .where('department', isEqualTo: department)
        .where('semester', isEqualTo: semester)
        .get();

    final candidates = <QueryDocumentSnapshot<Map<String, dynamic>>>[];

    for (final doc in querySnapshot.docs) {
      final data = doc.data();
      final groupId = data['groupId'] as String?;
      if (groupId == null || groupId.isEmpty) {
        candidates.add(doc);
      }
    }

    if (candidates.length < 5) {
      // Not enough students to form even a single group of 5.
      return;
    }

    // Simple skill-based ordering: sort by technicalSkills string so that
    // students with similar skill text are closer together when chunking.
    candidates.sort((a, b) {
      final aSkills = (a.data()['technicalSkills'] as String? ?? '').toLowerCase();
      final bSkills = (b.data()['technicalSkills'] as String? ?? '').toLowerCase();
      return aSkills.compareTo(bSkills);
    });

    final batch = _firestore.batch();
    int groupIndex = 1;

    for (int i = 0; i + 4 < candidates.length; i += 5) {
      final slice = candidates.sublist(i, i + 5);
      final memberIds = slice.map((d) => d.id).toList();

      final groupDoc = _firestore.collection('groups').doc();

      batch.set(groupDoc, {
        'name': '$department-$semester-Group-$groupIndex',
        'department': department,
        'semester': semester,
        'memberIds': memberIds,
        'guideId': '',
        'coordinatorId': '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      for (final studentDoc in slice) {
        batch.update(studentDoc.reference, {
          'groupId': groupDoc.id,
        });
      }

      groupIndex++;
    }

    await batch.commit();
  }
}

