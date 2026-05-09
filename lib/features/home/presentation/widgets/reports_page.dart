import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_shell.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppShell(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('التقارير', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            const _ReportTile(
              title: 'تقييم المخزون',
              subtitle: 'متابعة قيمة المخزون الحالي وتوزيعه بين المخازن.',
            ),
            const SizedBox(height: 12),
            const _ReportTile(
              title: 'مطابقة نقاط البيع',
              subtitle: 'مقارنة مبيعات نقاط البيع مع الخصومات والمرتجعات.',
            ),
            const SizedBox(height: 12),
            const _ReportTile(
              title: 'استثناءات التدقيق',
              subtitle: 'مراجعة الفروقات والحالات المستثناة وفشل المزامنة.',
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_left_rounded),
      ),
    );
  }
}
