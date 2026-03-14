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
                (doc) => AppUser.fromDocument(
                    doc as DocumentSnapshot<Map<String, dynamic>>),
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
                (doc) => AppUser.fromDocument(
                    doc as DocumentSnapshot<Map<String, dynamic>>),
              )
              .toList(),
        );
  }

  Stream<List<AppUser>> getApprovedFacultyStream() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'Faculty')
        .where('status', isEqualTo: 'approved')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => AppUser.fromDocument(
                    doc as DocumentSnapshot<Map<String, dynamic>>),
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

  Future<void> autoFormGroupsForDepartmentSemester({
    required String department,
    required String semester,
    required int groupLimit,
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

    if (candidates.length < groupLimit) {
      return;
    }

    // ── Skill-based scoring for balanced group formation ──
    // Score = codingProficiency (0-2) + domainInterests count + tools count
    int skillScore(Map<String, dynamic> data) {
      int score = 0;
      final prof = data['codingProficiency'] as String?;
      if (prof == 'Advanced') {
        score += 3;
      } else if (prof == 'Intermediate') {
        score += 2;
      } else if (prof == 'Beginner') {
        score += 1;
      }

      final domains = (data['domainInterests'] as List?)?.length ?? 0;
      score += domains;

      final langs = (data['programmingLanguages'] as List?)?.length ?? 0;
      score += langs;

      final tools =
          (data['toolsUsed'] as List?)?.where((t) => t != 'None').length ?? 0;
      score += tools;

      if (data['hasWorkedOnProject'] == true) score += 2;
      return score;
    }

    // Sort by skill score descending
    candidates
        .sort((a, b) => skillScore(b.data()).compareTo(skillScore(a.data())));

    // Distribute using snake/round-robin pattern for skill diversity:
    // Group them into groups of $groupLimit by round-robin so each group gets
    // a mix of high, medium, and low scorers.
    final groupCount = candidates.length ~/ groupLimit;
    final List<List<QueryDocumentSnapshot<Map<String, dynamic>>>> groups =
        List.generate(groupCount, (_) => []);

    for (int i = 0; i < candidates.length && i < groupCount * groupLimit; i++) {
      // Snake: 0,1,2,...,groupCount-1,groupCount-1,...,1,0,0,1,...
      final roundIndex = i ~/ groupCount;
      final posInRound = i % groupCount;
      final groupIdx =
          roundIndex.isEven ? posInRound : (groupCount - 1 - posInRound);
      groups[groupIdx].add(candidates[i]);
    }

    // ── Find Coordinator for this department ──
    String coordinatorId = '';
    final coordSnap = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'Faculty')
        .where('specificRole', isEqualTo: 'Coordinator')
        .where('department', isEqualTo: department)
        .limit(1)
        .get();
    
    if (coordSnap.docs.isNotEmpty) {
      coordinatorId = coordSnap.docs.first.id;
    }

    final batch = _firestore.batch();

    for (int g = 0; g < groups.length; g++) {
      final slice = groups[g];
      if (slice.length < groupLimit) continue; // skip incomplete groups

      final memberIds = slice.map((d) => d.id).toList();
      final groupDoc = _firestore.collection('groups').doc();

      batch.set(groupDoc, {
        'name': '$department-$semester-Group-${g + 1}',
        'department': department,
        'semester': semester,
        'memberIds': memberIds,
        'guideId': '',
        'coordinatorId': coordinatorId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      for (final studentDoc in slice) {
        batch.update(studentDoc.reference, {
          'groupId': groupDoc.id,
        });
      }
    }

    await batch.commit();

    // ── Send Notifications ──
    for (int g = 0; g < groups.length; g++) {
      final slice = groups[g];
      if (slice.length < groupLimit) continue;
      final groupName = '$department-$semester-Group-${g + 1}';

      for (final student in slice) {
        await _firestore.collection('activities').add({
          'userId': student.id,
          'title': 'Group Formed!',
          'message': 'You have been assigned to $groupName. Check your dashboard for details.',
          'type': 'group_formed',
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        });
      }
    }

    if (coordinatorId.isNotEmpty) {
      await _firestore.collection('activities').add({
        'userId': coordinatorId,
        'title': 'Groups Formed',
        'message': 'New groups formed for $department, Semester $semester.',
        'type': 'group_formed',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    }
  }

  Stream<AppUser?> getUserStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map(
          (snapshot) => snapshot.exists
              ? AppUser.fromDocument(snapshot)
              : null,
        );
  }

  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }
}
