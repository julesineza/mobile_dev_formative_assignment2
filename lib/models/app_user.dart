import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firestore_keys.dart';
import '../core/constants/user_role.dart';

class AppUser {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  // Firestore -> Dart. The document ID comes separately from the data.
  factory AppUser.fromMap(Map<String, dynamic> map, String uid) {
    return AppUser(
      uid: uid,
      name: map[FirestoreKeys.name] as String? ?? '',
      email: map[FirestoreKeys.email] as String? ?? '',
      role: UserRole.fromString(map[FirestoreKeys.role] as String?),
      createdAt:
          (map[FirestoreKeys.createdAt] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Dart -> Firestore. No uid here: it is the document's name.
  Map<String, dynamic> toMap() {
    return {
      FirestoreKeys.name: name,
      FirestoreKeys.email: email,
      FirestoreKeys.role: role.value,
      FirestoreKeys.createdAt: Timestamp.fromDate(createdAt),
    };
  }

  AppUser copyWith({String? name, UserRole? role}) {
    return AppUser(
      uid: uid,
      name: name ?? this.name,
      email: email,
      role: role ?? this.role,
      createdAt: createdAt,
    );
  }
}