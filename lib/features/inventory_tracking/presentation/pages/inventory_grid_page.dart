import 'package:flutter/material.dart';

import '../../../../core/widgets/grid_selection_page.dart';
import '../../../production_management/presentation/pages/production_page.dart';
import '../../../waste_management/presentation/pages/waste_page.dart';
import '../../../stock_counting/presentation/pages/stock_counts_page.dart';

class InventoryGridPage extends StatelessWidget {
  const InventoryGridPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GridSelectionPage(
      title: 'المخزون',
      subtitle: 'اختر القسم الذي تريد إدارته',
      items: [
        // GridItem(
        //   title: 'دفتر المخزون',
        //   subtitle: 'عرض وتتبع أرصدة المخزون الحالية',
        //   icon: Icons.inventory_2_outlined,
        //   color: const Color(0xFF0F766E),
        //   onTap: () {
        //     Navigator.of(context).push(
        //       MaterialPageRoute(builder: (_) => const InventoryPage()),
        //     );
        //   },
        // ),
        GridItem(
          title: 'الإنتاج',
          subtitle: 'إدارة أوامر وعمليات الإنتاج',
          icon: Icons.precision_manufacturing_outlined,
          color: const Color(0xFFD97706),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProductionPage()),
            );
          },
        ),
        GridItem(
          title: 'الهالك',
          subtitle: 'تسجيل وإدارة المنتجات التالفة',
          icon: Icons.delete_outline,
          color: const Color(0xFFDC2626),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const WastePage()),
            );
          },
        ),
        GridItem(
          title: 'جرد المخزون',
          subtitle: 'إجراء عمليات الجرد وتدقيق المخازن',
          icon: Icons.checklist_rtl_outlined,
          color: const Color(0xFF6366F1),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const StockCountsPage()),
            );
          },
        ),
      ],
    );
  }
}
