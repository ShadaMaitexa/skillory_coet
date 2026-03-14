import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class AuthRepository {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  AuthRepository();

  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> saveUser(AppUser user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDoc(String uid) async {
    return _firestore.collection('users').doc(uid).get();
  }

  Future<int> getStudentCount(String department, String semester) async {
    final snap = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'Student')
        .where('department', isEqualTo: department)
        .where('semester', isEqualTo: semester)
        .get();
    return snap.docs.length;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getDepartmentDoc(String deptId) async {
    return _firestore.collection('departments').doc(deptId).get();
  }
}
