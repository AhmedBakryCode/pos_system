class DomainEvent {
  const DomainEvent({
    required this.name,
    required this.aggregateId,
    required this.occurredAtIso,
    required this.payload,
  });

  final String name;
  final String aggregateId;
  final String occurredAtIso;
  final Map<String, Object?> payload;
}
