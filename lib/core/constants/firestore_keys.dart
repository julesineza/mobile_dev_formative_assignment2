class FirestoreKeys {
  FirestoreKeys._();

  // Collections
  static const String users = 'users';
  static const String issues = 'issues';

  // Shared fields
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';

  // User fields
  static const String uid = 'uid';
  static const String name = 'name';
  static const String email = 'email';
  static const String role = 'role';

  // Issue fields
  static const String title = 'title';
  static const String description = 'description';
  static const String category = 'category';
  static const String department = 'department';
  static const String location = 'location';
  static const String status = 'status';
  static const String priority = 'priority';
  static const String imageUrl = 'imageUrl';
  static const String reportedBy = 'reportedBy';
  static const String resolvedBy = 'resolvedBy';
  static const String resolvedAt = 'resolvedAt';
}
