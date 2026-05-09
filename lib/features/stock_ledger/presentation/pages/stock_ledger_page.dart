import 'package:flutter/material.dart';
import '../../domain/entities/stock_ledger.dart';

class StockLedgerPage extends StatefulWidget {
  const StockLedgerPage({super.key});

  @override
  State<StockLedgerPage> createState() => _StockLedgerPageState();
}

class _StockLedgerPageState extends State<StockLedgerPage> {
  final _searchController = TextEditingController();
  StockMovementType? _selectedType;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('دفتر المخزون'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'بحث باسم المنتج أو المرجع',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          _buildMovementsList(),
        ],
      ),
    );
  }

  Widget _buildMovementsList() {
    final entries = _mockEntries;

    return Expanded(
      child: entries.isEmpty
          ? const Center(
              child: Text('لا توجد حركات'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return _LedgerEntryCard(entry: entry);
              },
            ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تصفية',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<StockMovementType?>(
              initialValue: _selectedType,
              decoration: const InputDecoration(
                labelText: 'نوع الحركة',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('الكل')),
                ...StockMovementType.values.map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type.label),
                    )),
              ],
              onChanged: (value) {
                setState(() => _selectedType = value);
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => _startDate = date);
                      }
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_startDate != null
                        ? '${_startDate!.day}/${_startDate!.month}'
                        : 'من تاريخ'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _endDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => _endDate = date);
                      }
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_endDate != null
                        ? '${_endDate!.day}/${_endDate!.month}'
                        : 'إلى تاريخ'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedType = null;
                        _startDate = null;
                        _endDate = null;
                      });
                      Navigator.of(context).pop();
                    },
                    child: const Text('إعادة تعيين'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('تطبيق'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static final _mockEntries = [
    StockLedgerEntry(
      id: '1',
      productId: 'prod_1',
      productName: 'اسبريسو',
      movementType: StockMovementType.purchase,
      quantity: 50,
      balanceAfter: 100,
      date: DateTime.now().subtract(const Duration(days: 1)),
      reference: 'PO-001',
      notes: 'شراء من التاجري',
    ),
    StockLedgerEntry(
      id: '2',
      productId: 'prod_1',
      productName: 'اسبريسو',
      movementType: StockMovementType.sale,
      quantity: -10,
      balanceAfter: 90,
      date: DateTime.now().subtract(const Duration(hours: 12)),
      reference: 'POS-1234',
    ),
    StockLedgerEntry(
      id: '3',
      productId: 'prod_2',
      productName: 'لاتيه',
      movementType: StockMovementType.adjustmentIncrease,
      quantity: 5,
      balanceAfter: 85,
      date: DateTime.now().subtract(const Duration(hours: 6)),
      reference: 'ADJ-001',
      notes: 'تسوية جرد',
    ),
    StockLedgerEntry(
      id: '4',
      productId: 'prod_1',
      productName: 'اسبريسو',
      movementType: StockMovementType.waste,
      quantity: -2,
      balanceAfter: 88,
      date: DateTime.now().subtract(const Duration(hours: 3)),
      reference: 'W-001',
      notes: 'Expired quantity',
    ),
  ];
}

class _LedgerEntryCard extends StatelessWidget {
  final StockLedgerEntry entry;

  const _LedgerEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isPositive = entry.quantity > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isPositive
                    ? Colors.green.shade100
                    : Colors.red.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isPositive
                    ? Icons.arrow_downward
                    : Icons.arrow_upward,
                color: isPositive
                    ? Colors.green.shade700
                    : Colors.red.shade700,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.productName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          entry.movementType.label,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      if (entry.reference != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          entry.reference!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isPositive ? '+' : ''}${entry.quantity.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isPositive
                            ? Colors.green
                            : Colors.red,
                      ),
                ),
                Text(
                  'الرصيد: ${entry.balanceAfter.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}