import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_keys.dart';
import '../core/constants/user_role.dart';
import '../models/app_user.dart';

class AuthUser {
  const AuthUser({required this.uid, this.displayName});

  final String uid;
  final String? displayName;
}

class AuthService {
  static const String allowedEmailDomain = 'alustudent.com';

  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<AuthUser?> get authStateChanges {
    return _auth.authStateChanges().map(_toAuthUser);
  }

  AuthUser? get currentUser => _toAuthUser(_auth.currentUser);

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    if (role == UserRole.student && !isAluEmail(email)) {
      throw const FormatException(
        'Student accounts must use an ALU email ending in @alustudent.com.',
      );
    }

    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final firebaseUser = userCredential.user;

    if (firebaseUser == null) {
      throw StateError('Firebase did not return a user after registration.');
    }

    if (role == UserRole.student) {
      await firebaseUser.sendEmailVerification();
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

  static bool isAluEmail(String email) {
    final normalizedEmail = email.trim().toLowerCase();
    final atIndex = normalizedEmail.indexOf('@');
    return atIndex > 0 &&
        atIndex == normalizedEmail.lastIndexOf('@') &&
        normalizedEmail.substring(atIndex + 1) == allowedEmailDomain;
  }

  Future<User?> signUp(String email, String password) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = userCredential.user;
    if (user != null) {
      await user.sendEmailVerification();
    }
    return user;
  }

  Future<User?> signIn(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  Future<void> resendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No signed-in user was found.');
    }
    await user.sendEmailVerification();
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> updatePassword(String password) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No signed-in user was found.');
    }
    await user.updatePassword(password);
  }

  AuthUser? _toAuthUser(User? user) {
    if (user == null) return null;
    return AuthUser(uid: user.uid, displayName: user.displayName);
  }
}