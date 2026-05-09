import '../../../shared/domain/entities/audit_log_entry.dart';
import '../../../shared/domain/entities/stock_costing_method.dart';
import '../../../shared/domain/entities/stock_movement.dart';
import '../../../shared/domain/entities/stock_movement_type.dart';
import '../../../shared/domain/services/inventory_event_factory.dart';
import '../../../shared/domain/services/inventory_policy_service.dart';
import '../../domain/entities/transaction_header.dart';
import '../../domain/entities/transaction_line.dart';
import '../../domain/entities/transaction_status.dart';
import '../../domain/entities/transaction_type.dart';
import '../../domain/repositories/transaction_repository.dart';

class MockTransactionRepository implements TransactionRepository {
  MockTransactionRepository({
    required InventoryPolicyService inventoryPolicyService,
    required InventoryEventFactory inventoryEventFactory,
  }) : _inventoryPolicyService = inventoryPolicyService,
       _inventoryEventFactory = inventoryEventFactory {
    for (final transaction in _buildSeedTransactions()) {
      _storage[transaction.transactionId] = transaction;
    }
  }

  final InventoryPolicyService _inventoryPolicyService;
  final InventoryEventFactory _inventoryEventFactory;
  final Map<String, TransactionHeader> _storage = {};
  final List<StockMovement> _postedMovements = [];
  final List<AuditLogEntry> _auditEntries = [];

  @override
  Future<List<TransactionHeader>> listTransactions() async {
    final transactions = _storage.values.toList(growable: false)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return transactions;
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    _storage.remove(transactionId);
    _appendAudit(
      entityId: transactionId,
      action: 'delete_transaction',
      before: const {'deleted': false},
      after: const {'deleted': true},
    );
  }

  @override
  Future<TransactionHeader> approveTransaction(String transactionId) async {
    final existing = await loadTransaction(transactionId);
    if (existing.lines.isEmpty) {
      throw StateError('Transaction cannot be approved without lines.');
    }

    final approved = existing.copyWith(status: TransactionStatus.approved);
    _storage[transactionId] = approved;
    _appendAudit(
      entityId: transactionId,
      action: 'approve_transaction',
      before: {'status': existing.status.name},
      after: {'status': approved.status.name},
    );
    return approved;
  }

  @override
  Future<TransactionHeader> createTransaction(TransactionHeader transaction) async {
    _guardLines(transaction);
    _storage[transaction.transactionId] = transaction;
    _appendAudit(
      entityId: transaction.transactionId,
      action: 'create_transaction',
      before: const {},
      after: {'status': transaction.status.name, 'lineCount': transaction.lines.length},
    );
    return transaction;
  }

  @override
  Future<TransactionHeader> loadTransaction(String transactionId) async {
    final transaction = _storage[transactionId];
    if (transaction == null) {
      throw StateError('Transaction $transactionId was not found.');
    }
    return transaction;
  }

  @override
  Future<TransactionHeader> postTransaction(String transactionId) async {
    final existing = await loadTransaction(transactionId);

    if (existing.status != TransactionStatus.approved) {
      throw StateError('Only approved transactions can be posted.');
    }

    if (existing.lines.isEmpty) {
      throw StateError('Posted transaction must contain at least one line.');
    }

    if (_requiresAvailabilityCheck(existing.transactionType)) {
      final totalQuantity = existing.totalQuantity;
      final canPost = _inventoryPolicyService.canPostOutboundMovement(
        availableQuantity: 500,
        requestedQuantity: totalQuantity,
        allowNegativeOverride: false,
      );

      if (!canPost) {
        _inventoryEventFactory.posSyncFailed(
          posOrderId: existing.transactionId,
          reason: 'Insufficient available stock during posting.',
        );
        throw StateError('Insufficient available stock to post transaction.');
      }
    }

    for (final line in existing.lines) {
      _postedMovements.add(
        StockMovement(
          id: 'sm-${existing.transactionId}-${line.productId}',
          eventId: 'evt-${existing.transactionId}',
          transactionId: existing.transactionId,
          productId: line.productId,
          warehouseId: existing.warehouseId,
          type: _movementTypeFor(existing.transactionType),
          quantity: line.quantity,
          unitCost: line.unitPrice ?? 0,
          beforeQuantity: 500,
          afterQuantity: 500 - line.quantity,
          costingMethod: StockCostingMethod.fifo,
          createdBy: existing.createdBy,
          sourceModule: 'transactions',
        ),
      );
    }

    final posted = existing.copyWith(status: TransactionStatus.posted);
    _storage[transactionId] = posted;
    _appendAudit(
      entityId: transactionId,
      action: 'post_transaction',
      before: {'status': existing.status.name},
      after: {'status': posted.status.name, 'movements': posted.lines.length},
    );
    return posted;
  }

  @override
  Future<TransactionHeader> updateTransaction(TransactionHeader transaction) async {
    _guardLines(transaction);
    final existing = _storage[transaction.transactionId];
    if (existing?.status == TransactionStatus.posted) {
      throw StateError('Posted transactions are immutable and must be reversed.');
    }

    _storage[transaction.transactionId] = transaction;
    _appendAudit(
      entityId: transaction.transactionId,
      action: 'update_transaction',
      before: {
        'previousLineCount': existing?.lines.length,
        'previousStatus': existing?.status.name,
      },
      after: {
        'lineCount': transaction.lines.length,
        'status': transaction.status.name,
      },
    );
    return transaction;
  }

