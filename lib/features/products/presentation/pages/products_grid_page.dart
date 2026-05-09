import 'package:flutter/material.dart';

import '../../../../core/widgets/grid_selection_page.dart';
import 'categories_page.dart';
import 'items_grid_page.dart';
import 'units_page.dart';

class ProductsGridPage extends StatelessWidget {
  const ProductsGridPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GridSelectionPage(
      title: 'المنتجات',
      subtitle: 'إدارة المنتجات والفئات والوحدات',
      items: [
        GridItem(
          title: 'العناصر',
          subtitle: 'المواد الخام، والمنتجات النهائية، ونصف المصنعة',
          icon: Icons.inventory_2_outlined,
          color: const Color(0xFF3B82F6),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ItemsGridPage()),
            );
          },
        ),
        GridItem(
          title: 'الفئات',
          subtitle: 'إدارة فئات وتصنيفات المنتجات',
          icon: Icons.category_outlined,
          color: const Color(0xFF8B5CF6),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CategoriesPage()),
            );
          },
        ),
        GridItem(
          title: 'الوحدات',
          subtitle: 'إدارة وحدات القياس',
          icon: Icons.straighten_outlined,
          color: const Color(0xFF10B981),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const UnitsPage()),
            );
          },
        ),
      ],
    );
  }
}
