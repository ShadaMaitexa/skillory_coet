import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Loads the list of departments (with their semesters) managed by admin.
/// Each entry has: { 'name': String, 'semesters': List<String> }
Stream<List<Map<String, dynamic>>> departmentsStream() {
  if (Firebase.apps.isEmpty) return Stream.value([]);
  
  try {
    return FirebaseFirestore.instance
        .collection('departments')
        .orderBy('name')
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              return {
                ...data,
                'name': data['name'] ?? d.id, // Fallback to doc ID if name field is missing
              };
            }).toList());
  } catch (e) {
    return Stream.value([]);
  }
}
