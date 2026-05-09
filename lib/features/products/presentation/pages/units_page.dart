import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection.dart';
import '../bloc/units_cubit.dart';
import '../bloc/units_state.dart';

class UnitsPage extends StatelessWidget {
  const UnitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<UnitsCubit>()..loadUnits(),
      child: const UnitsView(),
    );
  }
}

class UnitsView extends StatelessWidget {
  const UnitsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الوحدات'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context),
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<UnitsCubit, UnitsState>(
        listener: (context, state) {
          if (state.status == UnitsStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'حدث خطأ'),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == UnitsStatus.loading && state.units.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.units.isEmpty) {
            return const Center(child: Text('لا توجد وحدات مضافة بعد.'));
          }

          return RefreshIndicator(
            onRefresh: () => context.read<UnitsCubit>().loadUnits(refresh: true),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.units.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final unit = state.units[index];
                return Card(
                  child: ListTile(
                    title: Text(unit.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(unit.description ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                          onPressed: () => _showAddEditDialog(context, unit: unit),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _showDeleteDialog(context, unit.id, unit.name),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, {dynamic unit}) {
    final nameController = TextEditingController(text: unit?.name ?? '');
    final descController = TextEditingController(text: unit?.description ?? '');
    final cubit = context.read<UnitsCubit>();
    final isEdit = unit != null;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(isEdit ? 'تعديل الوحدة' : 'إضافة وحدة جديدة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'اسم الوحدة'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'الوصف'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                final desc = descController.text.trim();
                if (name.isEmpty) return;

                if (isEdit) {
                  cubit.updateUnit(unit.id, name, desc);
                } else {
                  cubit.createUnit(name, desc);
                }
                Navigator.pop(ctx);
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, int id, String name) {
    final cubit = context.read<UnitsCubit>();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: Text('هل أنت متأكد من حذف الوحدة "$name"؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                cubit.deleteUnit(id);
                Navigator.pop(ctx);
              },
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );
  }
}
