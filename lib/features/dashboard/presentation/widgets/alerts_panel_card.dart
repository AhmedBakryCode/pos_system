import 'package:flutter/material.dart';

class AlertsPanelCard extends StatelessWidget {
  const AlertsPanelCard({
    super.key,
    required this.alerts,
    required this.warningColor,
    required this.infoColor,
    required this.errorColor,
  });

  final List<({
    Color color,
    String description,
    String severity,
    String time,
    String title,
  })> alerts;
  final Color warningColor;
  final Color infoColor;
  final Color errorColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Alerts Panel', style: theme.textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              'Low stock warnings, missing GRNs, and audit discrepancies.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            ...alerts.map((alert) => _AlertTile(alert: alert)),
          ],
        ),
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({
    required this.alert,
  });

  final ({
    Color color,
    String description,
    String severity,
    String time,
    String title,
  }) alert;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: alert.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(alert.title, style: theme.textTheme.titleMedium),
              ),
              Text(alert.time, style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: alert.color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              alert.severity,
              style: theme.textTheme.labelMedium?.copyWith(
                color: alert.color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(alert.description, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: () {},
              child: const Text('Review'),
            ),
          ),
        ],
      ),
    );
  }
}
