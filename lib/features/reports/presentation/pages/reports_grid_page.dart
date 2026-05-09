import 'package:flutter/material.dart';
import '../../../../core/widgets/grid_selection_page.dart';
import 'inventory_report_page.dart';
import 'profit_report_page.dart';
import 'movements_report_page.dart';
import 'variance_report_page.dart';
import 'daily_report_page.dart';
import 'top_products_report_page.dart';

class ReportsGridPage extends StatelessWidget {
  const ReportsGridPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GridSelectionPage(
      title: 'التقارير',
      subtitle: 'اختر التقرير الذي تريد عرضه',
      items: [
        GridItem(
          title: 'تقرير المخزون',
          subtitle: 'عرض تفصيلي لأرصدة وقيمة المخزون',
          icon: Icons.inventory_2_outlined,
          color: Colors.blue,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const InventoryReportPage()),
          ),
        ),
        GridItem(
          title: 'تقرير الأرباح',
          subtitle: 'تحليل الأرباح والخسائر خلال فترة',
          icon: Icons.monetization_on_outlined,
          color: Colors.green,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ProfitReportPage()),
          ),
        ),
        GridItem(
          title: 'حركات المخزون',
          subtitle: 'تتبع حركة كل صنف وارد وصادر',
          icon: Icons.swap_horiz_outlined,
          color: Colors.orange,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MovementsReportPage()),
          ),
        ),
        GridItem(
          title: 'تقرير الانحراف',
          subtitle: 'الفرق بين المخزون الفعلي والدفتري',
          icon: Icons.difference_outlined,
          color: Colors.red,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const VarianceReportPage()),
          ),
        ),
        GridItem(
          title: 'التقرير اليومي',
          subtitle: 'ملخص المبيعات والمشتريات اليومية',
          icon: Icons.today_outlined,
          color: Colors.purple,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const DailyReportPage()),
          ),
        ),
        GridItem(
          title: 'الأكثر مبيعاً',
          subtitle: 'قائمة بأكثر الأصناف طلباً',
          icon: Icons.star_outline,
          color: Colors.amber,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TopProductsReportPage()),
          ),
        ),
      ],
    );
  }
}
