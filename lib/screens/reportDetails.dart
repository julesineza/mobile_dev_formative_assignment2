import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/constants/colors.dart';
import '../core/constants/issue_status.dart';
import '../models/issue.dart';
import '../providers/image_provider.dart';

class ReportDetails extends StatelessWidget {
  const ReportDetails({required this.issue, super.key});

  final Issue issue;

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        context.watch<ImageUploadProvider>().imageUrl ?? issue.imageUrl;

    return Scaffold(
      appBar: AppBar(title: const Text('Report details')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        children: [
          Text(
            issue.title.trim().isEmpty ? 'Untitled report' : issue.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _StatusBadge(status: issue.status),
          const SizedBox(height: 24),
          if (imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                imageUrl,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _ImagePlaceholder(
                  message: 'Unable to load report image',
                ),
              ),
            )
          else
            const _ImagePlaceholder(message: 'No image attached'),
          const SizedBox(height: 24),
          _InfoCard(
            title: 'Issue description',
            child: Text(
              issue.description.trim().isEmpty
                  ? 'No description provided.'
                  : issue.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.text,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 14),
          _InfoCard(
            title: 'Location',
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    issue.location.trim().isEmpty
                        ? 'Location not provided'
                        : issue.location,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Status timeline',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _StatusTimeline(issue: issue),
        ],
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline({required this.issue});

  final Issue issue;

  @override
  Widget build(BuildContext context) {
    final steps = [
      _TimelineStep(
        label: 'Report submitted',
        date: issue.createdAt,
        complete: true,
        icon: Icons.receipt_long_outlined,
      ),
      _TimelineStep(
        label: 'In progress',
        date: issue.status == IssueStatus.submitted ? null : issue.updatedAt,
        complete: issue.status != IssueStatus.submitted,
        icon: Icons.engineering_outlined,
      ),
      _TimelineStep(
        label: 'Resolved',
        date: issue.resolvedAt,
        complete: issue.status == IssueStatus.resolved,
        icon: Icons.check_circle_outline,
      ),
    ];

    return Column(
      children: [
        for (var index = 0; index < steps.length; index++)
          _TimelineItem(
            step: steps[index],
            isLast: index == steps.length - 1,
          ),
      ],
    );
  }
}

class _TimelineStep {
  const _TimelineStep({
    required this.label,
    required this.date,
    required this.complete,
    required this.icon,
  });

  final String label;
  final DateTime? date;
  final bool complete;
  final IconData icon;
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.step, required this.isLast});

  final _TimelineStep step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = step.complete
        ? AppColors.primaryBlue
        : AppColors.border;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Icon(step.icon, color: color, size: 25),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: color.withValues(alpha: 0.35)),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: step.complete
                          ? AppColors.text
                          : AppColors.secondaryText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step.date == null
                        ? 'Waiting for an update'
                        : DateFormat('MMM d, y · h:mm a').format(step.date!),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.image_not_supported_outlined,
            color: AppColors.secondaryText,
            size: 34,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(color: AppColors.secondaryText),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final IssueStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      IssueStatus.submitted => AppColors.warning,
      IssueStatus.inProgress => AppColors.primaryBlue,
      IssueStatus.resolved => AppColors.success,
    };

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          status.label,
          style: TextStyle(color: color, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
