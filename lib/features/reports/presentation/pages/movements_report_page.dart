import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../products/presentation/bloc/items_cubit.dart';
import '../bloc/reports_cubit.dart';
import '../bloc/reports_state.dart';

class MovementsReportPage extends StatefulWidget {
  const MovementsReportPage({super.key});

  @override
  State<MovementsReportPage> createState() => _MovementsReportPageState();
}

class _MovementsReportPageState extends State<MovementsReportPage> {
  @override
  void initState() {
    super.initState();
    context.read<ReportsCubit>().loadMovementsReport(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حركات المخزون')),
      body: BlocBuilder<ReportsCubit, ReportsState>(
        builder: (context, state) {
          if (state.status == ReportsStatus.loading && state.movementsReport.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ReportsStatus.error && state.movementsReport.isEmpty) {
            return Center(child: Text(state.errorMessage ?? 'خطأ في جلب البيانات'));
          }

          if (state.movementsReport.isEmpty) {
            return const Center(child: Text('لا توجد حركات مخزون حالياً'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.movementsReport.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final item = state.movementsReport[index];
              return _MovementItemTile(reportItem: item);
            },
          );
        },
      ),
    );
  }
}

class _MovementItemTile extends StatelessWidget {
  const _MovementItemTile({required this.reportItem});

  final dynamic reportItem;

  @override
  Widget build(BuildContext context) {
    final itemsState = context.watch<ItemsCubit>().state;
    final matchingItems = itemsState.items.where((i) => i.id == reportItem.itemId);
    final product = matchingItems.isNotEmpty ? matchingItems.first : null;

    Color typeColor;
    String typeLabel;
    IconData icon;

    switch (reportItem.type) {
      case 'adjustment':
        typeColor = Colors.blue;
        typeLabel = 'تسوية جرد';
        icon = Icons.edit_note;
        break;
      case 'waste':
        typeColor = Colors.red;
        typeLabel = 'هالك';
        icon = Icons.delete_outline;
        break;
      case 'sale':
        typeColor = Colors.green;
        typeLabel = 'مبيعات';
        icon = Icons.shopping_cart_outlined;
        break;
      case 'production_in':
        typeColor = Colors.teal;
        typeLabel = 'إنتاج وارد';
        icon = Icons.add_box_outlined;
        break;
      case 'production_out':
        typeColor = Colors.orange;
        typeLabel = 'إنتاج صادر';
        icon = Icons.outbox_outlined;
        break;
      default:
        typeColor = Colors.grey;
        typeLabel = reportItem.type;
        icon = Icons.swap_horiz;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: typeColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product?.name ?? 'صنف رقم ${reportItem.itemId}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      typeLabel,
                      style: TextStyle(color: typeColor, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${reportItem.quantity} وحدة',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    reportItem.createdAt?.split('T').first ?? '',
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MiniDetail(label: 'قبل', value: reportItem.beforeQuantity),
                const Icon(Icons.arrow_forward, size: 14, color: Colors.grey),
                _MiniDetail(label: 'بعد', value: reportItem.afterQuantity),
                _MiniDetail(label: 'التكلفة', value: '${reportItem.unitCost}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniDetail extends StatelessWidget {
  const _MiniDetail({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
