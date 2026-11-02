import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_keys.dart';
import '../core/constants/user_role.dart';
import '../models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final firebaseUser = userCredential.user;

    if (firebaseUser == null) {
      throw StateError('Firebase did not return a user after registration.');
    }

    final appUser = AppUser(
      uid: firebaseUser.uid,
      name: name,
      email: email,
      role: role,
      createdAt: DateTime.now(),
    );

    try {
      await _firestore
          .collection(FirestoreKeys.users)
          .doc(appUser.uid)
          .set(appUser.toMap());
    } catch (_) {
      await firebaseUser.delete();
      rethrow;
    }

    return appUser;
  }

  Future<User?> signUp(String email, String password) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  Future<User?> signIn(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}