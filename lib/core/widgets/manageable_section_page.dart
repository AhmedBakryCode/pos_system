import 'package:flutter/material.dart';

import 'app_shell.dart';
import 'entity_details_page.dart';

class ManageableRecord {
  const ManageableRecord({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.details,
  });

  final String title;
  final String subtitle;
  final String trailing;
  final Map<String, String> details;

  ManageableRecord copyWith({
    String? title,
    String? subtitle,
    String? trailing,
    Map<String, String>? details,
  }) {
    return ManageableRecord(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      trailing: trailing ?? this.trailing,
      details: details ?? this.details,
    );
  }
}

class ManageableSectionPage extends StatefulWidget {
  const ManageableSectionPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.createLabel,
    required this.recordLabel,
    required this.stats,
    required this.initialRecords,
    this.onCreate,
    this.onRecordTap,
    this.actions = const [],
  });

  final String title;
  final String subtitle;
  final String createLabel;
  final String recordLabel;
  final List<({String label, String value})> stats;
  final List<ManageableRecord> initialRecords;
  final VoidCallback? onCreate;
  final ValueChanged<ManageableRecord>? onRecordTap;
  final List<({IconData icon, String title, Color color})> actions;

  @override
  State<ManageableSectionPage> createState() => _ManageableSectionPageState();
}

class _ManageableSectionPageState extends State<ManageableSectionPage> {
  late List<ManageableRecord> _records;

  @override
  void initState() {
    super.initState();
    _records = List<ManageableRecord>.from(widget.initialRecords);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppShell(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              surfaceTintColor: Colors.transparent,
              title: Text(widget.title),
              actions: [
                IconButton(
                  onPressed: widget.onCreate ?? _showCreateDialog,
                  icon: const Icon(Icons.add_circle_outline_rounded),
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.subtitle,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: widget.onCreate ?? _showCreateDialog,
                        icon: const Icon(Icons.add_rounded),
                        label: Text(widget.createLabel),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final stat = widget.stats[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(stat.label),
                          const Spacer(),
                          Text(
                            stat.value,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ),
                  );
                }, childCount: widget.stats.length),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.35,
                ),
              ),
            ),
            if (widget.actions.isNotEmpty) ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'الإجراءات السريعة',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final action = widget.actions[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 42,
                              width: 42,
                              decoration: BoxDecoration(
                                color: action.color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(action.icon, color: action.color),
                            ),
                            const Spacer(),
                            Text(action.title),
                          ],
                        ),
                      ),
                    );
                  }, childCount: widget.actions.length),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.15,
                  ),
                ),
              ),
            ],
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              sliver: SliverList.separated(
                itemBuilder: (context, index) {
                  final record = _records[index];
                  return Card(
                    child: ListTile(
                      title: Text(record.title),
                      subtitle: Text(record.subtitle),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(record.trailing),
                          IconButton(
                            onPressed: () => widget.onRecordTap != null
                                ? widget.onRecordTap!(record)
                                : _openDetails(record),
                            icon: const Icon(Icons.info_outline_rounded),
                          ),
                          IconButton(
                            onPressed: () => _deleteRecord(index),
                            icon: const Icon(Icons.delete_outline_rounded),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemCount: _records.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetails(ManageableRecord record) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EntityDetailsPage(
          title: record.title,
          details: record.details,
        ),
      ),
    );
  }

  void _deleteRecord(int index) {
    setState(() => _records.removeAt(index));
  }

  Future<void> _showCreateDialog() async {
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();
    final trailingController = TextEditingController();

    final created = await showDialog<ManageableRecord>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(widget.createLabel),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'اسم ${widget.recordLabel}'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: subtitleController,
                decoration: const InputDecoration(labelText: 'وصف مختصر'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: trailingController,
                decoration: const InputDecoration(labelText: 'القيمة الجانبية'),
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
                Navigator.of(context).pop(
                  ManageableRecord(
                    title: titleController.text.trim().isEmpty
                        ? 'عنصر جديد'
                        : titleController.text.trim(),
                    subtitle: subtitleController.text.trim().isEmpty
                        ? 'تمت إضافته من الشاشة'
                        : subtitleController.text.trim(),
                    trailing: trailingController.text.trim().isEmpty
                        ? '-'
                        : trailingController.text.trim(),
                    details: {
                      'الاسم': titleController.text.trim().isEmpty
                          ? 'عنصر جديد'
                          : titleController.text.trim(),
                      'الوصف': subtitleController.text.trim().isEmpty
                          ? 'تمت إضافته من الشاشة'
                          : subtitleController.text.trim(),
                      'القيمة': trailingController.text.trim().isEmpty
                          ? '-'
                          : trailingController.text.trim(),
                    },
                  ),
                );
              },
              child: const Text('إضافة'),
            ),
          ],
        );
      },
    );

    if (created != null) {
      setState(() => _records.insert(0, created));
    }
  }
}
