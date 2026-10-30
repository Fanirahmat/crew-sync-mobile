import '../../../../core/storage/hive_service.dart';
import '../models/event_model.dart';
import '../models/rundown_item_model.dart';

abstract class EventLocalDataSource {
  Future<void> cacheEvents(List<EventModel> events);
  List<EventModel>? getCachedEvents();
  Future<void> cacheRundown(String eventId, List<RundownItemModel> rundownItems);
  List<RundownItemModel>? getCachedRundown(String eventId);
  EventModel? getCachedEventById(String eventId);
}

class EventLocalDataSourceImpl implements EventLocalDataSource {
  final HiveService _storage;

  EventLocalDataSourceImpl(this._storage);

  @override
  Future<void> cacheEvents(List<EventModel> events) async {
    final list = events.map((e) => e.toJson()).toList();
    await _storage.cacheEvents(list);
  }

  @override
  List<EventModel>? getCachedEvents() {
    final list = _storage.getCachedEvents();
    if (list == null) return null;
    return list.map((json) => EventModel.fromJson(json)).toList();
  }

  @override
  EventModel? getCachedEventById(String eventId) {
    final events = getCachedEvents();
    if (events == null) return null;
    try {
      return events.firstWhere((e) => e.id == eventId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cacheRundown(String eventId, List<RundownItemModel> rundownItems) async {
    final list = rundownItems.map((e) => e.toJson()).toList();
    await _storage.cacheRundown(eventId, list);
  }

  @override
  List<RundownItemModel>? getCachedRundown(String eventId) {
    final list = _storage.getCachedRundown(eventId);
    if (list == null) return null;
    return list.map((json) => RundownItemModel.fromJson(json)).toList();
  }
}
