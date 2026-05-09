import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../app/di/injection.dart';
import '../../../products/presentation/bloc/items_cubit.dart';
import '../../../products/presentation/bloc/items_state.dart';
import '../../domain/entities/order.dart';
import '../bloc/order_cubit.dart';
import '../bloc/order_state.dart';
import 'order_form_page.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<OrderCubit>()..loadOrders()),
        BlocProvider(create: (_) => sl<ItemsCubit>()..loadItems()),
      ],
      child: const _OrdersView(),
    );
  }
}

class _OrdersView extends StatelessWidget {
  const _OrdersView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('الطلبات والمبيعات')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final orderCubit = context.read<OrderCubit>();
          final itemsCubit = context.read<ItemsCubit>();
          await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: orderCubit),
                  BlocProvider.value(value: itemsCubit),
                ],
                child: const OrderFormPage(),
              ),
            ),
          );
        },
        child: const Icon(Icons.add_shopping_cart_outlined),
      ),
      body: BlocConsumer<OrderCubit, OrderState>(
        listener: (context, state) {
          if (state.status == OrderStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'حدث خطأ'),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == OrderStatus.loading && state.orders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.orders.isEmpty && state.status == OrderStatus.loaded) {
            return const Center(child: Text('لا توجد طلبات مضافة بعد.'));
          }

          return RefreshIndicator(
            onRefresh: () => context.read<OrderCubit>().loadOrders(refresh: true),
            child: BlocBuilder<ItemsCubit, ItemsState>(
              builder: (context, itemsState) {
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.orders.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = state.orders[index];
                    return _OrderCard(order: order, itemsState: itemsState);
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

class _OrderCard extends StatelessWidget {
  final SalesOrder order;
  final ItemsState itemsState;

  const _OrderCard({required this.order, required this.itemsState});

  @override
  Widget build(BuildContext context) {
    final dateStr = order.createdAt != null 
        ? DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(order.createdAt!))
        : 'التاريخ غير متوفر';

    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.receipt_long_outlined, color: Colors.green),
        title: Text('طلب #${order.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$dateStr - الإجمالي: ${order.total}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('الحالة:', style: TextStyle(fontWeight: FontWeight.bold)),
                    _StatusBadge(status: order.status),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('إجمالي التكلفة:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(order.totalCost ?? '0.00'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('الربح:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(order.profit ?? '0.00', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('الأصناف:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...order.items.map((item) {
                  final product = itemsState.items.where((i) => i.id == item.itemId).firstOrNull;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(product?.name ?? 'صنف #${item.itemId}')),
                        Text('${item.quantity} x ${item.sellingPrice} = ${item.total}'),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => _showDeleteDialog(context, context.read<OrderCubit>(), order.id),
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                    label: const Text('حذف الطلب', style: TextStyle(color: Colors.red)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, OrderCubit cubit, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف الطلب #$id؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
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

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey;
    String label = status;

    if (status == 'completed') {
      color = Colors.green;
      label = 'مكتمل';
    } else if (status == 'pending') {
      color = Colors.orange;
      label = 'قيد الانتظار';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}
