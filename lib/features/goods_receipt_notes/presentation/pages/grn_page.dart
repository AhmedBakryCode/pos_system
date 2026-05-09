import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../app/di/injection.dart';
import '../../domain/entities/grn.dart';
import '../bloc/grn_cubit.dart';
import '../bloc/grn_state.dart';
import 'grn_form_page.dart';

class GrnPage extends StatelessWidget {
  const GrnPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GRNCubit>()..loadGRNs(),
      child: const _GrnView(),
    );
  }
}

class _GrnView extends StatelessWidget {
  const _GrnView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('استلام البضائع (GRN)')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final cubit = context.read<GRNCubit>();
          await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: cubit,
                child: const GrnFormPage(),
              ),
            ),
          );
        },
        child: const Icon(Icons.receipt_long_outlined),
      ),
      body: BlocConsumer<GRNCubit, GRNState>(
        listener: (context, state) {
          if (state.status == GRNStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'حدث خطأ'),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == GRNStatus.loading && state.grns.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.grns.isEmpty && state.status == GRNStatus.loaded) {
            return const Center(child: Text('لا توجد أذونات استلام بعد.'));
          }

          return RefreshIndicator(
            onRefresh: () => context.read<GRNCubit>().loadGRNs(refresh: true),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.grns.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final grn = state.grns[index];
                return _GrnCard(grn: grn);
              },
            ),
          );
        },
      ),
    );
  }
}

class _GrnCard extends StatelessWidget {
  final GRN grn;

  const _GrnCard({required this.grn});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GRNCubit>();
    final dateStr = grn.createdAt != null 
        ? DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(grn.createdAt!))
        : 'التاريخ غير متوفر';

    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.inventory_outlined, color: Colors.blue),
        title: Text('إذن استلام #${grn.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('أمر شراء #${grn.purchaseOrderId} - $dateStr'),
        trailing: PopupMenuButton<String>(
          onSelected: (val) {
            if (val == 'edit') {
              Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: cubit,
                    child: GrnFormPage(grn: grn),
                  ),
                ),
              );
            } else if (val == 'delete') {
              _showDeleteDialog(context, cubit, grn.id);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('تعديل')),
            PopupMenuItem(value: 'delete', child: Text('حذف')),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const Text('العناصر المستلمة:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...grn.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.item?.name ?? 'عنصر #${item.itemId}'),
                      Text('الكمية: ${item.receivedQuantity}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, GRNCubit cubit, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف إذن الاستلام #$id؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              cubit.deleteGRN(id);
              Navigator.pop(ctx);
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
