class DashboardMetric {
  const DashboardMetric({
    required this.label,
    required this.value,
    required this.highlight,
    required this.description,
  });

  final String label;
  final String value;
  final String highlight;
  final String description;
}
