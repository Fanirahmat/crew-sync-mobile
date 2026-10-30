import '../../../../core/storage/hive_service.dart';
import '../models/checklist_item_model.dart';

abstract class LogisticsLocalDataSource {
  Future<void> cacheChecklist(String eventId, List<ChecklistItemModel> items);
  List<ChecklistItemModel>? getCachedChecklist(String eventId);
  Future<void> updateSingleItem(ChecklistItemModel item);
}

class LogisticsLocalDataSourceImpl implements LogisticsLocalDataSource {
  final HiveService _storage;

  LogisticsLocalDataSourceImpl(this._storage);

  @override
  Future<void> cacheChecklist(String eventId, List<ChecklistItemModel> items) async {
    final list = items.map((e) => e.toJson()).toList();
    await _storage.logisticsBox.put('checklist_$eventId', list);
  }

  @override
  List<ChecklistItemModel>? getCachedChecklist(String eventId) {
    final raw = _storage.logisticsBox.get('checklist_$eventId');
    if (raw == null) return null;
    return (raw as List)
        .map((e) => ChecklistItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<void> updateSingleItem(ChecklistItemModel item) async {
    final current = getCachedChecklist(item.eventId);
    if (current == null) return;

    final updated = current.map((i) => i.id == item.id ? item : i).toList();
    await cacheChecklist(item.eventId, updated);
  }
}
