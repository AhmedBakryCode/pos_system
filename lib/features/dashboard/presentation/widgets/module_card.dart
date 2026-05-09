import 'package:flutter/material.dart';

import '../../../shared/domain/entities/dashboard_module.dart';

class ModuleCard extends StatelessWidget {
  const ModuleCard({super.key, required this.module, this.onTap});

  final DashboardModule module;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: module.color.withValues(alpha: 0.14),
                  child: Icon(module.icon, color: module.color, size: 20),
                ),
                const SizedBox(height: 12),
                Text(
                  module.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  module.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: module.metrics
                      .take(2)
                      .map(
                        (metric) => Chip(
                          visualDensity: VisualDensity.compact,
                          label: Text(
                            metric,
                            style: theme.textTheme.labelSmall?.copyWith(fontSize: 10),
                          ),
                          side: BorderSide.none,
                          backgroundColor: module.color.withValues(alpha: 0.10),
                          padding: EdgeInsets.zero,
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
