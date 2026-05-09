import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/product_repository.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _repository;

  ProductBloc(this._repository) : super(const ProductState()) {
    on<LoadProducts>(_onLoadProducts);
    on<SearchProducts>(_onSearchProducts);
    on<FilterByCategory>(_onFilterByCategory);
    on<AddProduct>(_onAddProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProduct>(_onDeleteProduct);
    on<LoadCategories>(_onLoadCategories);
    on<LoadSuppliers>(_onLoadSuppliers);
    on<LoadLowStockProducts>(_onLoadLowStockProducts);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(status: ProductStatus.loading));
    try {
      final products = await _repository.getProducts();
      final lowStock = await _repository.getLowStockProducts();
      final total = await _repository.getProductCount();
      final lowStockCount = await _repository.getLowStockCount();
      emit(state.copyWith(
        status: ProductStatus.loaded,
        products: products,
        filteredProducts: products,
        lowStockProducts: lowStock,
        totalProducts: total,
        lowStockCount: lowStockCount,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSearchProducts(
    SearchProducts event,
    Emitter<ProductState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(state.copyWith(
        filteredProducts: state.products,
        searchQuery: '',
      ));
      return;
    }

    try {
      final filtered = await _repository.searchProducts(event.query);
      emit(state.copyWith(
        filteredProducts: filtered,
        searchQuery: event.query,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onFilterByCategory(
    FilterByCategory event,
    Emitter<ProductState> emit,
  ) async {
    if (event.categoryId == null) {
      emit(state.copyWith(
        filteredProducts: state.products,
        selectedCategoryId: null,
      ));
      return;
    }

    try {
      final filtered = await _repository.getProductsByCategory(event.categoryId!);
      emit(state.copyWith(
        filteredProducts: filtered,
        selectedCategoryId: event.categoryId,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAddProduct(
    AddProduct event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await _repository.addProduct(event.product);
      add(LoadProducts());
    } catch (e) {
      emit(state.copyWith(
        status: ProductStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateProduct(
    UpdateProduct event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await _repository.updateProduct(event.product);
      add(LoadProducts());
    } catch (e) {
      emit(state.copyWith(
        status: ProductStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteProduct(
    DeleteProduct event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await _repository.deleteProduct(event.id);
      add(LoadProducts());
    } catch (e) {
      emit(state.copyWith(
        status: ProductStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<ProductState> emit,
  ) async {
    try {
      final categories = await _repository.getCategories();
      emit(state.copyWith(categories: categories));
    } catch (e) {
      emit(state.copyWith(
        status: ProductStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadSuppliers(
    LoadSuppliers event,
    Emitter<ProductState> emit,
  ) async {
    try {
      final suppliers = await _repository.getSuppliers();
      emit(state.copyWith(suppliers: suppliers));
    } catch (e) {
      emit(state.copyWith(
        status: ProductStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadLowStockProducts(
    LoadLowStockProducts event,
    Emitter<ProductState> emit,
  ) async {
    try {
      final lowStock = await _repository.getLowStockProducts();
      final lowStockCount = await _repository.getLowStockCount();
      emit(state.copyWith(
        lowStockProducts: lowStock,
        lowStockCount: lowStockCount,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}