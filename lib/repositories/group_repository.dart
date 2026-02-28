import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/group.dart';

class GroupRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  GroupRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Stream<List<GroupModel>> groupsForCurrentCoordinator() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream<List<GroupModel>>.empty();
    }
    return _firestore
        .collection('groups')
        .where('coordinatorId', isEqualTo: user.uid)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (doc) => GroupModel.fromDocument(
                  doc as DocumentSnapshot<Map<String, dynamic>>,
                ),
              )
              .toList(),
        );
  }

  Stream<List<GroupModel>> groupsForCurrentGuide() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream<List<GroupModel>>.empty();
    }
    return _firestore
        .collection('groups')
        .where('guideId', isEqualTo: user.uid)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (doc) => GroupModel.fromDocument(
                  doc as DocumentSnapshot<Map<String, dynamic>>,
                ),
              )
              .toList(),
        );
  }

  Stream<List<GroupModel>> allGroupsStream() {
    return _firestore.collection('groups').snapshots().map(
          (snap) => snap.docs
              .map(
                (doc) => GroupModel.fromDocument(
                  doc as DocumentSnapshot<Map<String, dynamic>>,
                ),
              )
              .toList(),
        );
  }

  Stream<GroupModel?> groupForCurrentStudent() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(null);
    }
    return _firestore
        .collection('groups')
        .where('memberIds', arrayContains: user.uid)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return null;
      return GroupModel.fromDocument(
        snap.docs.first as DocumentSnapshot<Map<String, dynamic>>,
      );
    });
  }

  Future<void> assignGuideToGroup(String groupId, String guideId) async {
    await _firestore.collection('groups').doc(groupId).update({
      'guideId': guideId,
    });
  }

  Future<void> updateGroupStatus(String groupId, String status) async {
    await _firestore.collection('groups').doc(groupId).update({
      'status': status,
    });
  }
}

