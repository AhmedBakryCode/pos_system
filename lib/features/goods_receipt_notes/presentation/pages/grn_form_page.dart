import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection.dart';
import '../../../products/presentation/bloc/items_cubit.dart';
import '../../../products/presentation/bloc/items_state.dart';
import '../../../purchase_orders/presentation/bloc/purchases_cubit.dart';
import '../../../purchase_orders/presentation/bloc/purchases_state.dart';
import '../../domain/entities/grn.dart';
import '../bloc/grn_cubit.dart';

class GrnFormPage extends StatefulWidget {
  final GRN? grn;

  const GrnFormPage({super.key, this.grn});

  @override
  State<GrnFormPage> createState() => _GrnFormPageState();
}

class _GrnFormPageState extends State<GrnFormPage> {
  int? _selectedPOId;
  final List<_GRNItemRow> _rows = [];

  @override
  void initState() {
    super.initState();
    if (widget.grn != null) {
      _selectedPOId = widget.grn!.purchaseOrderId;
      for (final item in widget.grn!.items) {
        _rows.add(_GRNItemRow(
          itemId: item.itemId,
          receivedQuantity: double.tryParse(item.receivedQuantity) ?? 0,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<PurchasesCubit>()..loadAll()),
        BlocProvider(create: (_) => sl<ItemsCubit>()..loadItems()),
      ],
      child: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.grn != null ? 'تعديل إذن الاستلام' : 'إذن استلام جديد'),
            actions: [
              TextButton(
                onPressed: () => _save(context),
                child: const Text('حفظ', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          body: BlocBuilder<PurchasesCubit, PurchasesState>(
            builder: (context, poState) {
              return BlocBuilder<ItemsCubit, ItemsState>(
                builder: (context, itemsState) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // PO Selection
                        const Text('اختر أمر الشراء:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          isExpanded: true,
                          initialValue: _selectedPOId,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'اختر أمر الشراء',
                            prefixIcon: Icon(Icons.receipt_outlined),
                          ),
                          items: poState.orders.map((po) {
                            return DropdownMenuItem(
                              value: po.id,
                              child: Text('أمر شراء #${po.id}'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedPOId = val;
                              // Automatically populate rows from PO if it's a new GRN
                              if (widget.grn == null && val != null) {
                                final po = poState.orders.firstWhere((o) => o.id == val);
                                _rows.clear();
                                for (final item in po.items) {
                                  final foundItem = itemsState.items.where((i) => i.id == item.itemId).firstOrNull;
                                  _rows.add(_GRNItemRow(
                                    itemId: item.itemId,
                                    receivedQuantity: double.tryParse(item.quantity) ?? 0,
                                    itemName: foundItem?.name ?? 'عنصر #${item.itemId}',
                                  ));
                                }
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                        if (_selectedPOId != null) ...[
                          const Text('العناصر المستلمة:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ...List.generate(_rows.length, (index) {
                            final row = _rows[index];
                            
                            // If itemName is null, try to find it (for edit mode)
                            if (row.itemName == null) {
                              final foundItem = itemsState.items.where((i) => i.id == row.itemId).firstOrNull;
                              if (foundItem != null) {
                                row.itemName = foundItem.name;
                              }
                            }

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(row.itemName ?? 'عنصر #${row.itemId}'),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: TextFormField(
                                    initialValue: row.receivedQuantity.toString(),
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'الكمية المستلمة',
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                    onChanged: (val) {
                                      row.receivedQuantity = double.tryParse(val) ?? 0;
                                    },
                                  ),
                                ),
                              ),
                            );
                          }),
                        ] else
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Text('الرجاء اختيار أمر الشراء أولاً لعرض العناصر', style: TextStyle(color: Colors.grey)),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      }),
    );
  }

  void _save(BuildContext context) {
    if (_selectedPOId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء اختيار أمر الشراء')));
      return;
    }

    if (_rows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا توجد عناصر لاستلامها')));
      return;
    }

    final inputs = _rows.map((r) => GRNItemInput(
      itemId: r.itemId,
      receivedQuantity: r.receivedQuantity,
    )).toList();

    final cubit = context.read<GRNCubit>();
    if (widget.grn != null) {
      cubit.updateGRN(widget.grn!.id, purchaseOrderId: _selectedPOId!, items: inputs);
    } else {
      cubit.createGRN(purchaseOrderId: _selectedPOId!, items: inputs);
    }

    Navigator.of(context).pop(true);
  }
}

class _GRNItemRow {
  final int itemId;
  double receivedQuantity;
  String? itemName;

  _GRNItemRow({required this.itemId, this.receivedQuantity = 0, this.itemName});
}
