import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_remote_data_source.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource _remoteDataSource;

  AttendanceRepositoryImpl({
    required AttendanceRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<AttendanceEntity> submitAttendance({
    required String eventId,
    required AttendanceType type,
    required AttendanceMethod method,
    required double clientLat,
    required double clientLng,
    required int clientDistanceMeters,
    required bool isWithinGeofence,
    String? photoPath,
    String? biometricTokenRef,
  }) async {
    try {
      final model = await _remoteDataSource.submitAttendance(
        eventId: eventId,
        type: type.toApiString(),
        method: method.toApiString(),
        clientLat: clientLat,
        clientLng: clientLng,
        clientDistanceMeters: clientDistanceMeters,
        isWithinGeofence: isWithinGeofence,
        photoPath: photoPath,
        biometricTokenRef: biometricTokenRef,
      );
      return model;
    } on DioException catch (dioErr) {
      if (dioErr.error is AppException) {
        final appErr = dioErr.error as AppException;
        throw ServerFailure(appErr.message, appErr.statusCode);
      }
      throw ServerFailure(dioErr.message ?? 'Gagal mengirimkan data presensi.');
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Presensi gagal diproses: $e');
    }
  }

  @override
  Future<List<AttendanceEntity>> getAttendanceHistory(String eventId) async {
    try {
      return await _remoteDataSource.getAttendanceHistory(eventId);
    } catch (e) {
      return [];
    }
  }
}
