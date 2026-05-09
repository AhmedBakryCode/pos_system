import '../../domain/entities/audit_kpis.dart';
import '../../domain/repositories/audit_repository.dart';

class AuditRepositoryImpl implements AuditRepository {
  @override
  Future<AuditKpis> getKpis() async {
    return const AuditKpis(exceptionCount: 9, pendingReviews: 4);
  }
}
