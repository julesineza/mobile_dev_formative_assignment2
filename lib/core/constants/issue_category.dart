enum IssueCategory {
  water('water', 'Water Shortage'),
  electricity('electricity', 'Electricity Outage'),
  furniture('furniture', 'Damaged Furniture'),
  sanitation('sanitation', 'Sanitation'),
  safety('safety', 'Safety Concern'),
  facilities('facilities', 'Broken Facilities'),
  other('other', 'Other');

  const IssueCategory(this.value, this.label);

  final String value;
  final String label;

  static IssueCategory fromString(String? value) {
    return IssueCategory.values.firstWhere(
      (category) => category.value == value,
      orElse: () => IssueCategory.other,
    );
  }
}