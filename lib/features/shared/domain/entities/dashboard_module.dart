import 'package:flutter/material.dart';

class DashboardModule {
  const DashboardModule({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.metrics,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<String> metrics;
}
