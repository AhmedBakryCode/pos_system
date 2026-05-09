import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../products/presentation/bloc/items_cubit.dart';
import '../bloc/reports_cubit.dart';
import '../bloc/reports_state.dart';

class TopProductsReportPage extends StatefulWidget {
  const TopProductsReportPage({super.key});

  @override
  State<TopProductsReportPage> createState() => _TopProductsReportPageState();
}

class _TopProductsReportPageState extends State<TopProductsReportPage> {
  @override
  void initState() {
    super.initState();
    context.read<ReportsCubit>().loadTopProductsReport();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الأكثر مبيعاً')),
      body: BlocBuilder<ReportsCubit, ReportsState>(
        builder: (context, state) {
          if (state.status == ReportsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ReportsStatus.error) {
            return Center(child: Text(state.errorMessage ?? 'خطأ في جلب البيانات'));
          }

          if (state.topProductsReport.isEmpty) {
            return const Center(child: Text('لا توجد بيانات متاحة حالياً'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.topProductsReport.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final item = state.topProductsReport[index];
              return _TopProductItemTile(reportItem: item, rank: index + 1);
            },
          );
        },
      ),
    );
  }
}

class _TopProductItemTile extends StatelessWidget {
  const _TopProductItemTile({required this.reportItem, required this.rank});

  final dynamic reportItem;
  final int rank;

  @override
  Widget build(BuildContext context) {
    final itemsState = context.watch<ItemsCubit>().state;
    final items = itemsState.items.where((i) => i.id == reportItem.itemId);
    final productName = items.isNotEmpty ? items.first.name : 'صنف رقم ${reportItem.itemId}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: rank <= 3 ? Colors.amber.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: rank <= 3 ? Colors.amber.shade700 : Colors.grey,
                ),
              ),
            ),
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
                '${reportItem.totalSold}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.blue,
                ),
              ),
              const Text(
                'إجمالي المباع',
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
