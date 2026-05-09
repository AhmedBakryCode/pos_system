import 'package:equatable/equatable.dart';
import '../../domain/entities/grn.dart';

enum GRNStatus { initial, loading, loaded, error }

class GRNState extends Equatable {
  final GRNStatus status;
  final List<GRN> grns;
  final String? errorMessage;
  final int currentPage;

  const GRNState({
    this.status = GRNStatus.initial,
    this.grns = const [],
    this.errorMessage,
    this.currentPage = 1,
  });

  GRNState copyWith({
    GRNStatus? status,
    List<GRN>? grns,
    String? errorMessage,
    int? currentPage,
  }) {
    return GRNState(
      status: status ?? this.status,
      grns: grns ?? this.grns,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [status, grns, errorMessage, currentPage];
}
