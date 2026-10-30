import '../../domain/entities/attendance_entity.dart';

class AttendanceModel extends AttendanceEntity {
  const AttendanceModel({
    required super.id,
    required super.eventId,
    required super.userId,
    required super.type,
    required super.method,
    required super.clientLat,
    required super.clientLng,
    required super.clientDistanceMeters,
    required super.isWithinGeofence,
    super.photoUrl,
    required super.timestamp,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id']?.toString() ?? '',
      eventId: json['eventId']?.toString() ?? json['event_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? json['user_id']?.toString() ?? '',
      type: AttendanceType.fromString(json['type']?.toString()),
      method: AttendanceMethod.fromString(json['method']?.toString()),
      clientLat: double.tryParse((json['clientLat'] ?? json['client_lat'] ?? 0.0).toString()) ?? 0.0,
      clientLng: double.tryParse((json['clientLng'] ?? json['client_lng'] ?? 0.0).toString()) ?? 0.0,
      clientDistanceMeters: int.tryParse((json['clientDistanceMeters'] ?? json['client_distance_meters'] ?? 0).toString()) ?? 0,
      isWithinGeofence: json['isWithinGeofence'] ?? json['is_within_geofence'] ?? true,
      photoUrl: json['photoUrl']?.toString() ?? json['photo_url']?.toString(),
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'userId': userId,
      'type': type.toApiString(),
      'method': method.toApiString(),
      'clientLat': clientLat,
      'clientLng': clientLng,
      'clientDistanceMeters': clientDistanceMeters,
      'isWithinGeofence': isWithinGeofence,
      'photoUrl': photoUrl,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
