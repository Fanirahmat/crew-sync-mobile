import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/biometric_service.dart';
import '../../../../core/services/geofence_service.dart';
import '../../../../core/services/image_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../events/domain/entities/event_entity.dart';
import '../../data/datasources/attendance_remote_data_source.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/repositories/attendance_repository.dart';

// Foundation Providers
final geofenceServiceProvider = Provider<GeofenceService>((ref) {
  return GeofenceService();
});

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

final imageServiceProvider = Provider<ImageService>((ref) {
  return ImageService();
});

final attendanceRemoteDataSourceProvider = Provider<AttendanceRemoteDataSource>((ref) {
  return AttendanceRemoteDataSourceImpl(ref.watch(dioClientProvider));
});

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepositoryImpl(
    remoteDataSource: ref.watch(attendanceRemoteDataSourceProvider),
  );
});

// Geofence Evaluation Provider (Auto-evaluated on-demand when opening attendance sheet)
final geofenceEvaluationProvider =
    FutureProvider.autoDispose.family<GeofenceStatusResult, EventEntity>((ref, event) async {
  final service = ref.watch(geofenceServiceProvider);
  return await service.evaluateGeofence(
    venueLat: event.venueLat,
    venueLng: event.venueLng,
    allowedRadiusMeters: event.geofenceRadiusMeters,
  );
});

// Attendance Submission Notifier
class AttendanceSubmissionNotifier extends AsyncNotifier<AttendanceEntity?> {
  @override
  FutureOr<AttendanceEntity?> build() => null;

  /// Submits attendance via Biometric hardware
  Future<AttendanceEntity?> submitBiometric({
    required EventEntity event,
    required AttendanceType type,
    required GeofenceStatusResult geofence,
  }) async {
    state = const AsyncValue.loading();
    try {
      final bioService = ref.read(biometricServiceProvider);
      final success = await bioService.authenticate(
        localizedReason: 'Konfirmasi ${type.toDisplay()} untuk acara ${event.title}',
      );

      if (!success) {
        state = const AsyncValue.data(null);
        return null;
      }

      final repo = ref.read(attendanceRepositoryProvider);
      final result = await repo.submitAttendance(
        eventId: event.id,
        type: type,
        method: AttendanceMethod.biometric,
        clientLat: geofence.clientLat,
        clientLng: geofence.clientLng,
        clientDistanceMeters: geofence.distanceMeters.round(),
        isWithinGeofence: geofence.isWithinGeofence,
        biometricTokenRef: 'local_auth_hardware_ok',
      );

      state = AsyncValue.data(result);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Submits attendance via Selfie Photo capture
  Future<AttendanceEntity?> submitPhoto({
    required EventEntity event,
    required AttendanceType type,
    required GeofenceStatusResult geofence,
    required File photoFile,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(attendanceRepositoryProvider);
      final result = await repo.submitAttendance(
        eventId: event.id,
        type: type,
        method: AttendanceMethod.photo,
        clientLat: geofence.clientLat,
        clientLng: geofence.clientLng,
        clientDistanceMeters: geofence.distanceMeters.round(),
        isWithinGeofence: geofence.isWithinGeofence,
        photoPath: photoFile.path,
      );

      state = AsyncValue.data(result);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final attendanceSubmissionNotifierProvider =
    AsyncNotifierProvider<AttendanceSubmissionNotifier, AttendanceEntity?>(
  AttendanceSubmissionNotifier.new,
);
