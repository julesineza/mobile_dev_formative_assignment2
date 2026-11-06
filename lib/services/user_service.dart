import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_keys.dart';
import '../models/app_user.dart';

class UserService {
  UserService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<AppUser?> getUser(String uid) async {
    final snapshot = await _firestore
        .collection(FirestoreKeys.users)
        .doc(uid)
        .get();
    final data = snapshot.data();
    return data == null ? null : AppUser.fromMap(data, snapshot.id);
  }

  Stream<String?> watchUserName(String uid) {
    return _firestore.collection(FirestoreKeys.users).doc(uid).snapshots().map((
      snapshot,
    ) {
      final data = snapshot.data();
      return (data?[FirestoreKeys.name] as String?)?.trim();
    });
  }
}
