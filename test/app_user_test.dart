import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_dev_formative_assignment2/core/constants/user_role.dart';
import 'package:mobile_dev_formative_assignment2/models/app_user.dart';

void main() {
  test('AppUser round-trips its Firestore representation', () {
    final createdAt = DateTime.utc(2026, 11, 7, 17, 0);
    final user = AppUser(
      uid: 'user-1',
      name: 'Amina',
      email: 'amina@alustudent.com',
      role: UserRole.student,
      createdAt: createdAt,
    );

    final restored = AppUser.fromMap(user.toMap(), user.uid);

    expect(restored.uid, user.uid);
    expect(restored.name, user.name);
    expect(restored.email, user.email);
    expect(restored.role, UserRole.student);
    expect(restored.createdAt.toUtc(), createdAt);
    expect(user.toMap()['createdAt'], isA<Timestamp>());
  });
}
