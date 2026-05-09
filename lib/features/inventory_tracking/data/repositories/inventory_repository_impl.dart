import '../../domain/entities/inventory_summary.dart';
import '../../domain/repositories/inventory_repository.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  @override
  Future<InventorySummary> getInventorySummary() async {
    return const InventorySummary(stockValue: 248500, lowStockItems: 14);
  }
}
