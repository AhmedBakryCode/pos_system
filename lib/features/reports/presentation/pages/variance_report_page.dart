import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../products/presentation/bloc/items_cubit.dart';
import '../bloc/reports_cubit.dart';
import '../bloc/reports_state.dart';

class VarianceReportPage extends StatefulWidget {
  const VarianceReportPage({super.key});

  @override
  State<VarianceReportPage> createState() => _VarianceReportPageState();
}

class _VarianceReportPageState extends State<VarianceReportPage> {
  @override
  void initState() {
    super.initState();
    context.read<ReportsCubit>().loadVarianceReport();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تقرير الانحراف')),
      body: BlocBuilder<ReportsCubit, ReportsState>(
        builder: (context, state) {
          if (state.status == ReportsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ReportsStatus.error) {
            return Center(child: Text(state.errorMessage ?? 'خطأ في جلب البيانات'));
          }

          if (state.varianceReport.isEmpty) {
            return const Center(child: Text('لا توجد فروق جرد حالياً'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.varianceReport.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final item = state.varianceReport[index];
              return _VarianceItemTile(reportItem: item);
            },
          );
        },
      ),
    );
  }
}

class _VarianceItemTile extends StatelessWidget {
  const _VarianceItemTile({required this.reportItem});

  final dynamic reportItem;

  @override
  Widget build(BuildContext context) {
    final itemsState = context.watch<ItemsCubit>().state;
    final matchingItems = itemsState.items.where((i) => i.id == reportItem.itemId);
    final product = matchingItems.isNotEmpty ? matchingItems.first : null;

    final diff = double.tryParse(reportItem.difference) ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: diff >= 0 ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                child: Icon(
                  diff >= 0 ? Icons.trending_up : Icons.trending_down,
                  color: diff >= 0 ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product?.name ?? 'صنف رقم ${reportItem.itemId}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      'جرد رقم: ${reportItem.stockCountId}',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${reportItem.difference} وحدة',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: diff >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                  Text(
                    'القيمة: ${reportItem.totalCost} ج.م',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatBox(label: 'النظام', value: reportItem.systemQuantity, color: Colors.blue),
              const SizedBox(width: 8),
              _StatBox(label: 'الفعلي', value: reportItem.actualQuantity, color: Colors.orange),
              const SizedBox(width: 8),
              _StatBox(label: 'التكلفة/وحدة', value: reportItem.unitCost, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 10, color: color)),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
