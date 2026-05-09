import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection.dart';
import '../../../products/presentation/bloc/items_cubit.dart';
import '../../../products/presentation/bloc/items_state.dart';
import '../../domain/entities/purchase_order.dart';
import '../bloc/purchases_cubit.dart';
import '../bloc/purchases_state.dart';
import 'purchase_form_page.dart';

class PurchasesPage extends StatelessWidget {
  const PurchasesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<PurchasesCubit>()..loadAll()),
        BlocProvider(create: (_) => sl<ItemsCubit>()..loadItems()),
      ],
      child: const _PurchasesView(),
    );
  }
}

class _PurchasesView extends StatelessWidget {
  const _PurchasesView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('أوامر الشراء')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final cubit = context.read<PurchasesCubit>();
          await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: cubit,
                child: const PurchaseFormPage(),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<PurchasesCubit, PurchasesState>(
        listener: (context, state) {
          if (state.status == PurchasesStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'حدث خطأ'),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == PurchasesStatus.loading && state.orders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.orders.isEmpty && state.status == PurchasesStatus.loaded) {
            return const Center(child: Text('لا توجد أوامر شراء بعد.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<PurchasesCubit>().loadAll(refresh: true);
              context.read<ItemsCubit>().loadItems();
            },
            child: BlocBuilder<ItemsCubit, ItemsState>(
              builder: (context, itemsState) {
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.orders.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final order = state.orders[index];
                    final supplier = state.suppliers.where(
                      (s) => s.id == order.supplierId,
                    ).firstOrNull;

                    return _PurchaseOrderCard(
                      order: order,
                      supplierName: supplier?.name ?? '#${order.supplierId}',
                      itemsState: itemsState,
                    );
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

class _PurchaseOrderCard extends StatelessWidget {
  final PurchaseOrder order;
  final String supplierName;
  final ItemsState itemsState;

  const _PurchaseOrderCard({
    required this.order, 
    required this.supplierName,
    required this.itemsState,
  });

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'approved':
        return 'معتمد';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PurchasesCubit>();
    final totalItems = order.items.length;
    final totalValue = order.items.fold<double>(
      0,
      (sum, item) => sum + (double.tryParse(item.price) ?? 0) * (double.tryParse(item.quantity) ?? 0),
    );

    return Card(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            'أمر شراء #${order.id}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('المورد: $supplierName'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(order.status).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusLabel(order.status),
                  style: TextStyle(
                    color: _statusColor(order.status),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: cubit,
                          child: PurchaseFormPage(order: order),
                        ),
                      ),
                    );
                  } else if (value == 'delete') {
                    _showDeleteDialog(context, cubit, order.id);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('تعديل')),
                  PopupMenuItem(value: 'delete', child: Text('حذف')),
                ],
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  ...order.items.map((item) {
                    final foundItem = itemsState.items.where((i) => i.id == item.itemId).firstOrNull;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(foundItem?.name ?? 'عنصر #${item.itemId}'),
                          Text(
                            'الكمية: ${item.quantity} × ${item.price}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$totalItems عنصر'),
                      Text(
                        'الإجمالي: ${totalValue.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, PurchasesCubit cubit, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف أمر الشراء #$id؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              cubit.deleteOrder(id);
              Navigator.pop(ctx);
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
