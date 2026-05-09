import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../products/presentation/bloc/items_cubit.dart';
import '../bloc/reports_cubit.dart';
import '../bloc/reports_state.dart';

class InventoryReportPage extends StatefulWidget {
  const InventoryReportPage({super.key});

  @override
  State<InventoryReportPage> createState() => _InventoryReportPageState();
}

class _InventoryReportPageState extends State<InventoryReportPage> {
  @override
  void initState() {
    super.initState();
    context.read<ReportsCubit>().loadInventoryReport();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تقرير المخزون')),
      body: BlocBuilder<ReportsCubit, ReportsState>(
        builder: (context, state) {
          if (state.status == ReportsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ReportsStatus.error) {
            return Center(child: Text(state.errorMessage ?? 'خطأ في جلب البيانات'));
          }

          if (state.inventoryReport.isEmpty) {
            return const Center(child: Text('لا توجد بيانات للمخزون حالياً'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.inventoryReport.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final item = state.inventoryReport[index];
              return _InventoryItemTile(reportItem: item);
            },
          );
        },
      ),
    );
  }
}

class _InventoryItemTile extends StatelessWidget {
  const _InventoryItemTile({required this.reportItem});

  final dynamic reportItem;

  @override
  Widget build(BuildContext context) {
    // Get product name from ItemsCubit if available
    final itemsState = context.watch<ItemsCubit>().state;
    final items = itemsState.items.where((i) => i.id == reportItem.itemId);
    final productName = items.isNotEmpty ? items.first.name : 'صنف رقم ${reportItem.itemId}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.shade50,
            child: const Icon(Icons.inventory_2, color: Colors.blue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'رقم الصنف: ${reportItem.itemId}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${reportItem.quantity} وحدة',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              ),
              Text(
                'القيمة: ${reportItem.value} ج.م',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
