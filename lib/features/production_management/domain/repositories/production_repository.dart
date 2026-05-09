import '../entities/production.dart';

abstract class ProductionRepository {
  Future<List<Production>> getProductions({int page = 1});
  
  Future<Production> createProduction({
    required int recipeId,
    required double quantity,
  });

  Future<Production> updateProduction(
    int id, {
    required int recipeId,
    required double quantity,
  });

  Future<void> executeProduction(int id);
  
  Future<void> deleteProduction(int id);
}
