import 'package:flutter/foundation.dart';
import '../repositories/activity_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ActivityProvider extends ChangeNotifier {
  final ActivityRepository _activityRepository = ActivityRepository();

  Stream<List<ActivityModel>> get myActivitiesStream {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);
    return _activityRepository.getActivities(user.uid);
  }

  Future<void> markAsRead(String id) async {
    await _activityRepository.markAsRead(id);
    notifyListeners();
  }

  Future<void> notifyUser({
    required String userId,
    required String title,
    required String message,
    required String type,
  }) async {
    await _activityRepository.sendNotification(
      userId: userId,
      title: title,
      message: message,
      type: type,
    );
  }
}
