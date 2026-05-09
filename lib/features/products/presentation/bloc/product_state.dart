import 'package:equatable/equatable.dart';
import '../../domain/entities/product.dart';

enum ProductStatus { initial, loading, loaded, error }

class ProductState extends Equatable {
  final ProductStatus status;
  final List<Product> products;
  final List<Product> filteredProducts;
  final List<ProductCategory> categories;
  final List<Supplier> suppliers;
  final List<Product> lowStockProducts;
  final String? selectedCategoryId;
  final String searchQuery;
  final String? errorMessage;
  final int totalProducts;
  final int lowStockCount;

  const ProductState({
    this.status = ProductStatus.initial,
    this.products = const [],
    this.filteredProducts = const [],
    this.categories = const [],
    this.suppliers = const [],
    this.lowStockProducts = const [],
    this.selectedCategoryId,
    this.searchQuery = '',
    this.errorMessage,
    this.totalProducts = 0,
    this.lowStockCount = 0,
  });

  ProductState copyWith({
    ProductStatus? status,
    List<Product>? products,
    List<Product>? filteredProducts,
    List<ProductCategory>? categories,
    List<Supplier>? suppliers,
    List<Product>? lowStockProducts,
    String? selectedCategoryId,
    String? searchQuery,
    String? errorMessage,
    int? totalProducts,
    int? lowStockCount,
  }) {
    return ProductState(
      status: status ?? this.status,
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      categories: categories ?? this.categories,
      suppliers: suppliers ?? this.suppliers,
      lowStockProducts: lowStockProducts ?? this.lowStockProducts,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
      totalProducts: totalProducts ?? this.totalProducts,
      lowStockCount: lowStockCount ?? this.lowStockCount,
    );
  }

  @override
  List<Object?> get props => [
        status,
        products,
        filteredProducts,
        categories,
        suppliers,
        lowStockProducts,
        selectedCategoryId,
        searchQuery,
        errorMessage,
        totalProducts,
        lowStockCount,
      ];
}