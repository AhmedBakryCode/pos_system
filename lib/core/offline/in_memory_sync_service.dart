import 'sync_service.dart';

class InMemorySyncService implements SyncService {
  @override
  Future<int> pendingOperationsCount() async => 7;
}
