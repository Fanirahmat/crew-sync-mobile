import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/fcm_service.dart';
import '../../../../core/storage/hive_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/event_local_data_source.dart';
import '../../data/datasources/event_remote_data_source.dart';
import '../../data/repositories/event_repository_impl.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/entities/rundown_item_entity.dart';
import '../../domain/repositories/event_repository.dart';

// Foundation Providers
final fcmServiceProvider = Provider<FcmService>((ref) {
  return FcmService();
});

final eventLocalDataSourceProvider = Provider<EventLocalDataSource>((ref) {
  return EventLocalDataSourceImpl(HiveService());
});

final eventRemoteDataSourceProvider = Provider<EventRemoteDataSource>((ref) {
  return EventRemoteDataSourceImpl(ref.watch(dioClientProvider));
});

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  final repo = EventRepositoryImpl(
    remoteDataSource: ref.watch(eventRemoteDataSourceProvider),
    localDataSource: ref.watch(eventLocalDataSourceProvider),
    fcmService: ref.watch(fcmServiceProvider),
  );
  ref.onDispose(repo.dispose);
  return repo;
});

// Event List Provider
class EventListNotifier extends AsyncNotifier<List<EventEntity>> {
  @override
  Future<List<EventEntity>> build() async {
    return ref.watch(eventRepositoryProvider).getAssignedEvents();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(eventRepositoryProvider).getAssignedEvents(forceRefresh: true),
    );
  }
}

final eventListNotifierProvider =
    AsyncNotifierProvider<EventListNotifier, List<EventEntity>>(EventListNotifier.new);

// Rundown Timeline Provider per Event (Family)
class RundownNotifier extends AsyncNotifier<List<RundownItemEntity>> {
  final String eventId;
  RundownNotifier(this.eventId);

  StreamSubscription<RundownItemEntity>? _liveCueSubscription;

  @override
  Future<List<RundownItemEntity>> build() async {
    final repo = ref.watch(eventRepositoryProvider);

    // 1. Subscribe to FCM broadcast topic for this event
    await repo.subscribeToEventCues(eventId);

    // 2. Listen to real-time FCM cue updates
    _liveCueSubscription?.cancel();
    _liveCueSubscription = repo.liveCueStream.listen((liveCue) {
      if (liveCue.eventId == eventId) {
        _applyLiveCueUpdate(liveCue);
      }
    });

    ref.onDispose(() {
      _liveCueSubscription?.cancel();
      repo.unsubscribeFromEventCues(eventId);
    });

    // 3. Load initial rundown data (remote or Hive cache)
    return repo.getRundown(eventId);
  }

  /// Instantly updates the Riverpod state when an FCM cue signal is received
  void _applyLiveCueUpdate(RundownItemEntity updatedCue) {
    state.whenData((currentList) {
      final updatedList = currentList.map((item) {
        if (item.id == updatedCue.id) {
          return updatedCue;
        }
        // If a new item becomes ACTIVE, previous active items transition to COMPLETED
        if (updatedCue.status == RundownStatus.active && item.status == RundownStatus.active) {
          return item.copyWith(status: RundownStatus.completed);
        }
        return item;
      }).toList();

      state = AsyncValue.data(updatedList);
    });
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(eventRepositoryProvider).getRundown(eventId, forceRefresh: true),
    );
  }
}

final rundownNotifierProvider = AsyncNotifierProvider.family<
    RundownNotifier, List<RundownItemEntity>, String>(
  (arg) => RundownNotifier(arg),
);
