import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductLocalDatasource _datasource;

  ProductRepositoryImpl(this._datasource);

  @override
  Future<List<Product>> getProducts() => _datasource.getProducts();

  @override
  Future<Product?> getProductById(String id) => _datasource.getProductById(id);

  @override
  Future<void> addProduct(Product product) => _datasource.insertProduct(product);

  @override
  Future<void> updateProduct(Product product) => _datasource.updateProduct(product);

  @override
  Future<void> deleteProduct(String id) => _datasource.deleteProduct(id);

  @override
  Future<List<Product>> searchProducts(String query) =>
      _datasource.searchProducts(query);

  @override
  Future<List<Product>> getLowStockProducts() => _datasource.getLowStockProducts();

  @override
  Future<List<Product>> getProductsByCategory(String categoryId) =>
      _datasource.getProductsByCategory(categoryId);

  @override
  Future<List<ProductCategory>> getCategories() => _datasource.getCategories();

  @override
  Future<void> addCategory(ProductCategory category) =>
      _datasource.insertCategory(category);

  @override
  Future<void> updateCategory(ProductCategory category) =>
      _datasource.updateCategory(category);

  @override
  Future<void> deleteCategory(String id) => _datasource.deleteCategory(id);

  @override
  Future<ProductCategory?> getCategoryById(String id) =>
      _datasource.getCategoryById(id);

  @override
  Future<List<Supplier>> getSuppliers() => _datasource.getSuppliers();

  @override
  Future<void> addSupplier(Supplier supplier) =>
      _datasource.insertSupplier(supplier);

  @override
  Future<void> updateSupplier(Supplier supplier) =>
      _datasource.updateSupplier(supplier);

  @override
  Future<void> deleteSupplier(String id) => _datasource.deleteSupplier(id);

  @override
  Future<Supplier?> getSupplierById(String id) => _datasource.getSupplierById(id);

  @override
  Future<int> getProductCount() => _datasource.getProductCount();

  @override
  Future<int> getLowStockCount() => _datasource.getLowStockCount();
}