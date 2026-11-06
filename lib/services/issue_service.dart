import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_keys.dart';
import '../models/issue.dart';
import '../core/constants/issue_status.dart';

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

  Future<bool> updateStatusIfUnassigned({
    required String issueId,
    required IssueStatus status,
    required String staffUid,
  }) async {
    final reference = _firestore.collection(FirestoreKeys.issues).doc(issueId);
    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(reference);
      final data = snapshot.data();
      if (!snapshot.exists || data == null) return false;

      final assignedTo = data[FirestoreKeys.resolvedBy] as String?;
      if (assignedTo != null && assignedTo != staffUid) return false;

      transaction.update(reference, {
        FirestoreKeys.status: status.value,
        FirestoreKeys.updatedAt: FieldValue.serverTimestamp(),
        FirestoreKeys.resolvedBy: staffUid,
        if (status == IssueStatus.resolved)
          FirestoreKeys.resolvedAt: FieldValue.serverTimestamp(),
      });
      return true;
    });
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
