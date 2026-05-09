import '../entities/pos_sync_status.dart';

abstract class PosRepository {
  Future<PosSyncStatus> getSyncStatus();
}
