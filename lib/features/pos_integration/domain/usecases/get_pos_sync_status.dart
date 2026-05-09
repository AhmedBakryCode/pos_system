import '../entities/pos_sync_status.dart';
import '../repositories/pos_repository.dart';

class GetPosSyncStatus {
  const GetPosSyncStatus(this._repository);

  final PosRepository _repository;

  Future<PosSyncStatus> call() => _repository.getSyncStatus();
}
