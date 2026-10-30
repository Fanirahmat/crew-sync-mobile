enum RundownStatus {
  pending,
  active,
  completed;

  static RundownStatus fromString(String? val) {
    switch (val?.toUpperCase()) {
      case 'ACTIVE':
      case 'SEDANG':
      case 'SEDANG BERLANGSUNG':
        return RundownStatus.active;
      case 'COMPLETED':
      case 'SELESAI':
        return RundownStatus.completed;
      case 'PENDING':
      case 'BERIKUTNYA':
      default:
        return RundownStatus.pending;
    }
  }

  String toApiString() {
    switch (this) {
      case RundownStatus.active:
        return 'ACTIVE';
      case RundownStatus.completed:
        return 'COMPLETED';
      case RundownStatus.pending:
        return 'PENDING';
    }
  }

  String toDisplayBadge() {
    switch (this) {
      case RundownStatus.active:
        return 'SEDANG BERLANGSUNG';
      case RundownStatus.completed:
        return 'Selesai';
      case RundownStatus.pending:
        return 'Berikutnya';
    }
  }
}

/// Domain entity representing a chronological rundown session in an event.
class RundownItemEntity {
  final String id;
  final String eventId;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final String zone;
  final String picName;
  final String? picRole;
  final RundownStatus status;
  final int orderIndex;

  const RundownItemEntity({
    required this.id,
    required this.eventId,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.zone,
    required this.picName,
    this.picRole,
    required this.status,
    required this.orderIndex,
  });

  RundownItemEntity copyWith({
    String? id,
    String? eventId,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? zone,
    String? picName,
    String? picRole,
    RundownStatus? status,
    int? orderIndex,
  }) {
    return RundownItemEntity(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      zone: zone ?? this.zone,
      picName: picName ?? this.picName,
      picRole: picRole ?? this.picRole,
      status: status ?? this.status,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RundownItemEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
