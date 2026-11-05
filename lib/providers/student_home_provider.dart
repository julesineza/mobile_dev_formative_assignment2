import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../core/constants/firestore_keys.dart';
import '../core/constants/issue_status.dart';
import '../core/constants/colors.dart';
import '../models/issue.dart';

class DashboardReport {
  const DashboardReport({
    required this.title,
    required this.location,
    required this.status,
    required this.reportNumber,
    required this.reportDate,
    required this.icon,
    required this.statusColor,
    required this.statusBackground,
  });

  final String title;
  final String location;
  final String status;
  final String reportNumber;
  final String reportDate;
  final IconData icon;
  final Color statusColor;
  final Color statusBackground;
}

class StudentHomeProvider extends ChangeNotifier {
  StudentHomeProvider({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance {
    _authSubscription = _auth.authStateChanges().listen(
      _handleAuthStateChanged,
    );
  }

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _issuesSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userSubscription;

  int _selectedIndex = 0;
  bool _isLoading = true;
  String _studentName = 'Student';
  String? _errorMessage;
  List<Issue> _issues = const [];

  static const int _maxDashboardReports = 2;

  int get selectedIndex => _selectedIndex;
  bool get isLoading => _isLoading;
  String get studentName => _studentName;
  String? get errorMessage => _errorMessage;

  List<DashboardReport> get reports {
    return _issues.take(_maxDashboardReports).map(_toDashboardReport).toList();
  }

  int get reportsMade => _issues.length;
  int get activeReports =>
      _issues.where((issue) => issue.status != IssueStatus.resolved).length;
  int get resolvedReports =>
      _issues.where((issue) => issue.status == IssueStatus.resolved).length;

  void selectTab(int index) {
    if (index == _selectedIndex) return;
    _selectedIndex = index;
    notifyListeners();
  }

  Future<void> refresh() async {
    final user = _auth.currentUser;
    if (user == null) {
      _errorMessage = 'Sign in to view your dashboard data.';
      _isLoading = false;
      notifyListeners();
      return;
    }
    await _issuesSubscription?.cancel();
    _listenToIssues(user.uid);
  }

  Future<void> _handleAuthStateChanged(User? user) async {
    await _issuesSubscription?.cancel();
    await _userSubscription?.cancel();

    if (user == null) {
      _issues = const [];
      _studentName = 'Student';
      _errorMessage = 'Sign in to view your dashboard data.';
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _studentName = _firstWord(user.displayName) ?? 'Student';
    notifyListeners();

    _listenToUser(user.uid);
    _listenToIssues(user.uid);
  }

  void _listenToUser(String uid) {
    _userSubscription = _firestore
        .collection(FirestoreKeys.users)
        .doc(uid)
        .snapshots()
        .listen(
          (snapshot) {
            if (!snapshot.exists) return;
            final data = snapshot.data();
            if (data == null) return;
            final name = (data[FirestoreKeys.name] as String?)?.trim();
            if (name == null || name.isEmpty) return;
            _studentName = _firstWord(name) ?? _studentName;
            notifyListeners();
          },
          onError: (_) {
            // Keep current fallback name if user profile fetch fails.
          },
        );
  }

  void _listenToIssues(String uid) {
    _issuesSubscription = _firestore
        .collection(FirestoreKeys.issues)
        .where(FirestoreKeys.reportedBy, isEqualTo: uid)
        .snapshots()
        .listen(
          (snapshot) {
            _issues =
                snapshot.docs
                    .map((doc) => Issue.fromMap(doc.data(), doc.id))
                    .toList()
                  ..sort(
                    (first, second) =>
                        second.createdAt.compareTo(first.createdAt),
                  );
            _isLoading = false;
            _errorMessage = null;
            notifyListeners();
          },
          onError: (Object error) {
            debugPrint('Unable to load reports for student $uid: $error');
            _issues = const [];
            _isLoading = false;
            _errorMessage =
                'Unable to load reports right now. Please try again.';
            notifyListeners();
          },
        );
  }

  DashboardReport _toDashboardReport(Issue issue) {
    final statusColor = switch (issue.status) {
      IssueStatus.submitted => AppColors.warning,
      IssueStatus.inProgress => AppColors.primaryBlue,
      IssueStatus.resolved => AppColors.success,
    };

    final statusBackground = switch (issue.status) {
      IssueStatus.submitted => AppColors.warningBackground,
      IssueStatus.inProgress => AppColors.primaryBackground,
      IssueStatus.resolved => AppColors.successBackground,
    };

    final icon = switch (issue.category.value) {
      'water' => Icons.water_drop_outlined,
      'electricity' => Icons.bolt_outlined,
      'furniture' => Icons.chair_outlined,
      'sanitation' => Icons.clean_hands_outlined,
      'safety' => Icons.health_and_safety_outlined,
      'facilities' => Icons.home_repair_service_outlined,
      _ => Icons.report_problem_outlined,
    };

    final title = issue.title.trim().isEmpty ? 'Untitled report' : issue.title;
    final location = issue.location.trim().isEmpty
        ? 'Campus location not provided'
        : issue.location;

    return DashboardReport(
      title: title,
      location: location,
      status: issue.status.label,
      reportNumber: '#${_shortIssueId(issue.id)}',
      reportDate: DateFormat('MMM d').format(issue.createdAt),
      icon: icon,
      statusColor: statusColor,
      statusBackground: statusBackground,
    );
  }

  String _shortIssueId(String id) {
    final compact = id.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
    if (compact.isEmpty) return '----';
    if (compact.length <= 4) return compact;
    return compact.substring(compact.length - 4);
  }

  String? _firstWord(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return trimmed.split(RegExp(r'\s+')).first;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _issuesSubscription?.cancel();
    _userSubscription?.cancel();
    super.dispose();
  }
}
