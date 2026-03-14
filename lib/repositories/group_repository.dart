import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/group.dart';

class GroupRepository {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  GroupRepository();

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
    // 1. Update the group doc
    await _firestore.collection('groups').doc(groupId).update({
      'guideId': guideId,
    });

    // 2. Fetch group info for notifications
    final groupDoc = await _firestore.collection('groups').doc(groupId).get();
    if (!groupDoc.exists) return;
    final group = GroupModel.fromDocument(groupDoc);

    // 3. Notify the Guide
    await _firestore.collection('activities').add({
      'userId': guideId,
      'title': 'New Group Assigned',
      'message': 'You have been assigned as a guide for ${group.name}.',
      'type': 'group_assigned',
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    // 4. Notify all Students in the group
    for (final studentId in group.memberIds) {
      await _firestore.collection('activities').add({
        'userId': studentId,
        'title': 'Guide Assigned',
        'message': 'A guide has been assigned to your group (${group.name}).',
        'type': 'group_assigned',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    }
  }

  Future<void> updateGroupStatus(String groupId, String status) async {
    await _firestore.collection('groups').doc(groupId).update({
      'status': status,
    });
  }

  Future<void> updateProjectDetails({
    required String groupId,
    required String title,
    required String description,
    required List<String> techStack,
  }) async {
    await _firestore.collection('groups').doc(groupId).update({
      'projectTitle': title,
      'projectDescription': description,
      'projectTechStack': techStack,
    });
  }
}

