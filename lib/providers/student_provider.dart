import 'package:flutter/foundation.dart';
import '../models/group.dart';
import '../repositories/group_repository.dart';
import '../repositories/file_repository.dart';
import '../repositories/questionnaire_repository.dart';
import '../models/questionnaire.dart';

class StudentProvider extends ChangeNotifier {
  final GroupRepository _groupRepository;
  final FileRepository _fileRepository;
  final QuestionnaireRepository _questionnaireRepository;

  StudentProvider({
    GroupRepository? groupRepository,
    FileRepository? fileRepository,
    QuestionnaireRepository? questionnaireRepository,
  })  : _groupRepository = groupRepository ?? GroupRepository(),
        _fileRepository = fileRepository ?? FileRepository(),
        _questionnaireRepository = questionnaireRepository ?? QuestionnaireRepository();

  Stream<GroupModel?> get myGroupStream => _groupRepository.groupForCurrentStudent();

  Stream<List<Questionnaire>> get questionnairesStream => _questionnaireRepository.getQuestionnaires();

  Future<void> uploadFile({
    required String fileName,
    required String groupId,
    required String type,
    String? url,
  }) async {
    await _fileRepository.addFileRecord(
      fileName: fileName,
      groupId: groupId,
      type: type,
      url: url,
    );
  }

  Future<void> updateProjectDetails({
    required String groupId,
    required String title,
    required String description,
    required List<String> techStack,
  }) async {
    await _groupRepository.updateProjectDetails(
      groupId: groupId,
      title: title,
      description: description,
      techStack: techStack,
    );
    notifyListeners();
  }
}
