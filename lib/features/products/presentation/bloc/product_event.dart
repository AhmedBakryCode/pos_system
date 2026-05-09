import 'package:equatable/equatable.dart';
import '../../domain/entities/product.dart';

abstract class ProductEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductEvent {}

class SearchProducts extends ProductEvent {
  final String query;
  SearchProducts(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterByCategory extends ProductEvent {
  final String? categoryId;
  FilterByCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class AddProduct extends ProductEvent {
  final Product product;
  AddProduct(this.product);

  @override
  List<Object?> get props => [product];
}

class UpdateProduct extends ProductEvent {
  final Product product;
  UpdateProduct(this.product);

  @override
  List<Object?> get props => [product];
}

class DeleteProduct extends ProductEvent {
  final String id;
  DeleteProduct(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadCategories extends ProductEvent {}

class LoadSuppliers extends ProductEvent {}

class LoadLowStockProducts extends ProductEvent {}