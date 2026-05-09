import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/di/injection.dart';
import '../../domain/entities/item.dart';
import '../bloc/categories_cubit.dart';
import '../bloc/categories_state.dart';
import '../bloc/items_cubit.dart';
import '../bloc/items_state.dart';
import '../bloc/units_cubit.dart';
import '../bloc/units_state.dart';

class ItemsListPage extends StatelessWidget {
  final String title;
  final String itemType;

  const ItemsListPage({super.key, required this.title, required this.itemType});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<ItemsCubit>()..loadItems()),
        BlocProvider(create: (_) => sl<CategoriesCubit>()..loadCategories()),
        BlocProvider(create: (_) => sl<UnitsCubit>()..loadUnits()),
      ],
      child: _ItemsListView(title: title, itemType: itemType),
    );
  }
}

class _ItemsListView extends StatelessWidget {
  final String title;
  final String itemType;

  const _ItemsListView({required this.title, required this.itemType});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context, itemType),
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<ItemsCubit, ItemsState>(
        listener: (context, state) {
          if (state.status == ItemsStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'حدث خطأ'),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == ItemsStatus.loading && state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredItems = state.items.where((i) => i.type == itemType).toList();

          if (filteredItems.isEmpty && state.status == ItemsStatus.loaded) {
            return const Center(child: Text('لا توجد عناصر مضافة بعد.'));
          }

          return RefreshIndicator(
            onRefresh: () => context.read<ItemsCubit>().loadItems(refresh: true),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filteredItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return Card(
                  child: ListTile(
                    leading: item.image != null
                        ? CircleAvatar(backgroundImage: NetworkImage(item.image!))
                        : const CircleAvatar(child: Icon(Icons.inventory_2_outlined)),
                    title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('فئة: ${item.categoryId} | وحدة: ${item.unitId}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                          onPressed: () => _showAddEditDialog(context, itemType, item: item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _showDeleteDialog(context, item.id, item.name),
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

  void _showAddEditDialog(BuildContext context, String type, {Item? item}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<ItemsCubit>()),
            BlocProvider.value(value: context.read<CategoriesCubit>()),
            BlocProvider.value(value: context.read<UnitsCubit>()),
          ],
          child: _AddEditItemDialog(itemType: type, item: item),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, int id, String name) {
    final cubit = context.read<ItemsCubit>();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: Text('هل أنت متأكد من حذف "$name"؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                cubit.deleteItem(id);
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

class _AddEditItemDialog extends StatefulWidget {
  final String itemType;
  final Item? item;

  const _AddEditItemDialog({required this.itemType, this.item});

  @override
  State<_AddEditItemDialog> createState() => _AddEditItemDialogState();
}

class _AddEditItemDialogState extends State<_AddEditItemDialog> {
  late TextEditingController _nameController;
  int? _selectedCategoryId;
  int? _selectedUnitId;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _selectedCategoryId = widget.item?.categoryId;
    _selectedUnitId = widget.item?.unitId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.item != null;

    return AlertDialog(
      title: Text(isEdit ? 'تعديل العنصر' : 'إضافة عنصر جديد'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 40,
                backgroundImage: _selectedImage != null
                    ? FileImage(_selectedImage!)
                    : (widget.item?.image != null ? NetworkImage(widget.item!.image!) : null) as ImageProvider?,
                child: _selectedImage == null && widget.item?.image == null
                    ? const Icon(Icons.add_a_photo, size: 30)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'اسم العنصر'),
            ),
            const SizedBox(height: 12),
            BlocBuilder<CategoriesCubit, CategoriesState>(
              builder: (context, state) {
                if (state.status == CategoriesStatus.loading && state.categories.isEmpty) {
                  return const CircularProgressIndicator();
                }
                return DropdownButtonFormField<int>(
                  initialValue: _selectedCategoryId,
                  decoration: const InputDecoration(labelText: 'الفئة'),
                  items: state.categories.map((c) {
                    return DropdownMenuItem(
                      value: c.id,
                      child: Text(c.name),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCategoryId = val),
                );
              },
            ),
            const SizedBox(height: 12),
            BlocBuilder<UnitsCubit, UnitsState>(
              builder: (context, state) {
                if (state.status == UnitsStatus.loading && state.units.isEmpty) {
                  return const CircularProgressIndicator();
                }
                return DropdownButtonFormField<int>(
                  initialValue: _selectedUnitId,
                  decoration: const InputDecoration(labelText: 'الوحدة'),
                  items: state.units.map((u) {
                    return DropdownMenuItem(
                      value: u.id,
                      child: Text(u.name),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedUnitId = val),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty || _selectedCategoryId == null || _selectedUnitId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('الرجاء تعبئة الحقول المطلوبة (الاسم، الفئة، الوحدة)')),
              );
              return;
            }

            final cubit = context.read<ItemsCubit>();
            if (isEdit) {
              cubit.updateItem(
                widget.item!.id,
                name: name,
                categoryId: _selectedCategoryId!,
                unitId: _selectedUnitId!,
                type: widget.itemType,
                image: _selectedImage,
              );
            } else {
              cubit.createItem(
                name: name,
                categoryId: _selectedCategoryId!,
                unitId: _selectedUnitId!,
                type: widget.itemType,
                image: _selectedImage,
              );
            }
            Navigator.pop(context);
          },
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}
