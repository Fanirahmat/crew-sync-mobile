import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/checklist_item_entity.dart';
import '../../domain/repositories/logistics_repository.dart';
import '../datasources/logistics_local_data_source.dart';
import '../datasources/logistics_remote_data_source.dart';

class LogisticsRepositoryImpl implements LogisticsRepository {
  final LogisticsRemoteDataSource _remoteDataSource;
  final LogisticsLocalDataSource _localDataSource;

  LogisticsRepositoryImpl({
    required LogisticsRemoteDataSource remoteDataSource,
    required LogisticsLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<List<ChecklistItemEntity>> getChecklist(
    String eventId, {
    ChecklistStage? stage,
    bool forceRefresh = false,
  }) async {
    try {
      final remoteItems = await _remoteDataSource.getChecklist(eventId);
      await _localDataSource.cacheChecklist(eventId, remoteItems);

      if (stage != null) {
        return remoteItems.where((i) => i.stage == stage).toList();
      }
      return remoteItems;
    } catch (e) {
      // Fallback to offline Hive cache
      final cached = _localDataSource.getCachedChecklist(eventId);
      if (cached != null && cached.isNotEmpty) {
        if (stage != null) {
          return cached.where((i) => i.stage == stage).toList();
        }
        return cached;
      }
      throw const NetworkFailure(
        'Gagal memuat daftar checklist logistik. Perangkat sedang offline dan belum ada cache.',
      );
    }
  }

  @override
  Future<ChecklistItemEntity> verifyItem({
    required String eventId,
    required String itemId,
    required int actualQuantity,
    required ItemCondition condition,
    String? notes,
    File? photoEvidence,
  }) async {
    try {
      final verifiedModel = await _remoteDataSource.verifyItem(
        itemId: itemId,
        actualQuantity: actualQuantity,
        condition: condition.toApiString(),
        notes: notes,
        photoEvidence: photoEvidence,
      );

      // Update local storage item
      await _localDataSource.updateSingleItem(verifiedModel);
      return verifiedModel;
    } on DioException catch (dioErr) {
      if (dioErr.error is AppException) {
        final appErr = dioErr.error as AppException;
        throw ServerFailure(appErr.message, appErr.statusCode);
      }
      throw ServerFailure(dioErr.message ?? 'Gagal memverifikasi barang logistik.');
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Gagal memverifikasi item: $e');
    }
  }
}
