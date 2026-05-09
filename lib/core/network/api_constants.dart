class ApiConstants {
  static const String baseUrl =
      'https://mediumorchid-cassowary-498278.hostingersite.com/inventory-system/public/api/';

  // Auth endpoints
  static const String login = 'auth/login';
  static const String refreshToken = 'auth/refresh-token';
  static const String profile = 'profile';
  static const String logout = 'auth/logout';

  // Products & Attributes
  static const String units = 'units';
  static const String categories = 'categories';
  static const String items = 'items';

  // Purchases
  static const String suppliers = 'suppliers';

  // Goods Receipt Notes
  static const String grns = 'grns';

  // Recipes
  static const String recipes = 'recipes';

  // Orders
  static const String orders = 'orders';

  // Productions
  static const String productions = 'productions';
  static const String purchases = 'purchases';
  // Stock Counts
  static const String stockCounts = 'stock-counts';

  // waste
  static const String wastes = 'wastes';

  // Reports
  static const String inventoryReport = 'reports/inventory';
  static const String profitReport = 'reports/profit';
  static const String movementsReport = 'reports/movement';
  static const String varianceReport = 'reports/variance';
  static const String dailyReport = 'reports/daily';
  static const String topProductsReport = 'reports/top-products';
}
