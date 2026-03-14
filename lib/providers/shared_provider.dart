import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';
import '../models/chat_message.dart';
import '../models/feedback.dart';
import '../repositories/chat_repository.dart';
import '../repositories/feedback_repository.dart';
import '../repositories/user_repository.dart';
import '../repositories/auth_repository.dart';

class SharedProvider extends ChangeNotifier {
  final ChatRepository _chatRepository;
  final FeedbackRepository _feedbackRepository;
  final UserRepository _userRepository;
  final AuthRepository _authRepository;

  SharedProvider({
    ChatRepository? chatRepository,
    FeedbackRepository? feedbackRepository,
    UserRepository? userRepository,
    AuthRepository? authRepository,
  })  : _chatRepository = chatRepository ?? ChatRepository(),
        _feedbackRepository = feedbackRepository ?? FeedbackRepository(),
        _userRepository = userRepository ?? UserRepository(),
        _authRepository = authRepository ?? AuthRepository();

  Stream<List<ChatMessage>> messagesForGroup(String groupId) =>
      _chatRepository.getMessagesForGroup(groupId);

  Future<void> sendMessage(String text, {String? groupId, String? receiverId}) =>
      _chatRepository.sendMessage(text: text, groupId: groupId, receiverId: receiverId);

  Stream<List<FeedbackModel>> feedbackForGroup(String groupId) =>
      _feedbackRepository.getFeedbackForGroup(groupId);

  Future<void> sendFeedback(String groupId, String text) =>
      _feedbackRepository.saveFeedback(groupId: groupId, text: text);

  Stream<AppUser?> getUserStream(String? uid) => _userRepository.getUserStream(uid);

  Future<void> updateProfile(String uid, Map<String, dynamic> data) =>
      _userRepository.updateProfile(uid, data);

  // Auth methods
  Future<UserCredential> signUp({required String email, required String password}) =>
      _authRepository.signUp(email: email, password: password);

  Future<UserCredential> signIn({required String email, required String password}) =>
      _authRepository.signIn(email: email, password: password);

  Future<void> signOut() => _authRepository.signOut();

  Future<void> sendPasswordResetEmail(String email) =>
      _authRepository.sendPasswordResetEmail(email);

  Future<void> saveUser(AppUser user) => _authRepository.saveUser(user);

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDoc(String uid) =>
      _authRepository.getUserDoc(uid);

  Future<int> getStudentCount(String dept, String sem) =>
      _authRepository.getStudentCount(dept, sem);

  Future<DocumentSnapshot<Map<String, dynamic>>> getDepartmentDoc(String deptId) =>
      _authRepository.getDepartmentDoc(deptId);
}
