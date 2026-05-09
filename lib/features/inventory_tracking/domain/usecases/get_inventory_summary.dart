import '../entities/inventory_summary.dart';
import '../repositories/inventory_repository.dart';

class GetInventorySummary {
  const GetInventorySummary(this._repository);

  final InventoryRepository _repository;

  Future<InventorySummary> call() => _repository.getInventorySummary();
}
