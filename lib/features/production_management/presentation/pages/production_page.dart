import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../app/di/injection.dart';
import '../../../products/presentation/bloc/items_cubit.dart';
import '../../../products/presentation/bloc/items_state.dart';
import '../../../recipes/presentation/bloc/recipe_cubit.dart';
import '../../../recipes/presentation/bloc/recipe_state.dart';
import '../../domain/entities/production.dart';
import '../bloc/production_cubit.dart';
import '../bloc/production_state.dart';
import 'production_form_page.dart';

class ProductionPage extends StatelessWidget {
  const ProductionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<ProductionCubit>()..loadProductions()),
        BlocProvider(create: (_) => sl<RecipeCubit>()..loadRecipes()),
        BlocProvider(create: (_) => sl<ItemsCubit>()..loadItems()),
      ],
      child: const _ProductionView(),
    );
  }
}

class _ProductionView extends StatelessWidget {
  const _ProductionView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('أوامر الإنتاج')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final prodCubit = context.read<ProductionCubit>();
          final recipeCubit = context.read<RecipeCubit>();
          final itemsCubit = context.read<ItemsCubit>();
          await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: prodCubit),
                  BlocProvider.value(value: recipeCubit),
                  BlocProvider.value(value: itemsCubit),
                ],
                child: const ProductionFormPage(),
              ),
            ),
          );
        },
        child: const Icon(Icons.precision_manufacturing_outlined),
      ),
      body: BlocConsumer<ProductionCubit, ProductionState>(
        listener: (context, state) {
          if (state.status == ProductionStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'حدث خطأ'),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == ProductionStatus.loading && state.productions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.productions.isEmpty && state.status == ProductionStatus.loaded) {
            return const Center(child: Text('لا توجد أوامر إنتاج مضافة بعد.'));
          }

          return RefreshIndicator(
            onRefresh: () => context.read<ProductionCubit>().loadProductions(refresh: true),
            child: BlocBuilder<RecipeCubit, RecipeState>(
              builder: (context, recipeState) {
                return BlocBuilder<ItemsCubit, ItemsState>(
                  builder: (context, itemsState) {
                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.productions.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final production = state.productions[index];
                        return _ProductionCard(
                          production: production,
                          recipeState: recipeState,
                          itemsState: itemsState,
                        );
                      },
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
}

class _ProductionCard extends StatelessWidget {
  final Production production;
  final RecipeState recipeState;
  final ItemsState itemsState;

  const _ProductionCard({
    required this.production,
    required this.recipeState,
    required this.itemsState,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProductionCubit>();
    final recipe = recipeState.recipes.where((r) => r.id == production.recipeId).firstOrNull;
    final outputItem = recipe != null 
        ? itemsState.items.where((i) => i.id == recipe.outputItemId).firstOrNull 
        : null;

    final dateStr = production.createdAt != null 
        ? DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(production.createdAt!))
        : 'التاريخ غير متوفر';

    return Card(
      child: ListTile(
        leading: Icon(
          production.status == 'completed' ? Icons.check_circle : Icons.pending_actions,
          color: production.status == 'completed' ? Colors.green : Colors.orange,
        ),
        title: Text(
          outputItem?.name ?? 'أمر إنتاج #${production.id}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الكمية المطلوبة: ${production.quantity}'),
            Text('التاريخ: $dateStr'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (production.status != 'completed')
              IconButton(
                icon: const Icon(Icons.play_circle_outline, color: Colors.blue),
                tooltip: 'تنفيذ الإنتاج',
                onPressed: () => _showExecuteDialog(context, cubit, production.id),
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _showDeleteDialog(context, cubit, production.id),
            ),
          ],
        ),
      ),
    );
  }

  void _showExecuteDialog(BuildContext context, ProductionCubit cubit, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد التنفيذ'),
        content: const Text('هل أنت متأكد من تنفيذ أمر الإنتاج هذا؟ سيتم خصم المكونات من المخزون وإضافة المنتج النهائي.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () {
              cubit.executeProduction(id);
              Navigator.pop(ctx);
            },
            child: const Text('تنفيذ'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ProductionCubit cubit, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف أمر الإنتاج #$id؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              cubit.deleteProduction(id);
              Navigator.pop(ctx);
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
