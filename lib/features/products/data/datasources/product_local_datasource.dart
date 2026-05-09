import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../domain/entities/product.dart';

class ProductLocalDatasource {
  static Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'pos_system.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE products (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            unit_price REAL NOT NULL,
            available_quantity REAL NOT NULL,
            type TEXT NOT NULL,
            unit_of_measure TEXT NOT NULL,
            category_id TEXT,
            sku TEXT,
            barcode TEXT,
            image_url TEXT,
            description TEXT,
            supplier_id TEXT,
            reorder_point REAL,
            cost_price REAL,
            is_active INTEGER DEFAULT 1,
            created_at TEXT,
            updated_at TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE categories (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE suppliers (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            contact_person TEXT,
            phone TEXT,
            email TEXT,
            address TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE product_variants (
            id TEXT PRIMARY KEY,
            product_id TEXT NOT NULL,
            name TEXT NOT NULL,
            sku TEXT,
            barcode TEXT,
            additional_price REAL,
            FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE
          )
        ''');

        await db.execute('CREATE INDEX idx_products_category ON products(category_id)');
        await db.execute('CREATE INDEX idx_products_supplier ON products(supplier_id)');
        await db.execute('CREATE INDEX idx_products_barcode ON products(barcode)');
        await db.execute('CREATE INDEX idx_variants_product ON product_variants(product_id)');

        await _insertSampleData(db);
      },
    );
  }

  Future<void> _insertSampleData(Database db) async {
    final now = DateTime.now().toIso8601String();
    
    await db.insert('categories', {
      'id': 'cat_1',
      'name': 'مشروبات ساخنة',
      'description': 'مشروبات ساخنة مثل القهوة والشاي',
    });
    await db.insert('categories', {
      'id': 'cat_2', 
      'name': 'مشروبات باردة',
      'description': 'مشروبات باردة ومثلجة',
    });
    await db.insert('categories', {
      'id': 'cat_3',
      'name': 'حلويات',
      'description': 'الحلويات والمخبوزات',
    });

    await db.insert('suppliers', {
      'id': 'sup_1',
      'name': 'شركة التاجرة有限公司',
      'contact_person': 'أحمد محمد',
      'phone': '+966501234567',
      'email': 'info@altajir.com',
      'address': 'الرياض، الصناعية',
    });
    await db.insert('suppliers', {
      'id': 'sup_2',
      'name': 'مؤسسة الاصيل',
      'contact_person': 'خالد Saleh',
      'phone': '+966509876543',
      'email': 'contact@alaseel.com',
      'address': 'جدة، حي النزهة',
    });

    await db.insert('products', {
      'id': 'prod_1',
      'name': 'اسبريسو',
      'unit_price': 15.0,
      'available_quantity': 100.0,
      'type': 'finished_product',
      'unit_of_measure': 'كوب',
      'category_id': 'cat_1',
      'sku': 'ESP001',
      'barcode': '1234567890123',
      'reorder_point': 20.0,
      'cost_price': 8.0,
      'is_active': 1,
      'created_at': now,
      'updated_at': now,
    });
    await db.insert('products', {
      'id': 'prod_2',
      'name': 'لاتيه',
      'unit_price': 18.0,
      'available_quantity': 80.0,
      'type': 'finished_product',
      'unit_of_measure': 'كوب',
      'category_id': 'cat_1',
      'sku': 'LAT001',
      'barcode': '1234567890124',
      'reorder_point': 15.0,
      'cost_price': 10.0,
      'is_active': 1,
      'created_at': now,
      'updated_at': now,
    });
    await db.insert('products', {
      'id': 'prod_3',
      'name': 'موكا',
      'unit_price': 20.0,
      'available_quantity': 50.0,
      'type': 'finished_product',
      'unit_of_measure': 'كوب',
      'category_id': 'cat_1',
      'sku': 'MOC001',
      'reorder_point': 10.0,
      'cost_price': 12.0,
      'is_active': 1,
      'created_at': now,
      'updated_at': now,
    });
    await db.insert('products', {
      'id': 'prod_4',
      'name': 'عصير برتقال',
      'unit_price': 12.0,
      'available_quantity': 60.0,
      'type': 'finished_product',
      'unit_of_measure': 'كوب',
      'category_id': 'cat_2',
      'sku': 'OJ001',
      'barcode': '1234567890125',
      'reorder_point': 25.0,
      'cost_price': 6.0,
      'is_active': 1,
      'created_at': now,
      'updated_at': now,
    });
    await db.insert('products', {
      'id': 'prod_5',
      'name': 'كابتشينو',
      'unit_price': 17.0,
      'available_quantity': 70.0,
      'type': 'finished_product',
      'unit_of_measure': 'كوب',
      'category_id': 'cat_1',
      'sku': 'CAP001',
      'reorder_point': 15.0,
      'cost_price': 9.0,
      'is_active': 1,
      'created_at': now,
      'updated_at': now,
    });
    await db.insert('products', {
      'id': 'prod_6',
      'name': 'شاي',
      'unit_price': 8.0,
      'available_quantity': 200.0,
      'type': 'finished_product',
      'unit_of_measure': 'كوب',
      'category_id': 'cat_1',
      'sku': 'TEA001',
      'reorder_point': 50.0,
      'cost_price': 3.0,
      'is_active': 1,
      'created_at': now,
      'updated_at': now,
    });
  }

  Future<List<Product>> getProducts() async {
    final db = await database;
    final maps = await db.query('products', orderBy: 'name ASC');
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  Future<Product?> getProductById(String id) async {
    final db = await database;
    final maps = await db.query('products', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Product.fromMap(maps.first);
  }

  Future<void> insertProduct(Product product) async {
    final db = await database;
    await db.insert('products', product.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateProduct(Product product) async {
    final db = await database;
    await db.update('products', product.toMap(),
        where: 'id = ?', whereArgs: [product.id]);
  }

  Future<void> deleteProduct(String id) async {
    final db = await database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Product>> searchProducts(String query) async {
    final db = await database;
    final maps = await db.query(
      'products',
      where: 'name LIKE ? OR sku LIKE ? OR barcode LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  Future<List<Product>> getLowStockProducts() async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT * FROM products 
      WHERE reorder_point IS NOT NULL 
      AND available_quantity < reorder_point 
      AND is_active = 1
      ORDER BY (available_quantity / reorder_point) ASC
    ''');
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  Future<List<Product>> getProductsByCategory(String categoryId) async {
    final db = await database;
    final maps = await db.query(
      'products',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'name ASC',
    );
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  Future<int> getProductCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM products');
    return result.first['count'] as int;
  }

  Future<int> getLowStockCount() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count FROM products 
      WHERE reorder_point IS NOT NULL 
      AND available_quantity < reorder_point 
      AND is_active = 1
    ''');
    return result.first['count'] as int;
  }

  Future<List<ProductCategory>> getCategories() async {
    final db = await database;
    final maps = await db.query('categories', orderBy: 'name ASC');
    return maps.map((map) => ProductCategory.fromMap(map)).toList();
  }

  Future<void> insertCategory(ProductCategory category) async {
    final db = await database;
    await db.insert('categories', category.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateCategory(ProductCategory category) async {
    final db = await database;
    await db.update('categories', category.toMap(),
        where: 'id = ?', whereArgs: [category.id]);
  }

  Future<void> deleteCategory(String id) async {
    final db = await database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Supplier>> getSuppliers() async {
    final db = await database;
    final maps = await db.query('suppliers', orderBy: 'name ASC');
    return maps.map((map) => Supplier.fromMap(map)).toList();
  }

  Future<void> insertSupplier(Supplier supplier) async {
    final db = await database;
    await db.insert('suppliers', supplier.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateSupplier(Supplier supplier) async {
    final db = await database;
    await db.update('suppliers', supplier.toMap(),
        where: 'id = ?', whereArgs: [supplier.id]);
  }

  Future<void> deleteSupplier(String id) async {
    final db = await database;
    await db.delete('suppliers', where: 'id = ?', whereArgs: [id]);
  }

  Future<ProductCategory?> getCategoryById(String id) async {
    final db = await database;
    final maps = await db.query('categories', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return ProductCategory.fromMap(maps.first);
  }

  Future<Supplier?> getSupplierById(String id) async {
    final db = await database;
    final maps = await db.query('suppliers', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Supplier.fromMap(maps.first);
  }
}