import '../entities/event_entity.dart';
import '../entities/rundown_item_entity.dart';

/// Contract interface for Event and Rundown data operations.
abstract class EventRepository {
  /// Fetches events assigned to the logged-in crew member.
  /// Falls back to local Hive cache when offline.
  Future<List<EventEntity>> getAssignedEvents({bool forceRefresh = false});

  /// Fetches a single event by its ID.
  Future<EventEntity?> getEventById(String eventId);

  /// Fetches rundown items for a specific event.
  /// Falls back to local Hive cache when in offline venue areas.
  Future<List<RundownItemEntity>> getRundown(
    String eventId, {
    bool forceRefresh = false,
  });

  /// Subscribes to FCM broadcast topic for the event.
  Future<void> subscribeToEventCues(String eventId);

  /// Unsubscribes from event topic when leaving the event screen.
  Future<void> unsubscribeFromEventCues(String eventId);

  /// Stream of real-time rundown cue updates delivered via FCM.
  Stream<RundownItemEntity> get liveCueStream;
}
