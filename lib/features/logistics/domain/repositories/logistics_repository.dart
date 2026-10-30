import 'dart:io';
import '../entities/checklist_item_entity.dart';

abstract class LogisticsRepository {
  /// Fetches checklist items for an event, falling back to local Hive storage when offline.
  Future<List<ChecklistItemEntity>> getChecklist(
    String eventId, {
    ChecklistStage? stage,
    bool forceRefresh = false,
  });

  /// Verifies an inventory item with actual physical count, condition status, and optional photo evidence.
  Future<ChecklistItemEntity> verifyItem({
    required String eventId,
    required String itemId,
    required int actualQuantity,
    required ItemCondition condition,
    String? notes,
    File? photoEvidence,
  });
}
