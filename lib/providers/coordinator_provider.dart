import 'package:flutter/foundation.dart';

import '../models/group.dart';
import '../repositories/user_repository.dart';

class CoordinatorProvider extends ChangeNotifier {
  final GroupRepository _groupRepository;
  final QuestionnaireRepository _questionnaireRepository;
  final UserRepository _userRepository;

  CoordinatorProvider({
    GroupRepository? groupRepository,
    QuestionnaireRepository? questionnaireRepository,
    UserRepository? userRepository,
  })  : _groupRepository = groupRepository ?? GroupRepository(),
        _questionnaireRepository =
            questionnaireRepository ?? QuestionnaireRepository(),
        _userRepository = userRepository ?? UserRepository();

  Stream<List<GroupModel>> get myGroupsStream =>
      _groupRepository.groupsForCurrentCoordinator();

  Stream<List<GroupModel>> get allGroupsStream =>
      _groupRepository.allGroupsStream();

  Future<void> addQuestionnaire({
    required String title,
    required String description,
    required List<String> questions,
  }) =>
      _questionnaireRepository.saveQuestionnaire(
        title: title,
        description: description,
        questions: questions,
      );

  Stream<List<AppUser>> get approvedFacultyStream =>
      _userRepository.getApprovedFacultyStream();

  Future<void> assignGuideToGroup(String groupId, String guideId) =>
      _groupRepository.assignGuideToGroup(groupId, guideId);
}

