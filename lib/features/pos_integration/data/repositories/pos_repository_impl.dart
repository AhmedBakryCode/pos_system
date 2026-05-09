import '../../domain/entities/pos_sync_status.dart';
import '../../domain/repositories/pos_repository.dart';

class PosRepositoryImpl implements PosRepository {
  @override
  Future<PosSyncStatus> getSyncStatus() async {
    return const PosSyncStatus(syncedOrders: 1242, totalOrders: 1258);
  }
}
