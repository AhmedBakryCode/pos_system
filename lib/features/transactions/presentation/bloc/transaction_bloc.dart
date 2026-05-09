import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/transaction_header.dart';
import '../../domain/entities/transaction_status.dart';
import '../../domain/entities/transaction_type.dart';
import '../../domain/usecases/approve_transaction.dart';
import '../../domain/usecases/create_transaction.dart';
import '../../domain/usecases/post_transaction.dart';
import '../../domain/usecases/update_transaction.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionBloc({
    required CreateTransaction createTransaction,
    required UpdateTransaction updateTransaction,
    required ApproveTransaction approveTransaction,
    required PostTransaction postTransaction,
  }) : _createTransaction = createTransaction,
       _updateTransaction = updateTransaction,
       _approveTransaction = approveTransaction,
       _postTransaction = postTransaction,
       super(const TransactionState.loading()) {
    on<InitializeTransaction>(_onInitializeTransaction);
    on<LoadTransaction>(_onLoadTransaction);
    on<AddLine>(_onAddLine);
    on<RemoveLine>(_onRemoveLine);
    on<UpdateLineQuantity>(_onUpdateLineQuantity);
    on<UpdateHeaderFields>(_onUpdateHeaderFields);
    on<SaveTransaction>(_onSaveTransaction);
    on<ApproveTransactionRequested>(_onApproveTransactionRequested);
    on<PostTransactionRequested>(_onPostTransactionRequested);
    on<ReplaceTransaction>(_onReplaceTransaction);
  }

  final CreateTransaction _createTransaction;
  final UpdateTransaction _updateTransaction;
  final ApproveTransaction _approveTransaction;
  final PostTransaction _postTransaction;

  Future<void> _onInitializeTransaction(
    InitializeTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    final now = DateTime.now();
    emit(
      TransactionState.loaded(
        TransactionHeader(
          transactionId: 'txn-${now.microsecondsSinceEpoch}',
          transactionType: event.transactionType ?? TransactionType.grn,
          status: TransactionStatus.draft,
          warehouseId: 'wh-main',
          branchId: 'br-001',
          createdAt: now,
          createdBy: 'current.user',
          referenceNumber: 'TRX-${now.millisecondsSinceEpoch}',
          notes: null,
          lines: const [],
        ),
      ),
    );
  }

  Future<void> _onLoadTransaction(
    LoadTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionState.loading());
    try {
      // Using update use cases only for persistence paths; this screen initializes locally.
      if (event.transactionId == 'txn-seed-001') {
        add(
          ReplaceTransaction(
            TransactionHeader(
              transactionId: 'txn-seed-001',
              transactionType: TransactionType.grn,
              status: TransactionStatus.draft,
              warehouseId: 'wh-main',
              branchId: 'br-001',
              createdAt: DateTime.now(),
              createdBy: 'warehouse.supervisor',
              referenceNumber: 'GRN-2026-001',
              notes: 'Receiving chilled inventory from supplier.',
              lines: const [],
            ),
          ),
        );
      } else {
        add(const InitializeTransaction());
      }
    } catch (error) {
      emit(TransactionState.error(error.toString()));
    }
  }

  void _onAddLine(AddLine event, Emitter<TransactionState> emit) {
    final transaction = _requireTransaction();
    final available = (event.line.metadata['available_at_add'] as num?)?.toDouble() ?? double.infinity;

    if (event.line.quantity > available) {
      emit(TransactionState.error('الكمية المطلوبة تتجاوز المتاح ($available)', transaction: transaction));
      return;
    }

    final updatedLines = [
      ...transaction.lines.where((line) => line.productId != event.line.productId),
      event.line.copyWith(
        totalPrice: event.line.totalPrice ??
            ((event.line.unitPrice ?? 0) * event.line.quantity),
      ),
    ];
    emit(TransactionState.editing(transaction.copyWith(lines: updatedLines)));
  }

  void _onRemoveLine(RemoveLine event, Emitter<TransactionState> emit) {
    final transaction = _requireTransaction();
    emit(
      TransactionState.editing(
        transaction.copyWith(
          lines: transaction.lines
              .where((line) => line.productId != event.productId)
              .toList(growable: false),
        ),
      ),
    );
  }

  void _onUpdateLineQuantity(
    UpdateLineQuantity event,
    Emitter<TransactionState> emit,
  ) {
    final transaction = _requireTransaction();
    
    final line = transaction.lines.firstWhere((l) => l.productId == event.productId);
    final available = (line.metadata['available_at_add'] as num?)?.toDouble() ?? double.infinity;

    if (event.quantity > available) {
      emit(TransactionState.error('الكمية المطلوبة تتجاوز المتاح ($available)', transaction: transaction));
      return;
    }

    final updatedLines = transaction.lines.map((l) {
      if (l.productId != event.productId) {
        return l;
      }

      return l.copyWith(
        quantity: event.quantity,
        totalPrice: (l.unitPrice ?? 0) * event.quantity,
      );
    }).toList(growable: false);

    emit(TransactionState.editing(transaction.copyWith(lines: updatedLines)));
  }

  void _onUpdateHeaderFields(
    UpdateHeaderFields event,
    Emitter<TransactionState> emit,
  ) {
    final transaction = _requireTransaction();
    emit(
      TransactionState.editing(
        transaction.copyWith(
          transactionType: event.transactionType,
          warehouseId: event.warehouseId,
          branchId: event.branchId,
          notes: event.notes,
        ),
      ),
    );
  }

  Future<void> _onSaveTransaction(
    SaveTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    final transaction = _requireTransaction();
    emit(const TransactionState.loading());
    try {
      final saved = transaction.status == TransactionStatus.draft
          ? await _createTransaction(transaction)
          : await _updateTransaction(transaction);
      emit(TransactionState.saved(saved));
      emit(TransactionState.loaded(saved));
    } catch (error) {
      emit(TransactionState.error(error.toString(), transaction: transaction));
    }
  }

  Future<void> _onApproveTransactionRequested(
    ApproveTransactionRequested event,
    Emitter<TransactionState> emit,
  ) async {
    final transaction = _requireTransaction();
    emit(const TransactionState.loading());
    try {
      final approved = await _approveTransaction(transaction.transactionId);
      emit(TransactionState.saved(approved));
      emit(TransactionState.loaded(approved));
    } catch (error) {
      emit(TransactionState.error(error.toString(), transaction: transaction));
    }
  }

  Future<void> _onPostTransactionRequested(
    PostTransactionRequested event,
    Emitter<TransactionState> emit,
  ) async {
    final transaction = _requireTransaction();
    emit(const TransactionState.loading());
    try {
      final posted = await _postTransaction(transaction.transactionId);
      emit(TransactionState.saved(posted));
      emit(TransactionState.loaded(posted));
    } catch (error) {
      emit(TransactionState.error(error.toString(), transaction: transaction));
    }
  }

  void _onReplaceTransaction(
    ReplaceTransaction event,
    Emitter<TransactionState> emit,
  ) {
    emit(TransactionState.loaded(event.transaction));
  }

  TransactionHeader _requireTransaction() {
    final transaction = state.transaction;
    if (transaction == null) {
      throw StateError('Transaction state is not initialized.');
    }
    return transaction;
  }
}
