import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection.dart';
import '../../../products/presentation/bloc/items_cubit.dart';
import '../../../products/presentation/bloc/items_state.dart';

import '../bloc/recipe_cubit.dart';
import '../bloc/recipe_state.dart';
import 'recipe_form_page.dart';

class RecipesPage extends StatelessWidget {
  const RecipesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<RecipeCubit>()..loadRecipes()),
        BlocProvider(create: (_) => sl<ItemsCubit>()..loadItems()),
      ],
      child: const _RecipesView(),
    );
  }
}

class _RecipesView extends StatelessWidget {
  const _RecipesView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('الوصفات (Recipes)')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final recipeCubit = context.read<RecipeCubit>();
          final itemsCubit = context.read<ItemsCubit>();
          await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: recipeCubit),
                  BlocProvider.value(value: itemsCubit),
                ],
                child: const RecipeFormPage(),
              ),
            ),
          );
        },
        child: const Icon(Icons.menu_book_outlined),
      ),
      body: BlocConsumer<RecipeCubit, RecipeState>(
        listener: (context, state) {
          if (state.status == RecipeStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'حدث خطأ'),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == RecipeStatus.loading && state.recipes.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.recipes.isEmpty && state.status == RecipeStatus.loaded) {
            return const Center(child: Text('لا توجد وصفات مضافة بعد.'));
          }

          return RefreshIndicator(
            onRefresh: () => context.read<RecipeCubit>().loadRecipes(refresh: true),
            child: BlocBuilder<ItemsCubit, ItemsState>(
              builder: (context, itemsState) {
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.recipes.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final recipe = state.recipes[index];
                    final outputItem = itemsState.items.where((i) => i.id == recipe.outputItemId).firstOrNull;

                    return Card(
                      child: ExpansionTile(
                        leading: const Icon(Icons.restaurant_menu, color: Colors.orange),
                        title: Text(
                          outputItem?.name ?? 'وصفة #${recipe.id}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('الكمية المنتجة: ${recipe.outputQuantity}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                              onPressed: () {
                                final recipeCubit = context.read<RecipeCubit>();
                                final itemsCubit = context.read<ItemsCubit>();
                                Navigator.of(context).push<bool>(
                                  MaterialPageRoute(
                                    builder: (_) => MultiBlocProvider(
                                      providers: [
                                        BlocProvider.value(value: recipeCubit),
                                        BlocProvider.value(value: itemsCubit),
                                      ],
                                      child: RecipeFormPage(recipe: recipe),
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _showDeleteDialog(context, context.read<RecipeCubit>(), recipe.id),
                            ),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Divider(),
                                const Text('المكونات:', style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                ...recipe.items.map((ing) {
                                  final ingItem = itemsState.items.where((i) => i.id == ing.itemId).firstOrNull;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(ingItem?.name ?? 'مكون #${ing.itemId}'),
                                        Text('الكمية: ${ing.quantity}'),
                                      ],
                                    ),
                                  );
                                }),
                              ],
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
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, RecipeCubit cubit, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف الوصفة #$id؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              cubit.deleteRecipe(id);
              Navigator.pop(ctx);
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
