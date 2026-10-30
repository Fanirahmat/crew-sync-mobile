import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/fcm_service.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/entities/rundown_item_entity.dart';
import '../../domain/repositories/event_repository.dart';
import '../datasources/event_local_data_source.dart';
import '../datasources/event_remote_data_source.dart';
import '../models/rundown_item_model.dart';

class EventRepositoryImpl implements EventRepository {
  final EventRemoteDataSource _remoteDataSource;
  final EventLocalDataSource _localDataSource;
  final FcmService _fcmService;

  final StreamController<RundownItemEntity> _liveCueController =
      StreamController<RundownItemEntity>.broadcast();
  StreamSubscription? _fcmSubscription;

  EventRepositoryImpl({
    required EventRemoteDataSource remoteDataSource,
    required EventLocalDataSource localDataSource,
    required FcmService fcmService,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _fcmService = fcmService {
    _initFcmListener();
  }

  void _initFcmListener() {
    _fcmSubscription = _fcmService.onForegroundMessage.listen((message) {
      final data = message.data;
      final type = data['type']?.toString() ?? data['eventType']?.toString();

      if (type == 'RUNDOWN_CUE_UPDATE') {
        try {
          final item = RundownItemModel.fromJson(data);
          _liveCueController.add(item);
          if (kDebugMode) {
            debugPrint('[EventRepository] Live cue received: ${item.title} -> ${item.status}');
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('[EventRepository] Error parsing live cue FCM data: $e');
          }
        }
      }
    });
  }

  @override
  Stream<RundownItemEntity> get liveCueStream => _liveCueController.stream;

  @override
  Future<List<EventEntity>> getAssignedEvents({bool forceRefresh = false}) async {
    // 1. Try remote fetch
    try {
      final remoteEvents = await _remoteDataSource.getEvents();
      // Cache to local Hive
      await _localDataSource.cacheEvents(remoteEvents);
      return remoteEvents;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[EventRepository] Remote events fetch failed ($e). Falling back to Hive cache.');
      }
      // 2. Fallback to local Hive cache
      final cached = _localDataSource.getCachedEvents();
      if (cached != null && cached.isNotEmpty) {
        return cached.map((event) => event.copyWith(isOfflineCached: true)).toList();
      }
      throw const NetworkFailure(
        'Gagal memuat jadwal acara. Anda sedang offline dan belum ada data tersimpan di perangkat.',
      );
    }
  }

  @override
  Future<EventEntity?> getEventById(String eventId) async {
    try {
      final event = await _remoteDataSource.getEventById(eventId);
      return event;
    } catch (_) {
      final cached = _localDataSource.getCachedEventById(eventId);
      return cached?.copyWith(isOfflineCached: true);
    }
  }

  @override
  Future<List<RundownItemEntity>> getRundown(
    String eventId, {
    bool forceRefresh = false,
  }) async {
    // 1. Attempt remote fetch
    try {
      final remoteItems = await _remoteDataSource.getRundown(eventId);
      // Cache into Hive rundowns_box
      await _localDataSource.cacheRundown(eventId, remoteItems);
      return remoteItems;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[EventRepository] Remote rundown fetch failed ($e). Falling back to Hive.');
      }
      // 2. Fallback to Hive cache
      final cached = _localDataSource.getCachedRundown(eventId);
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }
      throw const NetworkFailure(
        'Gagal memuat rundown. Sinyal venue offline dan belum ada data tersimpan di cache.',
      );
    }
  }

  @override
  Future<void> subscribeToEventCues(String eventId) async {
    await _fcmService.subscribeToEvent(eventId);
  }

  @override
  Future<void> unsubscribeFromEventCues(String eventId) async {
    await _fcmService.unsubscribeFromEvent(eventId);
  }

  void dispose() {
    _fcmSubscription?.cancel();
    _liveCueController.close();
  }
}
