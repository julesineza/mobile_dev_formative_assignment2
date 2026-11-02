enum Priority {
  normal('normal', 'Normal'),
  high('high', 'High'),
  urgent('urgent', 'Urgent');

  const Priority(this.value, this.label);

  final String value;
  final String label;

  static Priority fromString(String? value) {
    return Priority.values.firstWhere(
      (priority) => priority.value == value,
      orElse: () => Priority.normal,
    );
  }
}