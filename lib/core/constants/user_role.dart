enum UserRole {
  student('student', 'Student'),
  teacher('teacher', 'Teacher');

  const UserRole(this.value, this.label);

  final String value; // what is stored in Firestore: never change it
  final String label; // what the UI shows: change freely

  static UserRole fromString(String? value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.student,
    );
  }
}
