import '../entities/attendance_entity.dart';

abstract class AttendanceRepository {
  /// Submits attendance record (Biometric or Photo) to the backend.
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
  });

  /// Retrieves attendance history for the event
  Future<List<AttendanceEntity>> getAttendanceHistory(String eventId);
}
