import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../domain/entities/transaction_header.dart';
import '../../domain/entities/transaction_line.dart';
import '../../domain/entities/transaction_status.dart';
import '../../domain/entities/transaction_type.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';
import '../../../shared/domain/entities/product.dart';

class TransactionScreen extends StatelessWidget {
  const TransactionScreen({super.key, this.initialType});

  final TransactionType? initialType;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TransactionBloc>()..add(InitializeTransaction(transactionType: initialType)),
      child: const _TransactionView(),
    );
  }
}

class _TransactionView extends StatelessWidget {
  const _TransactionView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppShell(
        child: BlocConsumer<TransactionBloc, TransactionState>(
          listener: (context, state) {
            if (state.status == TransactionViewStatus.saved) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حفظ المعاملة بنجاح')),
              );
            } else if (state.status == TransactionViewStatus.error &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
            }
          },
          builder: (context, state) {
            final transaction = state.transaction;
            if (state.status == TransactionViewStatus.loading &&
                transaction == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (transaction == null) {
              return const Center(child: Text('المعاملة غير متاحة'));
            }

            return Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                        sliver: SliverToBoxAdapter(
                          child: _TransactionHeaderCard(
                            transaction: transaction,
                            hideTypeSelector: (context.findAncestorWidgetOfExactType<TransactionScreen>()?.initialType != null),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                        sliver: SliverToBoxAdapter(
                          child: _SectionHeader(
                            title: 'سطور المعاملة',
                            subtitle: 'إدارة المنتجات والكميات والقيم داخل المعاملة.',
                            action: FilledButton.icon(
                              onPressed: () => _showAddProductSheet(context),
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('إضافة منتج'),
                            ),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 150),
                        sliver: SliverToBoxAdapter(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            child: transaction.lines.isEmpty
                                ? const _EmptyLinesCard()
                                : _TransactionLineList(lines: transaction.lines),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _StickyActionBar(transaction: transaction),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showAddProductSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => BlocProvider.value(
        value: context.read<TransactionBloc>(),
        child: const _AddProductSheet(),
      ),
    );
  }
}

class _TransactionHeaderCard extends StatelessWidget {
  const _TransactionHeaderCard({
    required this.transaction,
    this.hideTypeSelector = false,
  });

  final TransactionHeader transaction;
  final bool hideTypeSelector;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColors = theme.extension<AppStatusColors>()!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('بيانات المعاملة', style: theme.textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text(
                        '${transaction.referenceNumber} • ${transaction.transactionId}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                _StatusBadge(
                  label: _statusText(transaction.status),
                  color: switch (transaction.status) {
                    TransactionStatus.draft => statusColors.draft,
                    TransactionStatus.approved => statusColors.approved,
                    TransactionStatus.posted => statusColors.success,
                    TransactionStatus.cancelled => statusColors.error,
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 760;

                return GridView.count(
                  crossAxisCount: compact ? 1 : 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: compact ? 4.2 : 3.3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    if (!hideTypeSelector)
                      DropdownButtonFormField<TransactionType>(
                        initialValue: transaction.transactionType,
                        decoration: const InputDecoration(labelText: 'نوع المعاملة'),
                        items: TransactionType.values
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(_transactionTypeText(type)),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (value) {
                          if (value == null) return;
                          context.read<TransactionBloc>().add(
                            UpdateHeaderFields(transactionType: value),
                          );
                        },
                      ),
                    DropdownButtonFormField<String>(
                      initialValue: transaction.warehouseId,
                      decoration: const InputDecoration(labelText: 'المخزن'),
                      items: const [
                        DropdownMenuItem(value: 'wh-main', child: Text('المخزن الرئيسي')),
                        DropdownMenuItem(value: 'wh-cold', child: Text('مخزن التبريد')),
                        DropdownMenuItem(value: 'wh-branch', child: Text('مخزن الفرع')),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        context.read<TransactionBloc>().add(
                          UpdateHeaderFields(warehouseId: value),
                        );
                      },
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: transaction.branchId,
                      decoration: const InputDecoration(labelText: 'الفرع'),
                      items: const [
                        DropdownMenuItem(value: 'br-001', child: Text('فرع القاهرة الرئيسي')),
                        DropdownMenuItem(value: 'br-002', child: Text('فرع الإسكندرية')),
                        DropdownMenuItem(value: 'br-003', child: Text('فرع الجيزة')),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        context.read<TransactionBloc>().add(
                          UpdateHeaderFields(branchId: value),
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: transaction.notes,
                      decoration: const InputDecoration(labelText: 'ملاحظات'),
                      onChanged: (value) {
                        context.read<TransactionBloc>().add(
                          UpdateHeaderFields(notes: value),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionLineList extends StatelessWidget {
  const _TransactionLineList({required this.lines});

  final List<TransactionLine> lines;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(lines.length, (index) {
        final line = lines[index];
        return Padding(
          padding: EdgeInsets.only(bottom: index == lines.length - 1 ? 0 : 12),
          child: _TransactionLineCard(line: line),
        );
      }),
    );
  }
}

class _TransactionLineCard extends StatelessWidget {
  const _TransactionLineCard({required this.line});

  final TransactionLine line;

  @override
  Widget build(BuildContext context) {
    final quantityText = line.quantity.toStringAsFixed(
      line.quantity.truncateToDouble() == line.quantity ? 0 : 2,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(line.productName,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 6),
                      Text(
                        '${line.productId} • ${line.unitOfMeasure}'
                        '${line.batchNumber == null ? '' : ' • باتش ${line.batchNumber}'}',
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () {
                    context.read<TransactionBloc>().add(RemoveLine(line.productId));
                  },
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.9,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                TextFormField(
                  initialValue: quantityText,
                  decoration: const InputDecoration(labelText: 'الكمية'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onFieldSubmitted: (value) {
                    final quantity = double.tryParse(value);
                    if (quantity == null) return;
                    context.read<TransactionBloc>().add(
                      UpdateLineQuantity(productId: line.productId, quantity: quantity),
                    );
                  },
                ),
                TextFormField(
                  initialValue: line.unitPrice?.toStringAsFixed(2) ?? '-',
                  enabled: false,
                  decoration: const InputDecoration(labelText: 'سعر الوحدة'),
                ),
                TextFormField(
                  initialValue: (line.totalPrice ?? 0).toStringAsFixed(2),
                  enabled: false,
                  decoration: const InputDecoration(labelText: 'الإجمالي'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddProductSheet extends StatelessWidget {
  const _AddProductSheet();

  static const List<Product> _products = [
    Product(
      id: 'SKU-1001',
      name: 'فيليه دجاج',
      unitOfMeasure: 'كجم',
      unitPrice: 12.5,
      availableQuantity: 24,
      type: ProductType.rawMaterial,
    ),
    Product(
      id: 'SKU-1002',
      name: 'جبنة موزاريلا',
      unitOfMeasure: 'صندوق',
      unitPrice: 36.0,
      availableQuantity: 10,
      type: ProductType.rawMaterial,
    ),
    Product(
      id: 'SKU-2001',
      name: 'بيتزا مارجريتا',
      unitOfMeasure: 'قطعة',
      unitPrice: 85.0,
      availableQuantity: 15,
      type: ProductType.finishedProduct,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TransactionBloc>().state;
    final isProduction = state.transaction?.transactionType == TransactionType.production;

    final filteredProducts = isProduction
        ? _products.where((p) => p.type == ProductType.rawMaterial).toList()
        : _products;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('إضافة منتج', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(
                        isProduction
                            ? 'عرض المواد الخام المتاحة للتصنيع فقط.'
                            : 'اختر منتجًا لإضافته إلى سطور المعاملة.',
                      ),
                    ],
                  ),
                ),
                if (isProduction)
                  const Badge(
                    label: Text('وضع الإنتاج'),
                    backgroundColor: Colors.amber,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ...filteredProducts.map(
              (product) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: ListTile(
                    title: Text(product.name),
                    subtitle: Text(
                      '${product.id} • ${product.type.label} • ${product.unitPrice.toStringAsFixed(2)} ج.م\n'
                      'الكمية المتاحة: ${product.availableQuantity} ${product.unitOfMeasure}',
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.add_circle_outline_rounded),
                    onTap: product.availableQuantity <= 0
                        ? null
                        : () {
                            context.read<TransactionBloc>().add(
                                  AddLine(
                                    TransactionLine(
                                      productId: product.id,
                                      productName: product.name,
                                      quantity: 1,
                                      unitPrice: product.unitPrice,
                                      totalPrice: product.unitPrice,
                                      unitOfMeasure: product.unitOfMeasure,
                                      metadata: {
                                        'source': 'product_picker',
                                        'available_at_add': product.availableQuantity,
                                      },
                                    ),
                                  ),
                                );
                            Navigator.of(context).pop();
                          },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StickyActionBar extends StatelessWidget {
  const _StickyActionBar({required this.transaction});

  final TransactionHeader transaction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${transaction.lines.length} سطر • كمية ${transaction.totalQuantity.toStringAsFixed(2)} • قيمة ${transaction.totalAmount.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                onPressed: transaction.lines.isEmpty
                    ? null
                    : () {
                        context.read<TransactionBloc>().add(const SaveTransaction());
                        // Automatically try to post/finalize in this simplified flow
                        context.read<TransactionBloc>().add(const PostTransactionRequested());
                      },
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('تأكيد المعاملة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.action,
  });

  final String title;
  final String subtitle;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(subtitle),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: action),
      ],
    );
  }
}

class _EmptyLinesCard extends StatelessWidget {
  const _EmptyLinesCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.inventory_2_outlined, size: 40),
            const SizedBox(height: 12),
            Text('لا توجد منتجات مضافة بعد'),
            const SizedBox(height: 8),
            Text(
              'استخدم زر إضافة منتج لإنشاء سطور المعاملة.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String _statusText(TransactionStatus status) {
  switch (status) {
    case TransactionStatus.draft:
      return 'مسودة';
    case TransactionStatus.approved:
      return 'معتمد';
    case TransactionStatus.posted:
      return 'مرحّل';
    case TransactionStatus.cancelled:
      return 'ملغي';
  }
}

String _transactionTypeText(TransactionType type) {
  switch (type) {
    case TransactionType.grn:
      return 'استلام GRN';
    case TransactionType.po:
      return 'أمر شراء';
    case TransactionType.sale:
      return 'بيع';
    case TransactionType.waste:
      return 'هالك';
    case TransactionType.production:
      return 'إنتاج';
    case TransactionType.stockCount:
      return 'جرد';
    case TransactionType.stockAdjustment:
      return 'تسوية مخزون';
  }
}
