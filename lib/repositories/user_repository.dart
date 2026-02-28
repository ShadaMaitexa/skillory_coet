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

  Stream<List<AppUser>> getApprovedFacultyStream() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'Faculty')
        .where('status', isEqualTo: 'approved')
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

    if (candidates.length < 5) return;

    candidates.sort((a, b) {
      final aLangs = (a.data()['programmingLanguages'] as List?)?.join(',') ?? '';
      final bLangs = (b.data()['programmingLanguages'] as List?)?.join(',') ?? '';
      return aLangs.compareTo(bLangs);
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
