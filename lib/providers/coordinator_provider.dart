import 'package:flutter/foundation.dart';

import '../models/group.dart';
import '../repositories/group_repository.dart';

class CoordinatorProvider extends ChangeNotifier {
  final GroupRepository _groupRepository;

  CoordinatorProvider({GroupRepository? groupRepository})
      : _groupRepository = groupRepository ?? GroupRepository();

  Stream<List<GroupModel>> get myGroupsStream =>
      _groupRepository.groupsForCurrentCoordinator();
}

