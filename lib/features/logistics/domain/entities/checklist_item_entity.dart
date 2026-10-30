enum ChecklistStage {
  loadIn,
  loadOut,
  postEvent;

  String toApiString() {
    switch (this) {
      case ChecklistStage.loadIn:
        return 'LOAD_IN';
      case ChecklistStage.loadOut:
        return 'LOAD_OUT';
      case ChecklistStage.postEvent:
        return 'POST_EVENT';
    }
  }

  String toDisplayName() {
    switch (this) {
      case ChecklistStage.loadIn:
        return 'Load-In';
      case ChecklistStage.loadOut:
        return 'Load-Out';
      case ChecklistStage.postEvent:
        return 'Pasca Acara';
    }
  }

  static ChecklistStage fromString(String? val) {
    switch (val?.toUpperCase()) {
      case 'LOAD_OUT':
      case 'LOADOUT':
        return ChecklistStage.loadOut;
      case 'POST_EVENT':
      case 'PASCA_ACARA':
      case 'POSTEVENT':
        return ChecklistStage.postEvent;
      case 'LOAD_IN':
      case 'LOADIN':
      default:
        return ChecklistStage.loadIn;
    }
  }
}

enum ItemCondition {
  good,
  damaged,
  missing;

  String toApiString() {
    switch (this) {
      case ItemCondition.good:
        return 'GOOD';
      case ItemCondition.damaged:
        return 'DAMAGED';
      case ItemCondition.missing:
        return 'MISSING';
    }
  }

  String toDisplayName() {
    switch (this) {
      case ItemCondition.good:
        return 'Baik';
      case ItemCondition.damaged:
        return 'Rusak';
      case ItemCondition.missing:
        return 'Hilang';
    }
  }

  static ItemCondition fromString(String? val) {
    switch (val?.toUpperCase()) {
      case 'DAMAGED':
      case 'RUSAK':
        return ItemCondition.damaged;
      case 'MISSING':
      case 'HILANG':
        return ItemCondition.missing;
      case 'GOOD':
      case 'BAIK':
      default:
        return ItemCondition.good;
    }
  }
}

/// Domain entity representing a logistics checklist inventory item.
class ChecklistItemEntity {
  final String id;
  final String eventId;
  final ChecklistStage stage;
  final String itemName;
  final int targetQuantity;
  final int actualQuantity;
  final String unit; // e.g. Unit, Roll, Set, Box
  final ItemCondition condition;
  final String? verifiedBy;
  final String? photoEvidenceUrl;
  final String? notes;
  final bool isVerified;

  const ChecklistItemEntity({
    required this.id,
    required this.eventId,
    required this.stage,
    required this.itemName,
    required this.targetQuantity,
    required this.actualQuantity,
    this.unit = 'Unit',
    this.condition = ItemCondition.good,
    this.verifiedBy,
    this.photoEvidenceUrl,
    this.notes,
    this.isVerified = false,
  });

  ChecklistItemEntity copyWith({
    String? id,
    String? eventId,
    ChecklistStage? stage,
    String? itemName,
    int? targetQuantity,
    int? actualQuantity,
    String? unit,
    ItemCondition? condition,
    String? verifiedBy,
    String? photoEvidenceUrl,
    String? notes,
    bool? isVerified,
  }) {
    return ChecklistItemEntity(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      stage: stage ?? this.stage,
      itemName: itemName ?? this.itemName,
      targetQuantity: targetQuantity ?? this.targetQuantity,
      actualQuantity: actualQuantity ?? this.actualQuantity,
      unit: unit ?? this.unit,
      condition: condition ?? this.condition,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      photoEvidenceUrl: photoEvidenceUrl ?? this.photoEvidenceUrl,
      notes: notes ?? this.notes,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChecklistItemEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
