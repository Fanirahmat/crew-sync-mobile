import '../../../../core/network/dio_client.dart';
import '../models/event_model.dart';
import '../models/rundown_item_model.dart';

abstract class EventRemoteDataSource {
  Future<List<EventModel>> getEvents();
  Future<EventModel> getEventById(String eventId);
  Future<List<RundownItemModel>> getRundown(String eventId);
}

class EventRemoteDataSourceImpl implements EventRemoteDataSource {
  final DioClient _client;

  EventRemoteDataSourceImpl(this._client);

  @override
  Future<List<EventModel>> getEvents() async {
    final response = await _client.get('/events');
    final data = response.data;

    List list = [];
    if (data is List) {
      list = data;
    } else if (data is Map && data['data'] is List) {
      list = data['data'] as List;
    }

    return list.map((item) => EventModel.fromJson(Map<String, dynamic>.from(item as Map))).toList();
  }

  @override
  Future<EventModel> getEventById(String eventId) async {
    final response = await _client.get('/events/$eventId');
    final data = response.data;
    final map = data is Map && data['data'] is Map ? data['data'] : data;
    return EventModel.fromJson(Map<String, dynamic>.from(map as Map));
  }

  @override
  Future<List<RundownItemModel>> getRundown(String eventId) async {
    final response = await _client.get('/events/$eventId/rundown');
    final data = response.data;

    List list = [];
    if (data is List) {
      list = data;
    } else if (data is Map && data['data'] is List) {
      list = data['data'] as List;
    }

    final items = list
        .map((item) => RundownItemModel.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();

    // Sort chronologically by orderIndex or startTime
    items.sort((a, b) {
      final orderCmp = a.orderIndex.compareTo(b.orderIndex);
      if (orderCmp != 0) return orderCmp;
      return a.startTime.compareTo(b.startTime);
    });

    return items;
  }
}
