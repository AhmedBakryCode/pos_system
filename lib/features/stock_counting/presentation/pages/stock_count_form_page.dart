import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../products/domain/entities/item.dart';
import '../../../products/presentation/bloc/items_cubit.dart';
import '../../../products/presentation/bloc/items_state.dart';
import '../../domain/entities/stock_count.dart';
import '../bloc/stock_count_cubit.dart';

class StockCountFormPage extends StatefulWidget {
  final StockCount? stockCount;

  const StockCountFormPage({super.key, this.stockCount});

  @override
  State<StockCountFormPage> createState() => _StockCountFormPageState();
}

class _StockCountFormPageState extends State<StockCountFormPage> {
  final List<_StockCountRow> _rows = [];

  @override
  void initState() {
    super.initState();
    if (widget.stockCount != null) {
      for (final item in widget.stockCount!.items) {
        _rows.add(
          _StockCountRow(
            itemId: item.itemId,
            actualQuantity: double.tryParse(item.actualQuantity) ?? 0,
          ),
        );
      }
    } else {
      _rows.add(_StockCountRow());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.stockCount != null ? 'تعديل الجرد' : 'جرد جديد'),
        actions: [
          TextButton(
            onPressed: () => _save(context),
            child: const Text(
              'حفظ كمسودة',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: BlocBuilder<ItemsCubit, ItemsState>(
        builder: (context, itemsState) {
          if (itemsState.status == ItemsStatus.loading &&
              itemsState.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final allItems = itemsState.items;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _rows.length,
                  itemBuilder: (context, index) {
                    return _StockCountRowWidget(
                      key: ValueKey(index),
                      row: _rows[index],
                      allowedItems: allItems,
                      onRemove: _rows.length > 1
                          ? () => setState(() => _rows.removeAt(index))
                          : null,
                      onChanged: () => setState(() {}),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        setState(() => _rows.add(_StockCountRow())),
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة صنف للجرد'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _save(BuildContext context) {
    final invalidRows = _rows.where((r) => r.itemId == null);
    if (invalidRows.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار جميع الأصناف')),
      );
      return;
    }

    final inputs = _rows
        .map(
          (r) => StockCountItemInput(
            itemId: r.itemId!,
            actualQuantity: r.actualQuantity,
          ),
        )
        .toList();

    final cubit = context.read<StockCountCubit>();
    if (widget.stockCount != null) {
      cubit.updateStockCount(widget.stockCount!.id, items: inputs);
    } else {
      cubit.createStockCount(items: inputs);
    }

    Navigator.of(context).pop(true);
  }
}

class _StockCountRow {
  int? itemId;
  double actualQuantity;

  _StockCountRow({this.itemId, this.actualQuantity = 0});
}

class _StockCountRowWidget extends StatelessWidget {
  final _StockCountRow row;
  final List<Item> allowedItems;
  final VoidCallback? onRemove;
  final VoidCallback onChanged;

  const _StockCountRowWidget({
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
                initialValue: row.actualQuantity > 0
                    ? row.actualQuantity.toString()
                    : '0',
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'الكمية الفعلية',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (val) {
                  row.actualQuantity = double.tryParse(val) ?? 0;
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
