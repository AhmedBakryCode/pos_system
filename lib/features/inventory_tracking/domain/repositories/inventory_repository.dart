import '../entities/inventory_summary.dart';

abstract class InventoryRepository {
  Future<InventorySummary> getInventorySummary();
}
