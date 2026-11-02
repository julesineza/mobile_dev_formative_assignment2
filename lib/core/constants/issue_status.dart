enum IssueStatus {
  submitted('submitted', 'Submitted'),
  inProgress('in_progress', 'In Progress'),
  resolved('resolved', 'Resolved');

  const IssueStatus(this.value, this.label);

  final String value; // stored in Firestore: never change it
  final String label; // shown in the UI

  static IssueStatus fromString(String? value) {
    return IssueStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => IssueStatus.submitted,
    );
  }
}