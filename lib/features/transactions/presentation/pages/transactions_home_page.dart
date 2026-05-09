import 'package:flutter/material.dart';

import '../../../../app/di/injection.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/entity_details_page.dart';
import '../../domain/entities/transaction_header.dart';
import '../../domain/repositories/transaction_repository.dart';
import 'transaction_screen.dart';

class TransactionsHomePage extends StatefulWidget {
  const TransactionsHomePage({super.key});

  @override
  State<TransactionsHomePage> createState() => _TransactionsHomePageState();
}

class _TransactionsHomePageState extends State<TransactionsHomePage> {
  late Future<List<TransactionHeader>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = sl<TransactionRepository>().listTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppShell(
        child: FutureBuilder<List<TransactionHeader>>(
          future: _future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final transactions = snapshot.data!;

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'المعاملات',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const TransactionScreen(),
                              ),
                            );
                            setState(_load);
                          },
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('جديد'),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverList.separated(
                    itemBuilder: (context, index) {
                      return _TransactionSummaryCard(
                        transaction: transactions[index],
                        onDetails: () => _openDetails(transactions[index]),
                        onDelete: () async {
                          await sl<TransactionRepository>()
                              .deleteTransaction(transactions[index].transactionId);
                          setState(_load);
                        },
                      );
                    },
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemCount: transactions.length,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _openDetails(TransactionHeader transaction) {
    final details = <String, String>{
      'رقم المرجع': transaction.referenceNumber,
      'نوع المعاملة': transaction.transactionType.name,
      'الحالة': transaction.status.name,
      'المخزن': transaction.warehouseId,
      'المنشئ': transaction.createdBy,
      'الإجمالي': transaction.totalAmount.toStringAsFixed(2),
      'عدد السطور': transaction.lines.length.toString(),
    };

    for (var index = 0; index < transaction.lines.length; index++) {
      final line = transaction.lines[index];
      details['سطر ${index + 1}'] =
          '${line.productName} - ${line.quantity} ${line.unitOfMeasure}';
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EntityDetailsPage(
          title: transaction.referenceNumber,
          details: details,
        ),
      ),
    );
  }
}

class _TransactionSummaryCard extends StatelessWidget {
  const _TransactionSummaryCard({
    required this.transaction,
    required this.onDetails,
    required this.onDelete,
  });

  final TransactionHeader transaction;
  final VoidCallback onDetails;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              transaction.referenceNumber,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              '${transaction.transactionType.name.toUpperCase()} • ${transaction.warehouseId} • ${transaction.status.name.toUpperCase()}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            ...transaction.lines.map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.35),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('${line.productName} (${line.productId})'),
                      ),
                      Text('${line.quantity} ${line.unitOfMeasure}'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${transaction.lines.length} سطر • كمية ${transaction.totalQuantity.toStringAsFixed(0)} • قيمة ${transaction.totalAmount.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: onDetails,
                  icon: const Icon(Icons.info_outline_rounded),
                  label: const Text('تفاصيل'),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
