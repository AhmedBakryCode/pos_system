import 'package:equatable/equatable.dart';
import '../../domain/entities/item.dart';

enum ItemsStatus { initial, loading, loaded, error }

class ItemsState extends Equatable {
  final ItemsStatus status;
  final List<Item> items;
  final String? errorMessage;
  final int currentPage;

  const ItemsState({
    this.status = ItemsStatus.initial,
    this.items = const [],
    this.errorMessage,
    this.currentPage = 1,
  });

  ItemsState copyWith({
    ItemsStatus? status,
    List<Item>? items,
    String? errorMessage,
    int? currentPage,
  }) {
    return ItemsState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage, currentPage];
}
