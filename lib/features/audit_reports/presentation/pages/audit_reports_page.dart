import 'package:flutter/material.dart';

import '../../../../core/widgets/app_shell.dart';

class AuditReportsPage extends StatelessWidget {
  const AuditReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppShell(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'التدقيق والتقارير',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'مخططات تدفق وتقارير تشغيلية لمتابعة دورة المخزون والتسوية.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            const _FlowSection(),
            const SizedBox(height: 20),
            const _FlowSectionTwo(),
            const SizedBox(height: 20),
            const _ReportsManager(),
          ],
        ),
      ),
    );
  }
}

class _FlowSection extends StatelessWidget {
  const _FlowSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('تدفق الشراء إلى المخزون', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            const Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _FlowNode('أمر شراء', Color(0xFF4B3FDC)),
                _FlowArrow(),
                _FlowNode('استلام GRN', Color(0xFF2563EB)),
                _FlowArrow(),
                _FlowNode('ترحيل المخزون', Color(0xFF1F8A5B)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FlowSectionTwo extends StatelessWidget {
  const _FlowSectionTwo();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('تدفق البيع والتسوية', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            const Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _FlowNode('طلب POS', Color(0xFF4B3FDC)),
                _FlowArrow(),
                _FlowNode('خصم المخزون', Color(0xFFD97706)),
                _FlowArrow(),
                _FlowNode('مطابقة وتدقيق', Color(0xFFC93C3C)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportsManager extends StatefulWidget {
  const _ReportsManager();

  @override
  State<_ReportsManager> createState() => _ReportsManagerState();
}

class _ReportsManagerState extends State<_ReportsManager> {
  final List<({String title, String subtitle, String status})> _reports = [
    (
      title: 'مطابقة نقاط البيع',
      subtitle: 'مقارنة المبيعات مع خصم المخزون',
      status: 'نشط',
    ),
    (
      title: 'استثناءات التدقيق',
      subtitle: 'الفروقات والاستثناءات اليومية',
      status: 'يومي',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'قوالب التقارير',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                FilledButton.icon(
                  onPressed: _addReport,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('إضافة'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ..._reports.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    title: Text(entry.value.title),
                    subtitle: Text(entry.value.subtitle),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(entry.value.status),
                        IconButton(
                          onPressed: () => _showDetails(entry.value),
                          icon: const Icon(Icons.info_outline_rounded),
                        ),
                        IconButton(
                          onPressed: () => setState(() => _reports.removeAt(entry.key)),
                          icon: const Icon(Icons.delete_outline_rounded),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addReport() async {
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();
    final statusController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('إضافة تقرير'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'اسم التقرير'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: subtitleController,
                decoration: const InputDecoration(labelText: 'الوصف'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: statusController,
                decoration: const InputDecoration(labelText: 'الحالة'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  _reports.insert(
                    0,
                    (
                      title: titleController.text.isEmpty
                          ? 'تقرير جديد'
                          : titleController.text,
                      subtitle: subtitleController.text.isEmpty
                          ? 'تمت إضافته من الشاشة'
                          : subtitleController.text,
                      status: statusController.text.isEmpty
                          ? 'جديد'
                          : statusController.text,
                    ),
                  );
                });
                Navigator.of(context).pop();
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDetails(({String title, String subtitle, String status}) report) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(report.title),
          content: Text('${report.subtitle}\nالحالة: ${report.status}'),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }
}

class _FlowNode extends StatelessWidget {
  const _FlowNode(this.label, this.color);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color),
      ),
    );
  }
}

class _FlowArrow extends StatelessWidget {
  const _FlowArrow();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Icon(Icons.arrow_back_rounded),
    );
  }
}
