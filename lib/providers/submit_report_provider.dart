import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/firestore_keys.dart';
import '../core/constants/issue_category.dart';
import '../core/constants/issue_status.dart';
import '../core/constants/priority.dart';
import '../models/issue.dart';

class SubmitReportProvider extends ChangeNotifier {
  SubmitReportProvider({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  IssueCategory _selectedCategory = IssueCategory.other;
  Priority _selectedPriority = Priority.normal;
  bool _isSubmitting = false;
  String? _errorMessage;

  IssueCategory get selectedCategory => _selectedCategory;
  Priority get selectedPriority => _selectedPriority;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  void selectCategory(IssueCategory category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void selectPriority(Priority priority) {
    _selectedPriority = priority;
    notifyListeners();
  }

  Future<bool> submit({
    required String title,
    required String description,
    required String location,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      _errorMessage = 'You must be signed in to submit a report.';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    final now = DateTime.now();
    final issue = Issue(
      id: '',
      title: title.trim(),
      description: description.trim(),
      category: _selectedCategory,
      location: location.trim(),
      status: IssueStatus.submitted,
      priority: _selectedPriority,
      reportedBy: user.uid,
      createdAt: now,
      updatedAt: now,
    );

    try {
      await _firestore.collection(FirestoreKeys.issues).add(issue.toMap());
      _isSubmitting = false;
      notifyListeners();
      return true;
    } on FirebaseException {
      _isSubmitting = false;
      _errorMessage =
          'Unable to submit your report right now. Please try again.';
      notifyListeners();
      return false;
    } catch (_) {
      _isSubmitting = false;
      _errorMessage =
          'Something went wrong while submitting your report. Please try again.';
      notifyListeners();
      return false;
    }
  }
}