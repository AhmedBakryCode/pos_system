import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_shell.dart';
import '../widgets/activity_feed_card.dart';
import '../widgets/alerts_panel_card.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  static const _activities = [
    (
      title: 'تم ترحيل خصم مخزون',
      description: 'طلب POS رقم #10342 خصم 18 وحدة من المخزن الرئيسي.',
      time: 'منذ دقيقتين',
      tag: 'POS',
      color: Color(0xFF4B3FDC),
      icon: Icons.point_of_sale_rounded,
    ),
    (
      title: 'تم اعتماد أمر شراء',
      description: 'أمر شراء PO-2048 معتمد لتوريد أغذية النيل.',
      time: 'منذ 18 دقيقة',
      tag: 'PO',
      color: Color(0xFF2563EB),
      icon: Icons.shopping_cart_checkout_rounded,
    ),
    (
      title: 'إشعار استلام GRN معلق',
      description: 'استلم فريق المخازن أصناف مبردة بانتظار فحص الجودة.',
      time: 'منذ 31 دقيقة',
      tag: 'GRN',
      color: Color(0xFF0EA5E9),
      icon: Icons.local_shipping_rounded,
    ),
    (
      title: 'بدء تشغيل دفعة إنتاج',
      description: 'بدأت الدفعة PR-771 مع حجز 4 مكونات خام.',
      time: 'منذ 54 دقيقة',
      tag: 'إنتاج',
      color: Color(0xFFD97706),
      icon: Icons.precision_manufacturing_rounded,
    ),
  ];

  static const _alerts = [
    (
      title: 'تحذير مخزون منخفض',
      description: 'معجون الطماطم أقل من نقطة إعادة الطلب في المطبخ المركزي.',
      severity: 'مخزون منخفض',
      time: 'الآن',
      color: Color(0xFFD98E04),
    ),
    (
      title: 'تنبيه GRN مفقود',
      description: 'تم تسليم PO-2039 ولكن لم يتم ترحيل إشعار الاستلام.',
      severity: 'استلام معلق',
      time: '12 دقيقة',
      color: Color(0xFF2563EB),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColors = theme.extension<AppStatusColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('التنبيهات والنشاط'),
        centerTitle: true,
      ),
      body: AppShell(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            Text(
              'تنبيهات النظام',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            AlertsPanelCard(
              alerts: _alerts,
              warningColor: statusColors.warning,
              infoColor: statusColors.info,
              errorColor: statusColors.error,
            ),
            const SizedBox(height: 32),
            Text(
              'سجل النشاط المباشر',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ActivityFeedCard(activities: _activities),
          ],
        ),
      ),
    );
  }
}
