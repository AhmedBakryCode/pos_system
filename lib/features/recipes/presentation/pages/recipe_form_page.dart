import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../products/domain/entities/item.dart';
import '../../../products/presentation/bloc/items_cubit.dart';
import '../../../products/presentation/bloc/items_state.dart';
import '../../domain/entities/recipe.dart';
import '../bloc/recipe_cubit.dart';

class RecipeFormPage extends StatefulWidget {
  final Recipe? recipe;

  const RecipeFormPage({super.key, this.recipe});

  @override
  State<RecipeFormPage> createState() => _RecipeFormPageState();
}

class _RecipeFormPageState extends State<RecipeFormPage> {
  int? _selectedOutputItemId;
  final TextEditingController _outputQuantityController = TextEditingController(text: '1');
  final List<_IngredientRow> _rows = [];

  @override
  void initState() {
    super.initState();
    if (widget.recipe != null) {
      _selectedOutputItemId = widget.recipe!.outputItemId;
      _outputQuantityController.text = widget.recipe!.outputQuantity;
      for (final item in widget.recipe!.items) {
        _rows.add(_IngredientRow(
          itemId: item.itemId,
          quantity: double.tryParse(item.quantity) ?? 0,
        ));
      }
    } else {
      _rows.add(_IngredientRow());
    }
  }

  @override
  void dispose() {
    _outputQuantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe != null ? 'تعديل الوصفة' : 'وصفة جديدة'),
        actions: [
          TextButton(
            onPressed: () => _save(context),
            child: const Text('حفظ', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: BlocBuilder<ItemsCubit, ItemsState>(
        builder: (context, itemsState) {
          if (itemsState.status == ItemsStatus.loading && itemsState.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Output can be anything (usually finished/semi-finished, but no explicit constraint given)
          final allItems = itemsState.items;
          
          // Ingredients constraint: raw or semi-finished only
          final allowedIngredients = itemsState.items
              .where((i) => i.type == 'raw' || i.type == 'semi-finished')
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Output Item Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('المنتج الناتج عن الوصفة:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          initialValue: _selectedOutputItemId,
                          decoration: const InputDecoration(
                            labelText: 'المنتج النهائي',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.inventory_2_outlined),
                          ),
                          items: allItems.map((item) {
                            return DropdownMenuItem(value: item.id, child: Text(item.name));
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedOutputItemId = val),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _outputQuantityController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'الكمية الناتجة',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.scale_outlined),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Ingredients Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('المكونات (خام / نصف مصنع):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    FilledButton.tonal(
                      onPressed: () => setState(() => _rows.add(_IngredientRow())),
                      child: const Row(
                        children: [Icon(Icons.add, size: 18), SizedBox(width: 4), Text('إضافة مكون')],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Ingredient Rows
                ...List.generate(_rows.length, (index) {
                  return _IngredientRowWidget(
                    key: ValueKey(index),
                    row: _rows[index],
                    allowedItems: allowedIngredients,
                    onRemove: _rows.length > 1 ? () => setState(() => _rows.removeAt(index)) : null,
                    onChanged: () => setState(() {}),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  void _save(BuildContext context) {
    if (_selectedOutputItemId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء اختيار المنتج الناتج')));
      return;
    }

    final outputQty = double.tryParse(_outputQuantityController.text) ?? 0;
    if (outputQty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء إدخال كمية ناتجة صحيحة')));
      return;
    }

    final invalidRows = _rows.where((r) => r.itemId == null || r.quantity <= 0);
    if (invalidRows.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء تعبئة جميع بيانات المكونات')));
      return;
    }

    final inputs = _rows.map((r) => RecipeIngredientInput(
      itemId: r.itemId!,
      quantity: r.quantity,
    )).toList();

    final cubit = context.read<RecipeCubit>();
    if (widget.recipe != null) {
      cubit.updateRecipe(
        widget.recipe!.id,
        outputItemId: _selectedOutputItemId!,
        outputQuantity: outputQty,
        items: inputs,
      );
    } else {
      cubit.createRecipe(
        outputItemId: _selectedOutputItemId!,
        outputQuantity: outputQty,
        items: inputs,
      );
    }

    Navigator.of(context).pop(true);
  }
}

class _IngredientRow {
  int? itemId;
  double quantity;

  _IngredientRow({this.itemId, this.quantity = 1});
}

class _IngredientRowWidget extends StatelessWidget {
  final _IngredientRow row;
  final List<Item> allowedItems;
  final VoidCallback? onRemove;
  final VoidCallback onChanged;

  const _IngredientRowWidget({
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
                initialValue: row.itemId,
                decoration: const InputDecoration(
                  labelText: 'المكون',
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
