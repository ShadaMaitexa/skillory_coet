import 'package:flutter/foundation.dart';

import '../models/group.dart';
import '../repositories/group_repository.dart';

class GuideProvider extends ChangeNotifier {
  final GroupRepository _groupRepository;

  GuideProvider({GroupRepository? groupRepository})
      : _groupRepository = groupRepository ?? GroupRepository();

  Stream<List<GroupModel>> get myGroupsStream =>
      _groupRepository.groupsForCurrentGuide();
}

