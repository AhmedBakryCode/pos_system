import '../entities/audit_kpis.dart';

abstract class AuditRepository {
  Future<AuditKpis> getKpis();
}
