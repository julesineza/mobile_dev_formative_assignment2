import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/colors.dart';
import '../core/constants/issue_category.dart';
import '../core/constants/priority.dart';
import '../providers/submit_report_provider.dart';

class SubmitReport extends StatelessWidget {
  const SubmitReport({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SubmitReportProvider(),
      child: const _SubmitReportForm(),
    );
  }
}



class _SubmitReportForm extends StatefulWidget {
  const _SubmitReportForm();

  @override
  State<_SubmitReportForm> createState() => _SubmitReportFormState();
}

class _SubmitReportFormState extends State<_SubmitReportForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<SubmitReportProvider>();
    final submitted = await provider.submit(
      title: _titleController.text,
      description: _descriptionController.text,
      location: _locationController.text,
    );

    if (!mounted) return;
    if (submitted) {
      Navigator.of(context).pop(true);
    } else if (provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SubmitReportProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report an issue'),
        leading: IconButton(
          tooltip: 'Back',
          onPressed: provider.isSubmitting
              ? null
              : () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            children: [
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Issue details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _titleController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Issue title',
                        hintText: 'e.g. Broken tap in the library',
                        prefixIcon: Icon(Icons.title_outlined),
                      ),
                      validator: (value) => _required(value, 'title'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 5,
                      maxLength: 500,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Describe the issue and any helpful details',
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(bottom: 76),
                          child: Icon(Icons.notes_outlined),
                        ),
                        alignLabelWithHint: true,
                      ),
                      validator: (value) => _required(value, 'description'),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _locationController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        hintText: 'e.g. Main library, first floor',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      validator: (value) => _required(value, 'location'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Classification',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 18),
                    DropdownButtonFormField<IssueCategory>(
                      value: provider.selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: IssueCategory.values
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category.label),
                            ),
                          )
                          .toList(),
                      onChanged: provider.isSubmitting
                          ? null
                          : (category) {
                              if (category != null) {
                                provider.selectCategory(category);
                              }
                            },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Priority>(
                      value: provider.selectedPriority,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        prefixIcon: Icon(Icons.flag_outlined),
                      ),
                      items: Priority.values
                          .map(
                            (priority) => DropdownMenuItem(
                              value: priority,
                              child: Text(priority.label),
                            ),
                          )
                          .toList(),
                      onChanged: provider.isSubmitting
                          ? null
                          : (priority) {
                              if (priority != null) {
                                provider.selectPriority(priority);
                              }
                            },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: provider.isSubmitting ? null : _submit,
                icon: provider.isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_outlined),
                label: Text(
                  provider.isSubmitting ? 'Submitting...' : 'Submit report',
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  String? _required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter a $fieldName';
    }
    return null;
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}
