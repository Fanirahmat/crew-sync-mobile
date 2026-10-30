import '../../domain/entities/checklist_item_entity.dart';

/// Data model representing a checklist inventory item with JSON & Hive Map serialization.
class ChecklistItemModel extends ChecklistItemEntity {
  const ChecklistItemModel({
    required super.id,
    required super.eventId,
    required super.stage,
    required super.itemName,
    required super.targetQuantity,
    required super.actualQuantity,
    super.unit,
    super.condition,
    super.verifiedBy,
    super.photoEvidenceUrl,
    super.notes,
    super.isVerified,
  });

  factory ChecklistItemModel.fromJson(Map<String, dynamic> json) {
    final conditionStr = json['condition']?.toString();
    final verified = json['isVerified'] ??
        json['is_verified'] ??
        (conditionStr != null &&
            conditionStr != 'PENDING' &&
            (json['verifiedAt'] != null || json['verifiedByUserId'] != null));

    return ChecklistItemModel(
      id: json['id']?.toString() ?? '',
      eventId: json['eventId']?.toString() ?? json['event_id']?.toString() ?? '',
      stage: ChecklistStage.fromString(json['stage']?.toString()),
      itemName: json['itemName']?.toString() ?? json['item_name']?.toString() ?? '',
      targetQuantity: int.tryParse((json['targetQuantity'] ?? json['target_quantity'] ?? json['quantityExpected'] ?? 0).toString()) ?? 0,
      actualQuantity: int.tryParse((json['actualQuantity'] ?? json['actual_quantity'] ?? json['quantityActual'] ?? 0).toString()) ?? 0,
      unit: json['unit']?.toString() ?? 'Unit',
      condition: ItemCondition.fromString(conditionStr),
      verifiedBy: json['verifiedByUser'] is Map
          ? json['verifiedByUser']['fullName']?.toString()
          : (json['verifiedBy']?.toString() ?? json['verified_by']?.toString()),
      photoEvidenceUrl: json['photoEvidenceUrl']?.toString() ?? json['proofImageUrl']?.toString() ?? json['photo_evidence_url']?.toString(),
      notes: json['notes']?.toString(),
      isVerified: verified as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'stage': stage.toApiString(),
      'itemName': itemName,
      'targetQuantity': targetQuantity,
      'actualQuantity': actualQuantity,
      'unit': unit,
      'condition': condition.toApiString(),
      'verifiedBy': verifiedBy,
      'photoEvidenceUrl': photoEvidenceUrl,
      'notes': notes,
      'isVerified': isVerified,
    };
  }

  factory ChecklistItemModel.fromEntity(ChecklistItemEntity entity) {
    return ChecklistItemModel(
      id: entity.id,
      eventId: entity.eventId,
      stage: entity.stage,
      itemName: entity.itemName,
      targetQuantity: entity.targetQuantity,
      actualQuantity: entity.actualQuantity,
      unit: entity.unit,
      condition: entity.condition,
      verifiedBy: entity.verifiedBy,
      photoEvidenceUrl: entity.photoEvidenceUrl,
      notes: entity.notes,
      isVerified: entity.isVerified,
    );
  }
}
