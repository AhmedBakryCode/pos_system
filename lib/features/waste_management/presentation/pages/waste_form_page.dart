import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system/features/waste_management/presentation/bloc/waste_state.dart';

import '../../../products/domain/entities/item.dart';
import '../../../products/presentation/bloc/items_cubit.dart';
import '../../../products/presentation/bloc/items_state.dart';
import '../../domain/entities/waste.dart';
import '../bloc/waste_cubit.dart';

class WasteFormPage extends StatefulWidget {
  final Waste? waste;

  const WasteFormPage({super.key, this.waste});

  @override
  State<WasteFormPage> createState() => _WasteFormPageState();
}

class _WasteFormPageState extends State<WasteFormPage> {
  final TextEditingController _reasonController = TextEditingController();
  final List<_WasteItemRow> _rows = [];

  @override
  void initState() {
    super.initState();
    if (widget.waste != null) {
      _reasonController.text = widget.waste!.reason;
      for (final item in widget.waste!.items) {
        _rows.add(
          _WasteItemRow(
            itemId: item.itemId,
            quantity: double.tryParse(item.quantity) ?? 0,
          ),
        );
      }
    } else {
      _rows.add(_WasteItemRow());
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.waste != null ? 'تعديل الهالك' : 'تسجيل هالك جديد'),
        actions: [
          TextButton(
            onPressed: () => _save(context),
            child: const Text(
              'حفظ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: BlocConsumer<WasteCubit, WasteState>(
        listener: (context, state) {
          if (state.status == WasteStatus.loaded &&
              _reasonController.text.isNotEmpty) {
            // If we were saving and now it's loaded, it means success
            Navigator.of(context).pop(true);
          } else if (state.status == WasteStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'حدث خطأ'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              BlocBuilder<ItemsCubit, ItemsState>(
                builder: (context, itemsState) {
                  if (itemsState.status == ItemsStatus.loading &&
                      itemsState.items.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final allItems = itemsState.items;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'سبب الهالك:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _reasonController,
                          decoration: const InputDecoration(
                            hintText: 'مثال: تلف في الثلاجة، سقوط طبق...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'الأصناف التالفة:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            FilledButton.tonal(
                              onPressed: () =>
                                  setState(() => _rows.add(_WasteItemRow())),
                              child: const Row(
                                children: [
                                  Icon(Icons.add, size: 18),
                                  SizedBox(width: 4),
                                  Text('إضافة صنف'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...List.generate(_rows.length, (index) {
                          return _WasteItemRowWidget(
                            key: ValueKey(index),
                            row: _rows[index],
                            allowedItems: allItems,
                            onRemove: _rows.length > 1
                                ? () => setState(() => _rows.removeAt(index))
                                : null,
                            onChanged: () => setState(() {}),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
              if (state.status == WasteStatus.loading)
                Container(
                  color: Colors.black26,
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }

  void _save(BuildContext context) {
    if (_reasonController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('الرجاء إدخال سبب الهالك')));
      return;
    }

    final invalidRows = _rows.where((r) => r.itemId == null || r.quantity <= 0);
    if (invalidRows.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء التأكد من جميع الأصناف والكميات')),
      );
      return;
    }

    final inputs = _rows
        .map((r) => WasteItemInput(itemId: r.itemId!, quantity: r.quantity))
        .toList();

    final cubit = context.read<WasteCubit>();
    if (widget.waste != null) {
      cubit.updateWaste(
        widget.waste!.id,
        reason: _reasonController.text,
        items: inputs,
      );
    } else {
      cubit.createWaste(reason: _reasonController.text, items: inputs);
    }
  }
}

class _WasteItemRow {
  int? itemId;
  double quantity;

  _WasteItemRow({this.itemId, this.quantity = 1});
}

class _WasteItemRowWidget extends StatelessWidget {
  final _WasteItemRow row;
  final List<Item> allowedItems;
  final VoidCallback? onRemove;
  final VoidCallback onChanged;

  const _WasteItemRowWidget({
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              flex: 3,
              child: DropdownButtonFormField<int>(
                isExpanded: true,
                initialValue: row.itemId,
                decoration: const InputDecoration(
                  labelText: 'الصنف',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: allowedItems.map((item) {
                  return DropdownMenuItem(
                    value: item.id,
                    child: Text(item.name),
                  );
                }).toList(),
                onChanged: (val) {
                  row.itemId = val;
                  onChanged();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
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
            if (onRemove != null)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: onRemove,
              ),
          ],
        ),
      ),
    );
  }
}
