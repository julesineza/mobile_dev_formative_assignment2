import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_keys.dart';

class UserService {
  UserService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<String?> watchUserName(String uid) {
    return _firestore
        .collection(FirestoreKeys.users)
        .doc(uid)
        .snapshots()
        .map((snapshot) {
          final data = snapshot.data();
          return (data?[FirestoreKeys.name] as String?)?.trim();
        });
  }
}
