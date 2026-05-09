import 'package:equatable/equatable.dart';
import '../../domain/entities/supplier.dart';

enum SuppliersStatus { initial, loading, loaded, error }

class SuppliersState extends Equatable {
  final SuppliersStatus status;
  final List<Supplier> suppliers;
  final String? errorMessage;
  final int currentPage;

  const SuppliersState({
    this.status = SuppliersStatus.initial,
    this.suppliers = const [],
    this.errorMessage,
    this.currentPage = 1,
  });

  SuppliersState copyWith({
    SuppliersStatus? status,
    List<Supplier>? suppliers,
    String? errorMessage,
    int? currentPage,
  }) {
    return SuppliersState(
      status: status ?? this.status,
      suppliers: suppliers ?? this.suppliers,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [status, suppliers, errorMessage, currentPage];
}
