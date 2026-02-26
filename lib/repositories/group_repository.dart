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
}

