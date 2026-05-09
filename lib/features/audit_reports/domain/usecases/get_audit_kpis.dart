import '../entities/audit_kpis.dart';
import '../repositories/audit_repository.dart';

class GetAuditKpis {
  const GetAuditKpis(this._repository);

  final AuditRepository _repository;

  Future<AuditKpis> call() => _repository.getKpis();
}
