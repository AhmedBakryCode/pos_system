import '../entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Future<Product?> getProductById(String id);
  Future<void> addProduct(Product product);
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(String id);
  Future<List<Product>> searchProducts(String query);
  Future<List<Product>> getLowStockProducts();
  Future<List<Product>> getProductsByCategory(String categoryId);
  Future<List<ProductCategory>> getCategories();
  Future<void> addCategory(ProductCategory category);
  Future<void> updateCategory(ProductCategory category);
  Future<void> deleteCategory(String id);
  Future<ProductCategory?> getCategoryById(String id);
  Future<List<Supplier>> getSuppliers();
  Future<void> addSupplier(Supplier supplier);
  Future<void> updateSupplier(Supplier supplier);
  Future<void> deleteSupplier(String id);
  Future<Supplier?> getSupplierById(String id);
  Future<int> getProductCount();
  Future<int> getLowStockCount();
}