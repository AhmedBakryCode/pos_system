import 'package:equatable/equatable.dart';
import '../../domain/entities/production.dart';

enum ProductionStatus { initial, loading, loaded, error }

class ProductionState extends Equatable {
  final ProductionStatus status;
  final List<Production> productions;
  final String? errorMessage;
  final int currentPage;

  const ProductionState({
    this.status = ProductionStatus.initial,
    this.productions = const [],
    this.errorMessage,
    this.currentPage = 1,
  });

  ProductionState copyWith({
    ProductionStatus? status,
    List<Production>? productions,
    String? errorMessage,
    int? currentPage,
  }) {
    return ProductionState(
      status: status ?? this.status,
      productions: productions ?? this.productions,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [status, productions, errorMessage, currentPage];
}
