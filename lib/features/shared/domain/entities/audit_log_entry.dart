class AuditLogEntry {
  const AuditLogEntry({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.action,
    required this.actorId,
    required this.timestampIso,
    required this.beforeSnapshot,
    required this.afterSnapshot,
    required this.metadata,
  });

  final String id;
  final String entityType;
  final String entityId;
  final String action;
  final String actorId;
  final String timestampIso;
  final Map<String, Object?> beforeSnapshot;
  final Map<String, Object?> afterSnapshot;
  final Map<String, Object?> metadata;
}
