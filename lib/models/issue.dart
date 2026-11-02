import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firestore_keys.dart';
import '../core/constants/issue_category.dart';
import '../core/constants/issue_status.dart';
import '../core/constants/priority.dart';

class Issue {
  final String id;
  final String title;
  final String description;
  final IssueCategory category;
  final String? department;
  final String location;
  final IssueStatus status;
  final Priority priority;
  final String? imageUrl;
  final String reportedBy; // uid of the student
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? resolvedBy; // uid of the staff member
  final DateTime? resolvedAt;

  const Issue({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.department,
    required this.location,
    required this.status,
    required this.priority,
    this.imageUrl,
    required this.reportedBy,
    required this.createdAt,
    required this.updatedAt,
    this.resolvedBy,
    this.resolvedAt,
  });

  // Firestore -> Dart. The document ID comes separately from the data.
  factory Issue.fromMap(Map<String, dynamic> map, String id) {
    return Issue(
      id: id,
      title: map[FirestoreKeys.title] as String? ?? '',
      description: map[FirestoreKeys.description] as String? ?? '',
      category: IssueCategory.fromString(map[FirestoreKeys.category] as String?),
      status: IssueStatus.fromString(map[FirestoreKeys.status] as String?),
      priority: Priority.fromString(map[FirestoreKeys.priority] as String?),
      imageUrl: map[FirestoreKeys.imageUrl] as String?,
      reportedBy: map[FirestoreKeys.reportedBy] as String? ?? '',
      location: map[FirestoreKeys.location] as String? ?? '',
      createdAt:
          (map[FirestoreKeys.createdAt] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
          (map[FirestoreKeys.updatedAt] as Timestamp?)?.toDate() ?? DateTime.now(),
      resolvedBy: map[FirestoreKeys.resolvedBy] as String?,
      resolvedAt: (map[FirestoreKeys.resolvedAt] as Timestamp?)?.toDate(),
    );
  }

  // Dart -> Firestore. No id here: it is the document's name.
  // Null optional fields are skipped instead of being written as null.
  Map<String, dynamic> toMap() {
    return {
      FirestoreKeys.title: title,
      FirestoreKeys.description: description,
      FirestoreKeys.category: category.value,
      if (department != null) FirestoreKeys.department: department,
      FirestoreKeys.location: location,
      FirestoreKeys.status: status.value,
      FirestoreKeys.priority: priority.value,
      if (imageUrl != null) FirestoreKeys.imageUrl: imageUrl,
      FirestoreKeys.reportedBy: reportedBy,
      FirestoreKeys.createdAt: Timestamp.fromDate(createdAt),
      FirestoreKeys.updatedAt: Timestamp.fromDate(updatedAt),
      if (resolvedBy != null) FirestoreKeys.resolvedBy: resolvedBy,
      if (resolvedAt != null)
        FirestoreKeys.resolvedAt: Timestamp.fromDate(resolvedAt!),
    };
  }

  // Only the fields staff are expected to change are included.
  // Known limitation: you cannot set a nullable field back to null with this.
  Issue copyWith({
    IssueStatus? status,
    Priority? priority,
    DateTime? updatedAt,
    String? resolvedBy,
    DateTime? resolvedAt,
  }) {
    return Issue(
      id: id,
      title: title,
      description: description,
      category: category,
      department: department,
      location: location,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      imageUrl: imageUrl,
      reportedBy: reportedBy,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}