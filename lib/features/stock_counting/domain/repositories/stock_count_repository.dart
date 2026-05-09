import '../entities/stock_count.dart';

abstract class StockCountRepository {
  Future<List<StockCount>> getStockCounts({int page = 1});
  
  Future<StockCount> createStockCount({
    required List<StockCountItemInput> items,
  });

  Future<StockCount> updateStockCount(
    int id, {
    required List<StockCountItemInput> items,
  });

  Future<void> applyStockCount(int id);
  
  Future<void> deleteStockCount(int id);
}
