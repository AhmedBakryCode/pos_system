import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../app/di/injection.dart';
import '../../../products/presentation/bloc/items_cubit.dart';
import '../../../products/presentation/bloc/items_state.dart';
import '../../domain/entities/stock_count.dart';
import '../bloc/stock_count_cubit.dart';
import '../bloc/stock_count_state.dart';
import 'stock_count_form_page.dart';

class StockCountsPage extends StatelessWidget {
  const StockCountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<StockCountCubit>()..loadStockCounts()),
        BlocProvider(create: (_) => sl<ItemsCubit>()..loadItems()),
      ],
      child: const _StockCountsView(),
    );
  }
}

class _StockCountsView extends StatelessWidget {
  const _StockCountsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('جرد المخزون')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final countCubit = context.read<StockCountCubit>();
          final itemsCubit = context.read<ItemsCubit>();
          await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: countCubit),
                  BlocProvider.value(value: itemsCubit),
                ],
                child: const StockCountFormPage(),
              ),
            ),
          );
        },
        child: const Icon(Icons.inventory_outlined),
      ),
      body: BlocConsumer<StockCountCubit, StockCountState>(
        listener: (context, state) {
          if (state.status == StockCountStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'حدث خطأ'),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == StockCountStatus.loading && state.stockCounts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.stockCounts.isEmpty && state.status == StockCountStatus.loaded) {
            return const Center(child: Text('لا توجد عمليات جرد مضافة بعد.'));
          }

          return RefreshIndicator(
            onRefresh: () => context.read<StockCountCubit>().loadStockCounts(refresh: true),
            child: BlocBuilder<ItemsCubit, ItemsState>(
              builder: (context, itemsState) {
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.stockCounts.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final stockCount = state.stockCounts[index];
                    return _StockCountCard(stockCount: stockCount, itemsState: itemsState);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _StockCountCard extends StatelessWidget {
  final StockCount stockCount;
  final ItemsState itemsState;

  const _StockCountCard({required this.stockCount, required this.itemsState});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<StockCountCubit>();
    final dateStr = stockCount.createdAt != null 
        ? DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(stockCount.createdAt!))
        : 'التاريخ غير متوفر';

    return Card(
      child: ExpansionTile(
        leading: Icon(
          stockCount.status == 'completed' ? Icons.check_circle : Icons.pending_actions,
          color: stockCount.status == 'completed' ? Colors.green : Colors.orange,
        ),
        title: Text('جرد #${stockCount.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$dateStr - الحالة: ${stockCount.status == 'completed' ? 'معتمد' : 'مسودة'}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const Text('الأصناف المجرودة:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 20,
                    columns: const [
                      DataColumn(label: Text('الصنف')),
                      DataColumn(label: Text('النظام')),
                      DataColumn(label: Text('الفعلي')),
                      DataColumn(label: Text('الفرق')),
                    ],
                    rows: stockCount.items.map((item) {
                      final product = itemsState.items.where((i) => i.id == item.itemId).firstOrNull;
                      final diff = double.tryParse(item.difference) ?? 0;
                      return DataRow(cells: [
                        DataCell(Text(product?.name ?? '#${item.itemId}')),
                        DataCell(Text(item.systemQuantity)),
                        DataCell(Text(item.actualQuantity)),
                        DataCell(Text(
                          item.difference,
                          style: TextStyle(
                            color: diff < 0 ? Colors.red : (diff > 0 ? Colors.green : null),
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                      ]);
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (stockCount.status != 'completed') ...[
                      TextButton.icon(
                        onPressed: () => _showApplyDialog(context, cubit, stockCount.id),
                        icon: const Icon(Icons.done_all, color: Colors.blue),
                        label: const Text('اعتماد الجرد'),
                      ),
                      const SizedBox(width: 8),
                    ],
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _showDeleteDialog(context, cubit, stockCount.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showApplyDialog(BuildContext context, StockCountCubit cubit, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('اعتماد الجرد'),
        content: const Text('هل أنت متأكد من اعتماد عملية الجرد؟ سيتم تعديل كميات النظام لتطابق الكميات الفعلية.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () {
              cubit.applyStockCount(id);
              Navigator.pop(ctx);
            },
            child: const Text('اعتماد'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, StockCountCubit cubit, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف عملية الجرد #$id؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              cubit.deleteStockCount(id);
              Navigator.pop(ctx);
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
