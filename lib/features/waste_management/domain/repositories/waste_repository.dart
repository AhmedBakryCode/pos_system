import '../entities/waste.dart';

abstract class WasteRepository {
  Future<List<Waste>> getWastes({int page = 1});
  
  Future<Waste> createWaste({
    required String reason,
    required List<WasteItemInput> items,
  });

  Future<Waste> updateWaste(
    int id, {
    required String reason,
    required List<WasteItemInput> items,
  });

  Future<void> deleteWaste(int id);
}
