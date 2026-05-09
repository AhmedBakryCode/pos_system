import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../products/domain/entities/item.dart';
import '../../../products/presentation/bloc/items_cubit.dart';
import '../../../products/presentation/bloc/items_state.dart';
import '../../domain/entities/order.dart';
import '../bloc/order_cubit.dart';

class OrderFormPage extends StatefulWidget {
  const OrderFormPage({super.key});

  @override
  State<OrderFormPage> createState() => _OrderFormPageState();
}

class _OrderFormPageState extends State<OrderFormPage> {
  final List<_OrderItemRow> _rows = [];

  @override
  void initState() {
    super.initState();
    _rows.add(_OrderItemRow());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلب جديد'),
        actions: [
          TextButton(
            onPressed: () => _save(context),
            child: const Text('إتمام', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: BlocBuilder<ItemsCubit, ItemsState>(
        builder: (context, itemsState) {
          if (itemsState.status == ItemsStatus.loading && itemsState.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Sales constraint: semi-finished or finished only
          final allowedItems = itemsState.items
              .where((i) => i.type == 'semi-finished' || i.type == 'finished')
              .toList();

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _rows.length,
                  itemBuilder: (context, index) {
                    return _OrderItemRowWidget(
                      key: ValueKey(index),
                      row: _rows[index],
                      allowedItems: allowedItems,
                      onRemove: _rows.length > 1 ? () => setState(() => _rows.removeAt(index)) : null,
                      onChanged: () => setState(() {}),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 10, offset: const Offset(0, -5))],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('الإجمالي المتوقع:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(
                          _calculateTotal().toStringAsFixed(2),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.green),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => setState(() => _rows.add(_OrderItemRow())),
                        icon: const Icon(Icons.add),
                        label: const Text('إضافة صنف آخر'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  double _calculateTotal() {
    return _rows.fold(0, (sum, row) => sum + (row.quantity * row.sellingPrice));
  }

  void _save(BuildContext context) {
    final invalidRows = _rows.where((r) => r.itemId == null || r.quantity <= 0 || r.sellingPrice <= 0);
    if (invalidRows.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء التأكد من جميع البيانات (الكمية والسعر)')));
      return;
    }

    final inputs = _rows.map((r) => OrderItemInput(
      itemId: r.itemId!,
      quantity: r.quantity,
      sellingPrice: r.sellingPrice,
    )).toList();

    context.read<OrderCubit>().createOrder(items: inputs);
    Navigator.of(context).pop(true);
  }
}

class _OrderItemRow {
  _OrderItemRow();
  int? itemId;
  double quantity = 1;
  double sellingPrice = 0;
}

class _OrderItemRowWidget extends StatelessWidget {
  final _OrderItemRow row;
  final List<Item> allowedItems;
  final VoidCallback? onRemove;
  final VoidCallback onChanged;

  const _OrderItemRowWidget({
    super.key,
    required this.row,
    required this.allowedItems,
    this.onRemove,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              isExpanded: true,
              initialValue: row.itemId,
              decoration: const InputDecoration(
                labelText: 'الصنف',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.inventory_2_outlined),
              ),
              items: allowedItems.map((item) {
                return DropdownMenuItem(value: item.id, child: Text(item.name));
              }).toList(),
              onChanged: (val) {
                row.itemId = val;
                onChanged();
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: row.quantity.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'الكمية',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (val) {
                      row.quantity = double.tryParse(val) ?? 0;
                      onChanged();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: row.sellingPrice > 0 ? row.sellingPrice.toString() : '',
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'سعر البيع',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (val) {
                      row.sellingPrice = double.tryParse(val) ?? 0;
                      onChanged();
                    },
                  ),
                ),
                if (onRemove != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: onRemove,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
