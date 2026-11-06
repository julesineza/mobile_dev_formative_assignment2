import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../core/constants/colors.dart';
import '../core/constants/issue_status.dart';
import '../core/constants/priority.dart';
import '../models/issue.dart';
import '../providers/explore_issues_provider.dart';
import '../services/auth_service.dart';
import '../app_routes.dart';

class StaffDashboard extends StatelessWidget {
  const StaffDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExploreIssuesProvider(sortByUrgency: true),
      child: const _StaffDashboardContent(),
    );
  }
}

class _StaffDashboardContent extends StatelessWidget {
  const _StaffDashboardContent();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExploreIssuesProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff dashboard'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () async {
              await AuthService().signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.welcome,
                  (_) => false,
                );
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: provider.refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            Text(
              'Review reports by urgency and keep students informed.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            TextField(
              onChanged: provider.updateSearchQuery,
              decoration: const InputDecoration(
                hintText: 'Search title, description, or location',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 14),
            _Filters(provider: provider),
            const SizedBox(height: 20),
            if (provider.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (provider.errorMessage != null)
              _Message(
                message: provider.errorMessage!,
                icon: Icons.error_outline,
              )
            else if (provider.issues.isEmpty)
              const _Message(
                message: 'No issues match these filters.',
                icon: Icons.search_off,
              )
            else
              ...provider.issues.map(
                (issue) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _StaffIssueCard(issue: issue),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({required this.provider});
  final ExploreIssuesProvider provider;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _Menu<Priority>(
          label: provider.selectedPriority?.label ?? 'All urgency',
          values: Priority.values,
          value: provider.selectedPriority,
          itemLabel: (value) => value.label,
          onChanged: provider.selectPriority,
        ),
        _Menu<IssueStatus>(
          label: provider.selectedStatus?.label ?? 'All statuses',
          values: IssueStatus.values,
          value: provider.selectedStatus,
          itemLabel: (value) => value.label,
          onChanged: provider.selectStatus,
        ),
        if (provider.selectedPriority != null ||
            provider.selectedStatus != null ||
            provider.searchQuery.isNotEmpty)
          TextButton(
            onPressed: provider.clearFilters,
            child: const Text('Clear'),
          ),
      ],
    );
  }
}

class _Menu<T> extends StatelessWidget {
  const _Menu({
    required this.label,
    required this.values,
    required this.value,
    required this.itemLabel,
    required this.onChanged,
  });
  final String label;
  final List<T> values;
  final T? value;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T?>(
      onSelected: onChanged,
      itemBuilder: (_) => [
        PopupMenuItem<T?>(value: null, child: const Text('All')),
        ...values.map(
          (item) =>
              PopupMenuItem<T?>(value: item, child: Text(itemLabel(item))),
        ),
      ],
      child: Chip(
        label: Text(label),
        side: const BorderSide(color: AppColors.border),
        backgroundColor: AppColors.surface,
        deleteIcon: const Icon(Icons.keyboard_arrow_down, size: 18),
        onDeleted: () {},
      ),
    );
  }
}

class _StaffIssueCard extends StatelessWidget {
  const _StaffIssueCard({required this.issue});
  final Issue issue;

  @override
  Widget build(BuildContext context) {
    final assigned = issue.resolvedBy != null;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () =>
          Navigator.of(context)
              .pushNamed(AppRoutes.staffReportDetails, arguments: issue),
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    issue.title.trim().isEmpty ? 'Untitled issue' : issue.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _PriorityBadge(priority: issue.priority),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              issue.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 17,
                  color: AppColors.secondaryText,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    issue.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(DateFormat('MMM d').format(issue.createdAt)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Chip(label: Text(issue.status.label)),
                const Spacer(),
                Text(
                  assigned ? 'Assigned' : 'Update status',
                  style: TextStyle(
                    color: assigned
                        ? AppColors.secondaryText
                        : AppColors.primaryBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.primaryBlue),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});
  final Priority priority;
  @override
  Widget build(BuildContext context) => Chip(
    label: Text(priority.label),
    backgroundColor: priority == Priority.urgent
        ? AppColors.warningBackground
        : AppColors.background,
  );
}

class _Message extends StatelessWidget {
  const _Message({required this.message, required this.icon});
  final String message;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondaryText),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
    ),
  );
}