  void _guardLines(TransactionHeader transaction) {
    if (transaction.lines.any((line) => line.quantity <= 0)) {
      throw StateError('Transaction line quantity must be greater than zero.');
    }
  }

  bool _requiresAvailabilityCheck(TransactionType type) {
    return type == TransactionType.sale ||
        type == TransactionType.waste ||
        type == TransactionType.production ||
        type == TransactionType.stockAdjustment;
  }

  StockMovementType _movementTypeFor(TransactionType type) {
    switch (type) {
      case TransactionType.grn:
        return StockMovementType.grnIn;
      case TransactionType.po:
        return StockMovementType.adjustmentIn;
      case TransactionType.sale:
        return StockMovementType.posSaleOut;
      case TransactionType.waste:
        return StockMovementType.wasteOut;
      case TransactionType.production:
        return StockMovementType.productionConsume;
      case TransactionType.stockCount:
        return StockMovementType.adjustmentOut;
      case TransactionType.stockAdjustment:
        return StockMovementType.adjustmentOut;
    }
  }

  void _appendAudit({
    required String entityId,
    required String action,
    required Map<String, Object?> before,
    required Map<String, Object?> after,
  }) {
    _auditEntries.add(
      AuditLogEntry(
        id: 'audit-${_auditEntries.length + 1}',
        entityType: 'transaction',
        entityId: entityId,
        action: action,
        actorId: 'system_user',
        timestampIso: DateTime.now().toIso8601String(),
        beforeSnapshot: before,
        afterSnapshot: after,
        metadata: const {'module': 'transactions'},
      ),
    );
  }

  List<TransactionHeader> _buildSeedTransactions() {
    final now = DateTime.now();
    return [
      TransactionHeader(
        transactionId: 'txn-grn-001',
        transactionType: TransactionType.grn,
        status: TransactionStatus.approved,
        warehouseId: 'wh-main',
        branchId: 'br-001',
        createdAt: now.subtract(const Duration(hours: 1)),
        createdBy: 'warehouse.supervisor',
        notes: 'Inbound chilled inventory from supplier.',
        referenceNumber: 'GRN-2026-001',
        lines: const [
          TransactionLine(
            productId: 'SKU-1001',
            productName: 'Chicken Breast Fillet',
            quantity: 24,
            unitPrice: 12.5,
            totalPrice: 300,
            unitOfMeasure: 'kg',
            batchNumber: 'B-CH-241',
            metadata: {'zone': 'cold'},
          ),
          TransactionLine(
            productId: 'SKU-1002',
            productName: 'Mozzarella Cheese',
            quantity: 10,
            unitPrice: 36,
            totalPrice: 360,
            unitOfMeasure: 'box',
            batchNumber: 'B-MZ-118',
            metadata: {'zone': 'cold'},
          ),
        ],
      ),
      TransactionHeader(
        transactionId: 'txn-sale-002',
        transactionType: TransactionType.sale,
        status: TransactionStatus.posted,
        warehouseId: 'wh-branch',
        branchId: 'br-002',
        createdAt: now.subtract(const Duration(hours: 3)),
        createdBy: 'pos.cashier',
        notes: 'Lunch rush POS sale sync.',
        referenceNumber: 'SALE-2026-1881',
        lines: const [
          TransactionLine(
            productId: 'SKU-2001',
            productName: 'Margherita Pizza',
            quantity: 12,
            unitPrice: 8.5,
            totalPrice: 102,
            unitOfMeasure: 'unit',
            metadata: {'channel': 'pos'},
          ),
          TransactionLine(
            productId: 'SKU-2002',
            productName: 'Chicken Wrap',
            quantity: 8,
            unitPrice: 6.25,
            totalPrice: 50,
            unitOfMeasure: 'unit',
            metadata: {'channel': 'pos'},
          ),
        ],
      ),
      TransactionHeader(
        transactionId: 'txn-prod-003',
        transactionType: TransactionType.production,
        status: TransactionStatus.draft,
        warehouseId: 'wh-main',
        branchId: 'br-001',
        createdAt: now.subtract(const Duration(hours: 5)),
        createdBy: 'kitchen.manager',
        notes: 'Prep batch for evening service.',
        referenceNumber: 'PROD-2026-044',
        lines: const [
          TransactionLine(
            productId: 'SKU-3001',
            productName: 'Pizza Dough Batch',
            quantity: 30,
            unitPrice: 1.9,
            totalPrice: 57,
            unitOfMeasure: 'tray',
            metadata: {'recipe': 'classic_dough'},
          ),
        ],
      ),
      TransactionHeader(
        transactionId: 'txn-waste-004',
        transactionType: TransactionType.waste,
        status: TransactionStatus.approved,
        warehouseId: 'wh-cold',
        branchId: 'br-003',
        createdAt: now.subtract(const Duration(hours: 8)),
        createdBy: 'inventory.controller',
        notes: 'Expired dairy items removed from stock.',
        referenceNumber: 'WASTE-2026-011',
        lines: const [
          TransactionLine(
            productId: 'SKU-4010',
            productName: 'Greek Yogurt',
            quantity: 6,
            unitPrice: 4.75,
            totalPrice: 28.5,
            unitOfMeasure: 'case',
            batchNumber: 'B-GY-021',
            metadata: {'reason': 'expired'},
          ),
        ],
      ),
    ];
  }
}
