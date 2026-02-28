import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_message.dart';

class ChatRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ChatRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Stream<List<ChatMessage>> getMessagesForGroup(String groupId) {
    return _firestore
        .collection('messages')
        .where('groupId', isEqualTo: groupId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ChatMessage.fromDocument(doc)).toList());
  }

  Future<void> sendMessage({
    required String text,
    String? groupId,
    String? receiverId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final name = user.displayName ?? user.email ?? 'Unknown';

    await _firestore.collection('messages').add({
      'senderId': user.uid,
      'senderName': name,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'groupId': groupId,
      'receiverId': receiverId,
    });
  }
}
