enum AttendanceType {
  checkIn,
  checkOut;

  String toApiString() => this == AttendanceType.checkIn ? 'CHECK_IN' : 'CHECK_OUT';

  String toDisplay() => this == AttendanceType.checkIn ? 'Check-In Tiba di Venue' : 'Check-Out Selesai Bertugas';

  static AttendanceType fromString(String? val) {
    return val?.toUpperCase() == 'CHECK_OUT' ? AttendanceType.checkOut : AttendanceType.checkIn;
  }
}

enum AttendanceMethod {
  biometric,
  photo;

  String toApiString() => this == AttendanceMethod.biometric ? 'BIOMETRIC' : 'PHOTO';

  String toDisplay() => this == AttendanceMethod.biometric ? 'Biometrik' : 'Swafoto';

  static AttendanceMethod fromString(String? val) {
    return val?.toUpperCase() == 'BIOMETRIC' ? AttendanceMethod.biometric : AttendanceMethod.photo;
  }
}

/// Domain entity representing a submitted attendance record.
class AttendanceEntity {
  final String id;
  final String eventId;
  final String userId;
  final AttendanceType type;
  final AttendanceMethod method;
  final double clientLat;
  final double clientLng;
  final int clientDistanceMeters;
  final bool isWithinGeofence;
  final String? photoUrl;
  final DateTime timestamp;

  const AttendanceEntity({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.type,
    required this.method,
    required this.clientLat,
    required this.clientLng,
    required this.clientDistanceMeters,
    required this.isWithinGeofence,
    this.photoUrl,
    required this.timestamp,
  });
}
