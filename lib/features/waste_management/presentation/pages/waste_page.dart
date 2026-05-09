import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../app/di/injection.dart';
import '../../../products/presentation/bloc/items_cubit.dart';
import '../../../products/presentation/bloc/items_state.dart';
import '../../domain/entities/waste.dart';
import '../bloc/waste_cubit.dart';
import '../bloc/waste_state.dart';
import 'waste_form_page.dart';

class WastePage extends StatelessWidget {
  const WastePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<WasteCubit>()..loadWastes()),
        BlocProvider(create: (_) => sl<ItemsCubit>()..loadItems()),
      ],
      child: const _WasteView(),
    );
  }
}

class _WasteView extends StatelessWidget {
  const _WasteView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('إدارة الهالك')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final wasteCubit = context.read<WasteCubit>();
          final itemsCubit = context.read<ItemsCubit>();
          await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: wasteCubit),
                  BlocProvider.value(value: itemsCubit),
                ],
                child: const WasteFormPage(),
              ),
            ),
          );
        },
        child: const Icon(Icons.delete_outline),
      ),
      body: BlocConsumer<WasteCubit, WasteState>(
        listener: (context, state) {
          if (state.status == WasteStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'حدث خطأ'),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == WasteStatus.loading && state.wastes.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.wastes.isEmpty && state.status == WasteStatus.loaded) {
            return const Center(child: Text('لا توجد سجلات هالك مضافة بعد.'));
          }

          return RefreshIndicator(
            onRefresh: () => context.read<WasteCubit>().loadWastes(refresh: true),
            child: BlocBuilder<ItemsCubit, ItemsState>(
              builder: (context, itemsState) {
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.wastes.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final waste = state.wastes[index];
                    return _WasteCard(waste: waste, itemsState: itemsState);
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

class _WasteCard extends StatelessWidget {
  final Waste waste;
  final ItemsState itemsState;

  const _WasteCard({required this.waste, required this.itemsState});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WasteCubit>();
    final dateStr = waste.createdAt != null 
        ? DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(waste.createdAt!))
        : 'التاريخ غير متوفر';

    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
        title: Text(waste.reason, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(dateStr),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const Text('الأصناف الهالكة:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...waste.items.map((item) {
                  final product = itemsState.items.where((i) => i.id == item.itemId).firstOrNull;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(product?.name ?? 'صنف #${item.itemId}'),
                        Text('الكمية: ${item.quantity}'),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                      onPressed: () {
                        final wasteCubit = context.read<WasteCubit>();
                        final itemsCubit = context.read<ItemsCubit>();
                        Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (_) => MultiBlocProvider(
                              providers: [
                                BlocProvider.value(value: wasteCubit),
                                BlocProvider.value(value: itemsCubit),
                              ],
                              child: WasteFormPage(waste: waste),
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _showDeleteDialog(context, cubit, waste.id),
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

  void _showDeleteDialog(BuildContext context, WasteCubit cubit, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف سجل الهالك #$id؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              cubit.deleteWaste(id);
              Navigator.pop(ctx);
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
