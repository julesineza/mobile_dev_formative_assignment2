import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/constants/colors.dart';
import '../core/constants/issue_category.dart';
import '../core/constants/issue_status.dart';
import '../models/issue.dart';
import '../providers/explore_issues_provider.dart';
import '../widgets/navbar.dart';

class ExploreIssues extends StatelessWidget {
  const ExploreIssues({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExploreIssuesProvider(),
      child: const _ExploreIssuesContent(),
    );
  }
}

class _ExploreIssuesContent extends StatelessWidget {
  const _ExploreIssuesContent();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExploreIssuesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore issues'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: provider.refresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            children: [
              Text(
                'See what is happening around campus',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              TextField(
                onChanged: provider.updateSearchQuery,
                decoration: const InputDecoration(
                  hintText: 'Search issues or locations',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 14),
              _FilterRow(provider: provider),
              const SizedBox(height: 20),
              if (provider.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (provider.errorMessage != null)
                _MessageCard(
                  icon: Icons.error_outline,
                  message: provider.errorMessage!,
                  action: TextButton(
                    onPressed: provider.refresh,
                    child: const Text('Try again'),
                  ),
                )
              else if (provider.issues.isEmpty)
                const _MessageCard(
                  icon: Icons.search_off_outlined,
                  message: 'No issues match your search.',
                )
              else
                ...provider.issues.map(
                  (issue) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _IssueCard(issue: issue),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: StudentBottomNavigationBar(
        selectedIndex: 1,
        onSelected: (index) {
          if (index == 0) Navigator.of(context).pop();
        },
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.provider});

  final ExploreIssuesProvider provider;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterMenu<IssueCategory>(
            label: provider.selectedCategory?.label ?? 'All categories',
            value: provider.selectedCategory,
            values: IssueCategory.values,
            itemLabel: (category) => category.label,
            onChanged: provider.selectCategory,
          ),
          const SizedBox(width: 10),
          _FilterMenu<IssueStatus>(
            label: provider.selectedStatus?.label ?? 'All statuses',
            value: provider.selectedStatus,
            values: IssueStatus.values,
            itemLabel: (status) => status.label,
            onChanged: provider.selectStatus,
          ),
          if (provider.selectedCategory != null ||
              provider.selectedStatus != null ||
              provider.searchQuery.isNotEmpty) ...[
            const SizedBox(width: 6),
            TextButton(
              onPressed: provider.clearFilters,
              child: const Text('Clear'),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterMenu<T> extends StatelessWidget {
  const _FilterMenu({
    required this.label,
    required this.value,
    required this.values,
    required this.itemLabel,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final List<T> values;
  final String Function(T value) itemLabel;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T?>(
      onSelected: onChanged,
      itemBuilder: (context) => [
        PopupMenuItem<T?>(value: null, child: Text('All')),
        ...values.map(
          (item) => PopupMenuItem<T?>(
            value: item,
            child: Text(itemLabel(item)),
          ),
        ),
      ],
      child: Chip(
        label: Text(label),
        deleteIcon: const Icon(Icons.keyboard_arrow_down, size: 20),
        onDeleted: () {},
        side: const BorderSide(color: AppColors.border),
        backgroundColor: AppColors.surface,
      ),
    );
  }
}

class _IssueCard extends StatelessWidget {
  const _IssueCard({required this.issue});

  final Issue issue;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(issue.status);
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _showDetails(context),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    issue.title.trim().isEmpty ? 'Untitled issue' : issue.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _StatusBadge(status: issue.status),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              issue.description.trim().isEmpty
                  ? 'No description provided.'
                  : issue.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
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
                    issue.location.trim().isEmpty
                        ? 'Location not provided'
                        : issue.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ),
                Text(
                  DateFormat('MMM d').format(issue.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(_categoryIcon(issue.category), size: 18, color: statusColor),
                const SizedBox(width: 6),
                Text(
                  issue.category.label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              issue.title.trim().isEmpty ? 'Untitled issue' : issue.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            _StatusBadge(status: issue.status),
            const SizedBox(height: 18),
            Text(issue.description, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 18),
            Text(
              'Reported at ${issue.location}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('MMMM d, y').format(issue.createdAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final IssueStatus status;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.icon, required this.message, this.action});

  final IconData icon;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, size: 34, color: AppColors.secondaryText),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          if (action != null) action!,
        ],
      ),
    );
  }
}

Color _statusColor(IssueStatus status) {
  return switch (status) {
    IssueStatus.submitted => AppColors.warning,
    IssueStatus.inProgress => AppColors.primaryBlue,
    IssueStatus.resolved => AppColors.success,
  };
}

IconData _categoryIcon(IssueCategory category) {
  return switch (category) {
    IssueCategory.water => Icons.water_drop_outlined,
    IssueCategory.electricity => Icons.bolt_outlined,
    IssueCategory.furniture => Icons.chair_outlined,
    IssueCategory.sanitation => Icons.clean_hands_outlined,
    IssueCategory.safety => Icons.health_and_safety_outlined,
    IssueCategory.facilities => Icons.home_repair_service_outlined,
    IssueCategory.other => Icons.report_problem_outlined,
  };
}
