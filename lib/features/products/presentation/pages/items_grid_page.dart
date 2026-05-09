import 'package:flutter/material.dart';

import '../../../../core/widgets/grid_selection_page.dart';
import 'items_list_page.dart';
import '../../../recipes/presentation/pages/recipes_page.dart';

class ItemsGridPage extends StatelessWidget {
  const ItemsGridPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GridSelectionPage(
      title: 'العناصر',
      subtitle: 'اختر نوع العناصر',
      items: [
        GridItem(
          title: 'المواد الخام',
          subtitle: 'إدارة وعرض المواد الخام',
          icon: Icons.grass_outlined,
          color: const Color(0xFF10B981),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ItemsListPage(title: 'المواد الخام', itemType: 'raw'),
              ),
            );
          },
        ),
        GridItem(
          title: 'المنتجات النهائية',
          subtitle: 'إدارة المنتجات الجاهزة للبيع',
          icon: Icons.check_circle_outline,
          color: const Color(0xFF3B82F6),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ItemsListPage(title: 'المنتجات النهائية', itemType: 'finished'),
              ),
            );
          },
        ),
        GridItem(
          title: 'نصف المصنعة',
          subtitle: 'إدارة المنتجات قيد التصنيع',
          icon: Icons.build_circle_outlined,
          color: const Color(0xFFF59E0B),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ItemsListPage(title: 'نصف المصنعة', itemType: 'semi-finished'),
              ),
            );
          },
        ),
        GridItem(
          title: 'الوصفات',
          subtitle: 'إدارة وصفات الإنتاج',
          icon: Icons.menu_book_outlined,
          color: const Color(0xFF4F46E5),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RecipesPage()),
            );
          },
        ),
      ],
    );
  }
}
