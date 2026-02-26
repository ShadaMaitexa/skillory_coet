import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../repositories/user_repository.dart';

class AdminProvider extends ChangeNotifier {
  final UserRepository _userRepository;

  AdminProvider({UserRepository? userRepository})
      : _userRepository = userRepository ?? UserRepository();

  Stream<int> get totalUsersCountStream =>
      _userRepository.getTotalUsersCountStream();

  Stream<int> get pendingFacultyCountStream =>
      _userRepository.getPendingFacultyCountStream();

  Stream<List<AppUser>> get pendingFacultyStream =>
      _userRepository.getPendingFacultyStream();

  Stream<List<AppUser>> get allUsersStream =>
      _userRepository.getAllUsersStream();

  Future<void> approveFaculty({
    required String uid,
    required String specificRole,
  }) {
    return _userRepository.approveFaculty(
      uid: uid,
      specificRole: specificRole,
    );
  }

  Future<void> autoFormGroups({
    required String department,
    required String semester,
  }) {
    return _userRepository.autoFormGroupsForDepartmentSemester(
      department: department,
      semester: semester,
    );
  }
}

