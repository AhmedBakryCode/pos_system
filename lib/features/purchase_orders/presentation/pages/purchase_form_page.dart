import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection.dart';
import '../../../products/domain/entities/item.dart';
import '../../../products/presentation/bloc/items_cubit.dart';
import '../../../products/presentation/bloc/items_state.dart';
import '../../domain/entities/purchase_order.dart';
import '../bloc/purchases_cubit.dart';
import '../bloc/purchases_state.dart';

class PurchaseFormPage extends StatefulWidget {
  final PurchaseOrder? order;

  const PurchaseFormPage({super.key, this.order});

  @override
  State<PurchaseFormPage> createState() => _PurchaseFormPageState();
}

class _PurchaseFormPageState extends State<PurchaseFormPage> {
  int? _selectedSupplierId;
  final List<_ItemRow> _rows = [];

  @override
  void initState() {
    super.initState();
    if (widget.order != null) {
      _selectedSupplierId = widget.order!.supplierId;
      for (final item in widget.order!.items) {
        _rows.add(_ItemRow(
          itemId: item.itemId,
          quantity: double.tryParse(item.quantity) ?? 0,
          price: double.tryParse(item.price) ?? 0,
        ));
      }
    } else {
      _rows.add(_ItemRow());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ItemsCubit>()..loadItems(),
      child: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.order != null ? 'تعديل أمر الشراء' : 'أمر شراء جديد'),
            actions: [
              TextButton(
                onPressed: () => _save(context),
                child: const Text('حفظ', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          body: BlocBuilder<PurchasesCubit, PurchasesState>(
            builder: (context, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Supplier picker
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: DropdownButtonFormField<int>(
                          initialValue: _selectedSupplierId,
                          decoration: const InputDecoration(
                            labelText: 'المورد',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(),
                          ),
                          items: state.suppliers.map((s) {
                            return DropdownMenuItem(value: s.id, child: Text(s.name));
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedSupplierId = val),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Items header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'عناصر الشراء',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        FilledButton.tonal(
                          onPressed: () => setState(() => _rows.add(_ItemRow())),
                          child: const Row(
                            children: [Icon(Icons.add, size: 18), SizedBox(width: 4), Text('إضافة عنصر')],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Item rows
                    BlocBuilder<ItemsCubit, ItemsState>(
                      builder: (context, itemsState) {
                        // Filter only raw & semi-finished items
                        final allowedItems = itemsState.items
                            .where((i) => i.type == 'raw' || i.type == 'semi-finished')
                            .toList();

                        return Column(
                          children: List.generate(_rows.length, (index) {
                            return _ItemRowWidget(
                              key: ValueKey(index),
                              row: _rows[index],
                              allowedItems: allowedItems,
                              onRemove: _rows.length > 1
                                  ? () => setState(() => _rows.removeAt(index))
                                  : null,
                              onChanged: () => setState(() {}),
                            );
                          }),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    // Total
                    Card(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('الإجمالي', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(
                              _rows.fold<double>(0, (sum, r) => sum + r.total).toStringAsFixed(2),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }

  void _save(BuildContext context) {
    if (_selectedSupplierId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار المورد')),
      );
      return;
    }

    final invalidRows = _rows.where((r) => r.itemId == null || r.quantity <= 0 || r.price <= 0);
    if (invalidRows.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء تعبئة جميع بيانات العناصر')),
      );
      return;
    }

    final inputs = _rows
        .map((r) => PurchaseOrderItemInput(
              itemId: r.itemId!,
              quantity: r.quantity,
              price: r.price,
            ))
        .toList();

    final cubit = context.read<PurchasesCubit>();
    if (widget.order != null) {
      cubit.updateOrder(
        widget.order!.id,
        supplierId: _selectedSupplierId!,
        items: inputs,
      );
    } else {
      cubit.createOrder(supplierId: _selectedSupplierId!, items: inputs);
    }

    Navigator.of(context).pop(true);
  }
}

class _ItemRow {
  int? itemId;
  double quantity;
  double price;

  _ItemRow({this.itemId, this.quantity = 1, this.price = 0});

  double get total => quantity * price;
}

class _ItemRowWidget extends StatelessWidget {
  final _ItemRow row;
  final List<Item> allowedItems;
  final VoidCallback? onRemove;
  final VoidCallback onChanged;

  const _ItemRowWidget({
    super.key,
    required this.row,
    required this.allowedItems,
    this.onRemove,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              isExpanded: true,
              initialValue: row.itemId,
              decoration: const InputDecoration(
                labelText: 'العنصر (خام / نصف مصنع)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: allowedItems.map((item) {
                return DropdownMenuItem(value: item.id, child: Text(item.name));
              }).toList(),
              onChanged: (val) {
                row.itemId = val;
                onChanged();
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: row.quantity > 0 ? row.quantity.toString() : '',
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
                    initialValue: row.price > 0 ? row.price.toString() : '',
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'السعر',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (val) {
                      row.price = double.tryParse(val) ?? 0;
                      onChanged();
                    },
                  ),
                ),
                if (onRemove != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: onRemove,
                  ),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'الإجمالي: ${row.total.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
