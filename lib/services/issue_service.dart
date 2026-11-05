import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_keys.dart';
import '../models/issue.dart';

class IssueService {
  IssueService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<Issue>> watchAllIssues() {
    return _firestore.collection(FirestoreKeys.issues).snapshots().map(
      (snapshot) => _mapAndSort(snapshot),
    );
  }

  Stream<List<Issue>> watchIssuesReportedBy(String uid) {
    return _firestore
        .collection(FirestoreKeys.issues)
        .where(FirestoreKeys.reportedBy, isEqualTo: uid)
        .snapshots()
        .map((snapshot) => _mapAndSort(snapshot));
  }

  Future<void> createIssue(Issue issue) {
    return _firestore.collection(FirestoreKeys.issues).add(issue.toMap());
  }

  List<Issue> _mapAndSort(QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs
        .map((doc) => Issue.fromMap(doc.data(), doc.id))
        .toList()
      ..sort(
        (first, second) => second.createdAt.compareTo(first.createdAt),
      );
  }
}
