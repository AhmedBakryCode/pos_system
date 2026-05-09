import 'package:flutter/material.dart';
import 'package:pos_system/features/transactions/domain/entities/transaction_type.dart';

import '../../../../core/widgets/manageable_section_page.dart';
import '../../../transactions/presentation/pages/transaction_screen.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ManageableSectionPage(
      title: 'تتبع المخزون',
      subtitle: 'متابعة الأرصدة والحركات والتوفر عبر المخازن.',
      createLabel: 'إضافة صنف مخزني',
      recordLabel: 'الصنف',
      onCreate: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const TransactionScreen(
            initialType: TransactionType.stockAdjustment,
          ),
        ),
      ),
      onRecordTap: (record) => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const TransactionScreen(
            initialType: TransactionType.stockAdjustment,
          ),
        ),
      ),
      stats: const [
        (label: 'المتوفر', value: '1,248'),
        (label: 'منخفض', value: '14'),
        (label: 'محجوز', value: '126'),
        (label: 'التشغيلات', value: '83'),
      ],

      initialRecords: const [
        ManageableRecord(
          title: 'فيليه دجاج',
          subtitle: 'SKU-1001 • مخزن تبريد',
          trailing: '24 كجم',
          details: {
            'الكود': 'SKU-1001',
            'الموقع': 'مخزن تبريد',
            'الرصيد': '24 كجم',
          },
        ),
        ManageableRecord(
          title: 'جبنة موزاريلا',
          subtitle: 'SKU-1002 • مخزن تبريد',
          trailing: '10 صندوق',
          details: {
            'الكود': 'SKU-1002',
            'الموقع': 'مخزن تبريد',
            'الرصيد': '10 صندوق',
          },
        ),
      ],
    );
  }
}
