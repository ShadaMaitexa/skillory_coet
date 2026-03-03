import 'package:cloud_firestore/cloud_firestore.dart';

/// Loads the list of departments (with their semesters) managed by admin.
/// Each entry has: { 'name': String, 'semesters': List<String> }
Stream<List<Map<String, dynamic>>> departmentsStream() {
  return FirebaseFirestore.instance
      .collection('departments')
      .orderBy('name')
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => d.data() as Map<String, dynamic>)
          .toList());
}
