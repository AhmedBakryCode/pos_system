import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system/features/production_management/presentation/bloc/production_state.dart';

import '../../../products/presentation/bloc/items_cubit.dart';
import '../../../products/presentation/bloc/items_state.dart';
import '../../../recipes/presentation/bloc/recipe_cubit.dart';
import '../../../recipes/presentation/bloc/recipe_state.dart';
import '../../domain/entities/production.dart';
import '../bloc/production_cubit.dart';

class ProductionFormPage extends StatefulWidget {
  final Production? production;

  const ProductionFormPage({super.key, this.production});

  @override
  State<ProductionFormPage> createState() => _ProductionFormPageState();
}

class _ProductionFormPageState extends State<ProductionFormPage> {
  int? _selectedRecipeId;
  final TextEditingController _quantityController = TextEditingController(
    text: '1',
  );

  @override
  void initState() {
    super.initState();
    if (widget.production != null) {
      _selectedRecipeId = widget.production!.recipeId;
      _quantityController.text = widget.production!.quantity;
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.production != null ? 'تعديل أمر الإنتاج' : 'أمر إنتاج جديد',
        ),
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
      body: BlocConsumer<ProductionCubit, ProductionState>(
        listener: (context, state) {
          if (state.status == ProductionStatus.loaded &&
              _selectedRecipeId != null) {
            Navigator.of(context).pop(true);
          } else if (state.status == ProductionStatus.error) {
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
              BlocBuilder<RecipeCubit, RecipeState>(
                builder: (context, recipeState) {
                  return BlocBuilder<ItemsCubit, ItemsState>(
                    builder: (context, itemsState) {
                      if ((recipeState.status == RecipeStatus.loading &&
                              recipeState.recipes.isEmpty) ||
                          (itemsState.status == ItemsStatus.loading &&
                              itemsState.items.isEmpty)) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'اختر الوصفة:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<int>(
                              isExpanded: true,
                              initialValue: _selectedRecipeId,
                              decoration: const InputDecoration(
                                labelText: 'الوصفة',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.menu_book_outlined),
                              ),
                              items: recipeState.recipes.map((recipe) {
                                final outputItem = itemsState.items
                                    .where((i) => i.id == recipe.outputItemId)
                                    .firstOrNull;
                                return DropdownMenuItem(
                                  value: recipe.id,
                                  child: Text(
                                    'وصفة #${recipe.id} (${outputItem?.name ?? "منتج #${recipe.outputItemId}"})',
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedRecipeId = val),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'الكمية المطلوب إنتاجها (عدد مرات الوصفة):',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _quantityController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'الكمية',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(
                                  Icons.production_quantity_limits,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            if (_selectedRecipeId != null) ...[
                              const Text(
                                'ملاحظة:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              const Text(
                                'بعد حفظ أمر الإنتاج، ستحتاج للنقر على "تنفيذ" لبدء عملية التصنيع وخصم المواد من المخزون.',
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              if (state.status == ProductionStatus.loading)
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
    if (_selectedRecipeId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('الرجاء اختيار الوصفة')));
      return;
    }

    final qty = double.tryParse(_quantityController.text) ?? 0;
    if (qty <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('الرجاء إدخال كمية صحيحة')));
      return;
    }

    final cubit = context.read<ProductionCubit>();
    if (widget.production != null) {
      cubit.updateProduction(
        widget.production!.id,
        recipeId: _selectedRecipeId!,
        quantity: qty,
      );
    } else {
      cubit.createProduction(recipeId: _selectedRecipeId!, quantity: qty);
    }
  }
}
