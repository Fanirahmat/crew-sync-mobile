import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/hive_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/logistics_local_data_source.dart';
import '../../data/datasources/logistics_remote_data_source.dart';
import '../../data/repositories/logistics_repository_impl.dart';
import '../../domain/entities/checklist_item_entity.dart';
import '../../domain/repositories/logistics_repository.dart';

// Foundation Providers
final logisticsLocalDataSourceProvider = Provider<LogisticsLocalDataSource>((ref) {
  return LogisticsLocalDataSourceImpl(HiveService());
});

final logisticsRemoteDataSourceProvider = Provider<LogisticsRemoteDataSource>((ref) {
  return LogisticsRemoteDataSourceImpl(ref.watch(dioClientProvider));
});

final logisticsRepositoryProvider = Provider<LogisticsRepository>((ref) {
  return LogisticsRepositoryImpl(
    remoteDataSource: ref.watch(logisticsRemoteDataSourceProvider),
    localDataSource: ref.watch(logisticsLocalDataSourceProvider),
  );
});

// Logistics Notifier per Event
class LogisticsNotifier extends AsyncNotifier<List<ChecklistItemEntity>> {
  final String eventId;
  LogisticsNotifier(this.eventId);

  @override
  Future<List<ChecklistItemEntity>> build() async {
    final repo = ref.watch(logisticsRepositoryProvider);
    return repo.getChecklist(eventId);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(logisticsRepositoryProvider).getChecklist(eventId, forceRefresh: true),
    );
  }

  Future<ChecklistItemEntity> verifyItem({
    required String itemId,
    required int actualQuantity,
    required ItemCondition condition,
    String? notes,
    File? photoEvidence,
  }) async {
    final repo = ref.read(logisticsRepositoryProvider);
    final verifiedItem = await repo.verifyItem(
      eventId: eventId,
      itemId: itemId,
      actualQuantity: actualQuantity,
      condition: condition,
      notes: notes,
      photoEvidence: photoEvidence,
    );

    // Update Riverpod state optimistically
    state.whenData((currentList) {
      final updated = currentList.map((i) => i.id == itemId ? verifiedItem : i).toList();
      state = AsyncValue.data(updated);
    });

    return verifiedItem;
  }
}

final logisticsNotifierProvider =
    AsyncNotifierProvider.family<LogisticsNotifier, List<ChecklistItemEntity>, String>(
  (arg) => LogisticsNotifier(arg),
);
