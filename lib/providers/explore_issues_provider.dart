import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/constants/issue_category.dart';
import '../core/constants/issue_status.dart';
import '../models/issue.dart';
import '../services/issue_service.dart';

class ExploreIssuesProvider extends ChangeNotifier {
  ExploreIssuesProvider({IssueService? issueService})
    : _issueService = issueService ?? IssueService() {
    _listenToIssues();
  }

  final IssueService _issueService;
  StreamSubscription<List<Issue>>? _issuesSubscription;

  List<Issue> _issues = const [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  IssueCategory? _selectedCategory;
  IssueStatus? _selectedStatus;

  List<Issue> get issues => _filteredIssues;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  IssueCategory? get selectedCategory => _selectedCategory;
  IssueStatus? get selectedStatus => _selectedStatus;

  List<Issue> get _filteredIssues {
    final query = _searchQuery.trim().toLowerCase();
    return _issues.where((issue) {
      final matchesSearch =
          query.isEmpty ||
          issue.title.toLowerCase().contains(query) ||
          issue.description.toLowerCase().contains(query) ||
          issue.location.toLowerCase().contains(query);
      final matchesCategory =
          _selectedCategory == null || issue.category == _selectedCategory;
      final matchesStatus =
          _selectedStatus == null || issue.status == _selectedStatus;
      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();
  }

  void updateSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void selectCategory(IssueCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void selectStatus(IssueStatus? status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _selectedStatus = null;
    notifyListeners();
  }

  Future<void> refresh() async {
    await _issuesSubscription?.cancel();
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    _listenToIssues();
  }

  void _listenToIssues() {
    _issuesSubscription = _issueService.watchAllIssues().listen(
      (issues) {
        _issues = issues;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (Object error) {
        debugPrint('Unable to load issues for explore screen: $error');
        _issues = const [];
        _isLoading = false;
        _errorMessage =
            'Unable to load campus issues right now. Please try again.';
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _issuesSubscription?.cancel();
    super.dispose();
  }
}
