import 'package:flutter/material.dart';

import '../../../../core/offline/sync_service.dart';
import '../../../audit_reports/domain/usecases/get_audit_kpis.dart';
import '../../../inventory_tracking/domain/usecases/get_inventory_summary.dart';
import '../../../pos_integration/domain/usecases/get_pos_sync_status.dart';
import '../../../purchase_orders/domain/usecases/get_purchase_order_summary.dart';
import '../entities/dashboard_metric.dart';
import '../entities/dashboard_module.dart';
import 'dashboard_metrics_service.dart';

class DashboardMetricsServiceImpl implements DashboardMetricsService {
  DashboardMetricsServiceImpl({
    required GetInventorySummary getInventorySummary,
    required GetPurchaseOrderSummary getPurchaseOrderSummary,
    required GetPosSyncStatus getPosSyncStatus,
    required GetAuditKpis getAuditKpis,
    required SyncService syncService,
  }) : _getInventorySummary = getInventorySummary,
       _getPurchaseOrderSummary = getPurchaseOrderSummary,
       _getPosSyncStatus = getPosSyncStatus,
       _getAuditKpis = getAuditKpis,
       _syncService = syncService;

  final GetInventorySummary _getInventorySummary;
  final GetPurchaseOrderSummary _getPurchaseOrderSummary;
  final GetPosSyncStatus _getPosSyncStatus;
  final GetAuditKpis _getAuditKpis;
  final SyncService _syncService;

  @override
  Future<List<DashboardMetric>> getTopMetrics() async {
    final inventory = await _getInventorySummary();
    final purchaseOrders = await _getPurchaseOrderSummary();
    final posStatus = await _getPosSyncStatus();
    final audit = await _getAuditKpis();
    final pendingSync = await _syncService.pendingOperationsCount();

    return [
      DashboardMetric(
        label: 'قيمة المخزون',
        value: '\$${inventory.stockValue.toStringAsFixed(0)}',
        highlight: '${inventory.lowStockItems} تنبيه انخفاض',
        description: 'تقييم مباشر للمخزون عبر الفروع والمخازن.',
      ),
      DashboardMetric(
        label: 'المشتريات المفتوحة',
        value: '${purchaseOrders.openOrders}',
        highlight: '${purchaseOrders.pendingReceipts} استلامات معلقة',
        description: 'أوامر شراء تنتظر الاعتماد أو الاستلام.',
      ),
      DashboardMetric(
        label: 'مزامنة نقاط البيع',
        value: '${posStatus.syncedOrders}/${posStatus.totalOrders}',
        highlight: '$pendingSync عمليات في قائمة الانتظار',
        description: 'طلبات نقاط البيع المرحّلة إلى حركات المخزون.',
      ),
      DashboardMetric(
        label: 'استثناءات التدقيق',
        value: '${audit.exceptionCount}',
        highlight: '${audit.pendingReviews} مراجعات معلقة',
        description: 'متابعة الاستثناءات وسجل التتبع التشغيلي.',
      ),
    ];
  }

  @override
  Future<List<DashboardModule>> getModules() async {
    return const [
      DashboardModule(
        title: 'المشتريات',
        subtitle: 'إدارة أوامر الشراء والموردين',
        icon: Icons.shopping_cart_checkout_outlined,
        color: Color(0xFF2563EB),
        metrics: [],
      ),
      DashboardModule(
        title: 'استلام البضائع',
        subtitle: 'استلام البضاعة وتحديث المخزون',
        icon: Icons.local_shipping_outlined,
        color: Color(0xFF7C3AED),
        metrics: [],
      ),
      DashboardModule(
        title: 'الموردين',
        subtitle: 'إدارة حسابات الموردين',
        icon: Icons.people_outline,
        color: Color(0xFFD97706),
        metrics: [],
      ),
      DashboardModule(
        title: 'المخزون',
        subtitle: 'إدارة المخزون والإنتاج والهالك',
        icon: Icons.inventory_2_outlined,
        color: Color(0xFF0F766E),
        metrics: [],
      ),
      DashboardModule(
        title: 'الطلبات',
        subtitle: 'إدارة طلبات العملاء',
        icon: Icons.receipt_long_outlined,
        color: Color(0xFF0891B2),
        metrics: [],
      ),
      DashboardModule(
        title: 'الملف الشخصي',
        subtitle: 'إعدادات الحساب والصلاحيات',
        icon: Icons.person_outline,
        color: Color(0xFF4F46E5),
        metrics: [],
      ),
      DashboardModule(
        title: 'المنتجات',
        subtitle: 'إدارة الأصناف، الفئات والوحدات',
        icon: Icons.category_outlined,
        color: Color(0xFF475569),
        metrics: [],
      ),
      DashboardModule(
        title: 'التقارير',
        subtitle: 'تقارير الأرباح والمخزون وحركات الأصناف',
        icon: Icons.bar_chart_outlined,
        color: Color(0xFFE11D48),
        metrics: [],
      ),
    ];
  }
}
