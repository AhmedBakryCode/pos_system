import 'package:flutter/material.dart';

import '../../../../core/widgets/manageable_section_page.dart';
import '../../../transactions/domain/entities/transaction_type.dart';
import '../../../transactions/presentation/pages/transaction_screen.dart';

class PosIntegrationPage extends StatelessWidget {
  const PosIntegrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ManageableSectionPage(
      title: 'تكامل نقاط البيع',
      subtitle: 'مراقبة الطلبات والمزامنة والمرتجعات وفروقات الربط.',
      createLabel: 'إضافة عملية POS',
      recordLabel: 'العملية',
      onCreate: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              const TransactionScreen(initialType: TransactionType.sale),
        ),
      ),
      onRecordTap: (record) => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              const TransactionScreen(initialType: TransactionType.sale),
        ),
      ),
      stats: const [
        (label: 'طلبات متزامنة', value: '1,242'),
        (label: 'بانتظار مزامنة', value: '16'),
        (label: 'مرتجعات', value: '8'),
        (label: 'فروقات', value: '2'),
      ],
      initialRecords: const [
        ManageableRecord(
          title: 'POS-10342',
          subtitle: 'تم ترحيلها للمخزون',
          trailing: '18 صنف',
          details: {
            'الطلب': 'POS-10342',
            'الحالة': 'تم الترحيل',
            'العناصر': '18',
          },
        ),
        ManageableRecord(
          title: 'POS-10339',
          subtitle: 'بانتظار إعادة المحاولة',
          trailing: '6 أصناف',
          details: {
            'الطلب': 'POS-10339',
            'الحالة': 'بانتظار إعادة المحاولة',
            'العناصر': '6',
          },
        ),
      ],
    );
  }
}
