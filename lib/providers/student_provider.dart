import 'package:flutter/foundation.dart';
import '../models/group.dart';
import '../repositories/group_repository.dart';
import '../repositories/file_repository.dart';

class StudentProvider extends ChangeNotifier {
  final GroupRepository _groupRepository;
  final FileRepository _fileRepository;

  StudentProvider({
    GroupRepository? groupRepository,
    FileRepository? fileRepository,
  })  : _groupRepository = groupRepository ?? GroupRepository(),
        _fileRepository = fileRepository ?? FileRepository();

  Stream<GroupModel?> get myGroupStream => _groupRepository.groupForCurrentStudent();

  Future<void> uploadFile({
    required String fileName,
    required String groupId,
    required String type,
  }) async {
    await _fileRepository.addFileRecord(
      fileName: fileName,
      groupId: groupId,
      type: type,
    );
  }
}
