class InventoryReconciliationIssue {
  const InventoryReconciliationIssue({
    required this.referenceId,
    required this.reason,
    required this.severity,
    required this.requiresManualReview,
  });

  final String referenceId;
  final String reason;
  final String severity;
  final bool requiresManualReview;
}
