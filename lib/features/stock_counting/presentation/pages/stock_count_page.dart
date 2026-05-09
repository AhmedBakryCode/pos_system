import 'package:flutter/material.dart';

import '../../../../core/widgets/manageable_section_page.dart';
import '../../../transactions/domain/entities/transaction_type.dart'
    show TransactionType;
import '../../../transactions/presentation/pages/transaction_screen.dart';

class StockCountPage extends StatelessWidget {
  const StockCountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ManageableSectionPage(
      title: 'جرد المخزون',
      subtitle: 'تشغيل جلسات الجرد ومراجعة الفروقات وترحيل التسويات.',
      createLabel: 'إضافة جلسة جرد',
      recordLabel: 'الجلسة',
      onCreate: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              const TransactionScreen(initialType: TransactionType.stockCount),
        ),
      ),
      onRecordTap: (record) => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              const TransactionScreen(initialType: TransactionType.stockCount),
        ),
      ),
      stats: const [
        (label: 'جلسات مفتوحة', value: '4'),
        (label: 'بانتظار مراجعة', value: '2'),
        (label: 'فروقات', value: '9'),
        (label: 'أصناف معدلة', value: '21'),
      ],

      initialRecords: const [
        ManageableRecord(
          title: 'COUNT-031',
          subtitle: 'المخزن الرئيسي',
          trailing: 'فروقات',
          details: {
            'الجلسة': 'COUNT-031',
            'الموقع': 'المخزن الرئيسي',
            'الحالة': 'فروقات',
          },
        ),
        ManageableRecord(
          title: 'COUNT-029',
          subtitle: 'مخزن تبريد',
          trailing: 'جاهز',
          details: {
            'الجلسة': 'COUNT-029',
            'الموقع': 'مخزن تبريد',
            'الحالة': 'جاهز',
          },
        ),
      ],
    );
  }
}
