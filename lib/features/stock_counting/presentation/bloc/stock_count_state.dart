import 'package:equatable/equatable.dart';
import '../../domain/entities/stock_count.dart';

enum StockCountStatus { initial, loading, loaded, error }

class StockCountState extends Equatable {
  final StockCountStatus status;
  final List<StockCount> stockCounts;
  final String? errorMessage;
  final int currentPage;

  const StockCountState({
    this.status = StockCountStatus.initial,
    this.stockCounts = const [],
    this.errorMessage,
    this.currentPage = 1,
  });

  StockCountState copyWith({
    StockCountStatus? status,
    List<StockCount>? stockCounts,
    String? errorMessage,
    int? currentPage,
  }) {
    return StockCountState(
      status: status ?? this.status,
      stockCounts: stockCounts ?? this.stockCounts,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [status, stockCounts, errorMessage, currentPage];
}
