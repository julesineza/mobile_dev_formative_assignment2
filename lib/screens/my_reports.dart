import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_routes.dart';
import '../core/constants/colors.dart';
import '../providers/student_home_provider.dart';
import '../widgets/navbar.dart';
import 'StudentHome.dart';

class MyReports extends StatelessWidget {
  const MyReports({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StudentHomeProvider(),
      child: const _MyReportsContent(),
    );
  }
}

class _MyReportsContent extends StatelessWidget {
  const _MyReportsContent();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentHomeProvider>();
    final reports = provider.allReports;

    return Scaffold(
      appBar: AppBar(title: const Text('My reports')),
      body: RefreshIndicator(
        onRefresh: provider.refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            Text(
              'Reports you have made',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Track the progress of issues you reported to the campus team.',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppColors.secondaryText),
            ),
            const SizedBox(height: 24),
            if (provider.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 80),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.errorMessage != null)
              _MessageCard(
                icon: Icons.error_outline,
                message: provider.errorMessage!,
              )
            else if (reports.isEmpty)
              const _MessageCard(
                icon: Icons.assignment_outlined,
                message: 'You have not made any reports yet. Submit an issue to see it here.',
              )
            else
              ...reports.expand(
                (report) => [
                  ReportCard(report: report),
                  if (report != reports.last) const SizedBox(height: 14),
                ],
              ),
          ],
        ),
      ),
      bottomNavigationBar: StudentBottomNavigationBar(
        selectedIndex: 2,
        onSelected: (index) {
          if (index == 0) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.studentHome);
          } else if (index == 1) {
            Navigator.of(context).pushNamed(AppRoutes.exploreIssues);
          }
        },
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(23),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondaryText),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppColors.secondaryText),
            ),
          ),
        ],
      ),
    );
  }
}
