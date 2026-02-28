import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../models/chat_message.dart';
import '../models/feedback.dart';
import '../repositories/chat_repository.dart';
import '../repositories/feedback_repository.dart';
import '../repositories/user_repository.dart';

class SharedProvider extends ChangeNotifier {
  final ChatRepository _chatRepository;
  final FeedbackRepository _feedbackRepository;
  final UserRepository _userRepository;

  SharedProvider({
    ChatRepository? chatRepository,
    FeedbackRepository? feedbackRepository,
    UserRepository? userRepository,
  })  : _chatRepository = chatRepository ?? ChatRepository(),
        _feedbackRepository = feedbackRepository ?? FeedbackRepository(),
        _userRepository = userRepository ?? UserRepository();

  Stream<List<ChatMessage>> messagesForGroup(String groupId) =>
      _chatRepository.getMessagesForGroup(groupId);

  Future<void> sendMessage(String text, {String? groupId, String? receiverId}) =>
      _chatRepository.sendMessage(text: text, groupId: groupId, receiverId: receiverId);

  Stream<List<FeedbackModel>> feedbackForGroup(String groupId) =>
      _feedbackRepository.getFeedbackForGroup(groupId);

  Future<void> sendFeedback(String groupId, String text) =>
      _feedbackRepository.saveFeedback(groupId: groupId, text: text);

  Stream<AppUser?> getUserStream(String uid) => _userRepository.getUserStream(uid);

  Future<void> updateProfile(String uid, Map<String, dynamic> data) =>
      _userRepository.updateProfile(uid, data);
}
