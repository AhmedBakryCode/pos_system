import 'package:equatable/equatable.dart';
import '../../domain/entities/unit.dart';

enum UnitsStatus { initial, loading, loaded, error }

class UnitsState extends Equatable {
  final UnitsStatus status;
  final List<Unit> units;
  final String? errorMessage;
  final int currentPage;

  const UnitsState({
    this.status = UnitsStatus.initial,
    this.units = const [],
    this.errorMessage,
    this.currentPage = 1,
  });

  UnitsState copyWith({
    UnitsStatus? status,
    List<Unit>? units,
    String? errorMessage,
    int? currentPage,
  }) {
    return UnitsState(
      status: status ?? this.status,
      units: units ?? this.units,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [status, units, errorMessage, currentPage];
}
