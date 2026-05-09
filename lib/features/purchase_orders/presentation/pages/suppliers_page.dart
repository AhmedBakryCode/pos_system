import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection.dart';
import '../../domain/entities/supplier.dart';
import '../bloc/suppliers_cubit.dart';
import '../bloc/suppliers_state.dart';

class SuppliersPage extends StatelessWidget {
  const SuppliersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SuppliersCubit>()..loadSuppliers(),
      child: const _SuppliersView(),
    );
  }
}

class _SuppliersView extends StatelessWidget {
  const _SuppliersView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('الموردين')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context),
        child: const Icon(Icons.person_add_alt_1_outlined),
      ),
      body: BlocConsumer<SuppliersCubit, SuppliersState>(
        listener: (context, state) {
          if (state.status == SuppliersStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'حدث خطأ'),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == SuppliersStatus.loading && state.suppliers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.suppliers.isEmpty && state.status == SuppliersStatus.loaded) {
            return const Center(child: Text('لا يوجد موردين مضافين بعد.'));
          }

          return RefreshIndicator(
            onRefresh: () => context.read<SuppliersCubit>().loadSuppliers(refresh: true),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.suppliers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final supplier = state.suppliers[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(
                        supplier.fname.isNotEmpty ? supplier.fname[0].toUpperCase() : 'S',
                        style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(supplier.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (supplier.phone != null && supplier.phone!.isNotEmpty)
                          Row(
                            children: [
                              const Icon(Icons.phone_outlined, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(supplier.phone!, style: const TextStyle(fontSize: 13)),
                            ],
                          ),
                        if (supplier.address != null && supplier.address!.isNotEmpty)
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  supplier.address!,
                                  style: const TextStyle(fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                          onPressed: () => _showAddEditDialog(context, supplier: supplier),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _showDeleteDialog(context, supplier.id, supplier.name),
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

  void _showAddEditDialog(BuildContext context, {Supplier? supplier}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return BlocProvider.value(
          value: context.read<SuppliersCubit>(),
          child: _SupplierAddEditDialog(supplier: supplier),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, int id, String name) {
    final cubit = context.read<SuppliersCubit>();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: Text('هل أنت متأكد من حذف المورد "$name"؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                cubit.deleteSupplier(id);
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

class _SupplierAddEditDialog extends StatefulWidget {
  final Supplier? supplier;

  const _SupplierAddEditDialog({this.supplier});

  @override
  State<_SupplierAddEditDialog> createState() => _SupplierAddEditDialogState();
}

class _SupplierAddEditDialogState extends State<_SupplierAddEditDialog> {
  late TextEditingController _fnameController;
  late TextEditingController _lnameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _fnameController = TextEditingController(text: widget.supplier?.fname ?? '');
    _lnameController = TextEditingController(text: widget.supplier?.lname ?? '');
    _emailController = TextEditingController(text: widget.supplier?.email ?? '');
    _phoneController = TextEditingController(text: widget.supplier?.phone ?? '');
    _addressController = TextEditingController(text: widget.supplier?.address ?? '');
  }

  @override
  void dispose() {
    _fnameController.dispose();
    _lnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.supplier != null;

    return AlertDialog(
      title: Text(isEdit ? 'تعديل بيانات المورد' : 'إضافة مورد جديد'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _fnameController,
              decoration: const InputDecoration(labelText: 'الاسم الأول', prefixIcon: Icon(Icons.person_outline)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _lnameController,
              decoration: const InputDecoration(labelText: 'الاسم الأخير', prefixIcon: Icon(Icons.person_outline)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'البريد الإلكتروني', prefixIcon: Icon(Icons.email_outlined)),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'رقم الهاتف', prefixIcon: Icon(Icons.phone_outlined)),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'العنوان', prefixIcon: Icon(Icons.location_on_outlined)),
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
            final fname = _fnameController.text.trim();
            final lname = _lnameController.text.trim();
            final email = _emailController.text.trim();
            final phone = _phoneController.text.trim();
            final address = _addressController.text.trim();

            if (fname.isEmpty || lname.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('الرجاء إدخال الاسم الأول والأخير على الأقل')),
              );
              return;
            }

            final cubit = context.read<SuppliersCubit>();
            if (isEdit) {
              cubit.updateSupplier(
                widget.supplier!.id,
                fname: fname,
                lname: lname,
                email: email,
                phone: phone,
                address: address,
              );
            } else {
              cubit.createSupplier(
                fname: fname,
                lname: lname,
                email: email,
                phone: phone,
                address: address,
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
