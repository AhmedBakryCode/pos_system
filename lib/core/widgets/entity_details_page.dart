import 'package:flutter/material.dart';

class EntityDetailsPage extends StatelessWidget {
  const EntityDetailsPage({
    super.key,
    required this.title,
    required this.details,
    this.onManageLines,
  });

  final String title;
  final Map<String, String> details;
  final VoidCallback? onManageLines;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ...details.entries.map(
            (entry) => Card(
              child: ListTile(
                title: Text(entry.key),
                subtitle: Text(entry.value),
              ),
            ),
          ),
          if (onManageLines != null) ...[
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onManageLines,
              icon: const Icon(Icons.list_alt_rounded),
              label: const Text('إدارة سطور المعاملة والمنتجات'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
