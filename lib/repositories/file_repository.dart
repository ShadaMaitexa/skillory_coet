import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/file_meta.dart';

class FileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FileRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Stream<List<FileMeta>> getFilesForGroup(String groupId) {
    return _firestore
        .collection('files')
        .where('groupId', isEqualTo: groupId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => FileMeta.fromDocument(doc)).toList());
  }

  Future<void> addFileRecord({
    required String fileName,
    required String groupId,
    required String type,
    String? url,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('files').add({
      'fileName': fileName,
      'groupId': groupId,
      'uploadedBy': user.uid,
      'timestamp': FieldValue.serverTimestamp(),
      'type': type,
      'url': url,
    });
  }
}
