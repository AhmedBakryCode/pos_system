import 'package:flutter/material.dart';

import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../goods_receipt_notes/presentation/pages/grn_page.dart';
import '../../../inventory_tracking/presentation/pages/inventory_grid_page.dart';
import '../../../purchase_orders/presentation/pages/purchases_page.dart';

import '../../../products/presentation/pages/products_grid_page.dart';
import '../../../purchase_orders/presentation/pages/suppliers_page.dart';
import '../../../orders/presentation/pages/orders_page.dart';
import '../../../reports/presentation/pages/reports_grid_page.dart';
import '../../../auth/presentation/pages/profile_page.dart';

class MainNavigationPage extends StatelessWidget {
  const MainNavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DashboardPage(
        onModuleTap: (module) => _handleModuleTap(context, module),
      ),
    );
  }

  void _handleModuleTap(BuildContext context, String module) {
    if (module == 'المشتريات') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PurchasesPage()),
      );
      return;
    }

    if (module == 'استلام البضائع') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const GrnPage()),
      );
      return;
    }

    if (module == 'الموردين') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SuppliersPage()),
      );
      return;
    }

    if (module == 'المخزون') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const InventoryGridPage()),
      );
      return;
    }

    if (module == 'الطلبات') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const OrdersPage()),
      );
      return;
    }

    if (module == 'المنتجات') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ProductsGridPage()),
      );
      return;
    }

    if (module == 'التقارير') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ReportsGridPage()),
      );
      return;
    }

    if (module == 'الملف الشخصي') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ProfilePage()),
      );
      return;
    }
  }
}

