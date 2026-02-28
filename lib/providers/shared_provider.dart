import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../models/feedback.dart';
import '../repositories/chat_repository.dart';
import '../repositories/feedback_repository.dart';

class SharedProvider extends ChangeNotifier {
  final ChatRepository _chatRepository;
  final FeedbackRepository _feedbackRepository;

  SharedProvider({
    ChatRepository? chatRepository,
    FeedbackRepository? feedbackRepository,
  })  : _chatRepository = chatRepository ?? ChatRepository(),
        _feedbackRepository = feedbackRepository ?? FeedbackRepository();

  Stream<List<ChatMessage>> messagesForGroup(String groupId) =>
      _chatRepository.getMessagesForGroup(groupId);

  Future<void> sendMessage(String text, {String? groupId, String? receiverId}) =>
      _chatRepository.sendMessage(text: text, groupId: groupId, receiverId: receiverId);

  Stream<List<FeedbackModel>> feedbackForGroup(String groupId) =>
      _feedbackRepository.getFeedbackForGroup(groupId);

  Future<void> sendFeedback(String groupId, String text) =>
      _feedbackRepository.saveFeedback(groupId: groupId, text: text);
}
