import 'package:flutter/material.dart';
import 'package:pos_system/features/transactions/domain/entities/transaction_type.dart';

import '../../../../core/widgets/manageable_section_page.dart';
import '../../../transactions/presentation/pages/transaction_screen.dart';

class PurchaseOrdersPage extends StatelessWidget {
  const PurchaseOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ManageableSectionPage(
      title: 'أوامر الشراء',
      subtitle: 'إنشاء ومتابعة واعتماد أوامر الشراء من الموردين.',
      createLabel: 'إضافة أمر شراء',
      recordLabel: 'الأمر',
      onCreate: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              const TransactionScreen(initialType: TransactionType.po),
        ),
      ),
      onRecordTap: (record) => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              const TransactionScreen(initialType: TransactionType.po),
        ),
      ),
      stats: const [
        (label: 'المفتوح', value: '18'),
        (label: 'بانتظار اعتماد', value: '5'),
        (label: 'مستحق اليوم', value: '3'),
        (label: 'الموردون', value: '22'),
      ],

      initialRecords: const [
        ManageableRecord(
          title: 'PO-2048',
          subtitle: 'نيل فودز • 6 أصناف',
          trailing: 'معتمد',
          details: {'المورد': 'نيل فودز', 'الأصناف': '6', 'الحالة': 'معتمد'},
        ),
        ManageableRecord(
          title: 'PO-2047',
          subtitle: 'فريش ديري • 4 أصناف',
          trailing: 'معلق',
          details: {'المورد': 'فريش ديري', 'الأصناف': '4', 'الحالة': 'معلق'},
        ),
      ],
    );
  }
}
