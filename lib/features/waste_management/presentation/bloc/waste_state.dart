import 'package:equatable/equatable.dart';
import '../../domain/entities/waste.dart';

enum WasteStatus { initial, loading, loaded, error }

class WasteState extends Equatable {
  final WasteStatus status;
  final List<Waste> wastes;
  final String? errorMessage;
  final int currentPage;

  const WasteState({
    this.status = WasteStatus.initial,
    this.wastes = const [],
    this.errorMessage,
    this.currentPage = 1,
  });

  WasteState copyWith({
    WasteStatus? status,
    List<Waste>? wastes,
    String? errorMessage,
    int? currentPage,
  }) {
    return WasteState(
      status: status ?? this.status,
      wastes: wastes ?? this.wastes,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [status, wastes, errorMessage, currentPage];
}
