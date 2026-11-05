import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../widgets/navbar.dart';

import '../core/constants/colors.dart';
import '../providers/student_home_provider.dart';

class StudentHome extends StatelessWidget {
  const StudentHome({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StudentHomeProvider(),
      child: const _StudentHomeContent(),
    );
  }
}

class _StudentHomeContent extends StatelessWidget {
  const _StudentHomeContent();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentHomeProvider>();
    final today = DateFormat('EEE, MMM d').format(DateTime.now()).toUpperCase();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '· $today .',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            'Hello ,\n${provider.studentName}',
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(
                                  color: AppColors.text,
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                  height: 1.15,
                                ),
                          ),
                        ),
                        
                      ],
                    ),
                    const SizedBox(height: 28),
                    const _ReportPromptCard(),
                    const SizedBox(height: 28),
                    Text(
                      'Your impact',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: AppColors.text,
                            fontWeight: FontWeight.w400,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _ImpactCard(provider: provider),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent reports',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: AppColors.text,
                                fontWeight: FontWeight.w400,
                              ),
                        ),
                        TextButton(
                          onPressed: () => provider.selectTab(2),
                          child: const Text('View all'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (provider.isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (provider.errorMessage != null)
                      _StatusCard(
                        icon: Icons.error_outline,
                        message: provider.errorMessage!,
                      )
                    else if (provider.reports.isEmpty)
                      const _StatusCard(
                        icon: Icons.inbox_outlined,
                        message: 'No reports yet. Tap "Report an issue" to submit your first one.',
                      )
                    else
                      ...provider.reports.expand(
                        (report) => [
                          ReportCard(report: report),
                          if (report != provider.reports.last)
                            const SizedBox(height: 14),
                        ],
                      ),
                    const SizedBox(height: 27),
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: AppColors.success,
                          size: 23,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'All ${provider.activeReports} active reports are '
                            'with the campus team.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: StudentBottomNavigationBar(
        selectedIndex: provider.selectedIndex,
        onSelected: provider.selectTab,
      ),
    );
  }
}
class _ReportPromptCard extends StatelessWidget {
  const _ReportPromptCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(23),
      ),
      child: Column(
        children: [
          Row(
            children: [
              
              const SizedBox(width: 17),
              
            ],
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 73,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report an issue tapped')),
                );
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 25),
                  SizedBox(width: 12),
                  Text(
                    'Report an issue',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 21),
    
        ],
      ),
    );
  }
}

class _ImpactCard extends StatelessWidget {
  const _ImpactCard({required this.provider});

  final StudentHomeProvider provider;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(23),
      ),
      child: Row(
        children: [
          Expanded(
            child: ImpactItem(
              number: '${provider.reportsMade}',
              label: 'Reports made',
              color: AppColors.text,
            ),
          ),
          Expanded(
            child: ImpactItem(
              number: '${provider.activeReports}',
              label: 'Active',
              color: AppColors.primaryBlue,
            ),
          ),
          Expanded(
            child: ImpactItem(
              number: '${provider.resolvedReports}',
              label: 'Resolved',
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}

class ImpactItem extends StatelessWidget {
  const ImpactItem({
    super.key,
    required this.number,
    required this.label,
    required this.color,
  });

  final String number;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: color,
            fontSize: 37,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: AppColors.secondaryText),
        ),
      ],
    );
  }
}

class ReportCard extends StatelessWidget {
  const ReportCard({super.key, required this.report});

  final DashboardReport report;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(23),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(report.icon, color: AppColors.secondaryText, size: 27),
          ),
          const SizedBox(width: 17),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.text,
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  report.location,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: AppColors.secondaryText),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: report.statusBackground,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        report.status,
                        style: TextStyle(
                          color: report.statusColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        '${report.reportNumber} · ${report.reportDate}',
                        textAlign: TextAlign.end,
                        style: Theme.of(context).textTheme.labelSmall
                            ?.copyWith(color: AppColors.secondaryText),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
