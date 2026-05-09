import '../entities/grn.dart';

abstract class GRNRepository {
  Future<List<GRN>> getGRNs({int page = 1});
  
  Future<GRN> createGRN({
    required int purchaseOrderId,
    required List<GRNItemInput> items,
  });

  Future<GRN> updateGRN(
    int id, {
    required int purchaseOrderId,
    required List<GRNItemInput> items,
  });

  Future<void> deleteGRN(int id);
}
