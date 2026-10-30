import '../../domain/entities/event_entity.dart';

/// Data model representing an event with JSON & Hive serialization.
class EventModel extends EventEntity {
  const EventModel({
    required super.id,
    required super.title,
    required super.clientName,
    required super.venueName,
    super.venueAddress,
    required super.venueLat,
    required super.venueLng,
    required super.geofenceRadiusMeters,
    required super.eventDate,
    super.isOfflineCached,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      clientName: json['clientName']?.toString() ?? json['client_name']?.toString() ?? '',
      venueName: json['venueName']?.toString() ?? json['venue_name']?.toString() ?? '',
      venueAddress: json['venueAddress']?.toString() ?? json['venue_address']?.toString(),
      venueLat: double.tryParse((json['venueLat'] ?? json['venue_lat'] ?? json['venueLatitude'] ?? 0.0).toString()) ?? 0.0,
      venueLng: double.tryParse((json['venueLng'] ?? json['venue_lng'] ?? json['venueLongitude'] ?? 0.0).toString()) ?? 0.0,
      geofenceRadiusMeters: int.tryParse((json['geofenceRadiusMeters'] ?? json['geofence_radius_meters'] ?? 100).toString()) ?? 100,
      eventDate: json['eventDate'] != null
          ? DateTime.tryParse(json['eventDate'].toString()) ?? DateTime.now()
          : (json['event_date'] != null
              ? DateTime.tryParse(json['event_date'].toString()) ?? DateTime.now()
              : DateTime.now()),
      isOfflineCached: json['isOfflineCached'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'clientName': clientName,
      'venueName': venueName,
      'venueAddress': venueAddress,
      'venueLat': venueLat,
      'venueLng': venueLng,
      'geofenceRadiusMeters': geofenceRadiusMeters,
      'eventDate': eventDate.toIso8601String(),
      'isOfflineCached': isOfflineCached,
    };
  }

  factory EventModel.fromEntity(EventEntity entity) {
    return EventModel(
      id: entity.id,
      title: entity.title,
      clientName: entity.clientName,
      venueName: entity.venueName,
      venueAddress: entity.venueAddress,
      venueLat: entity.venueLat,
      venueLng: entity.venueLng,
      geofenceRadiusMeters: entity.geofenceRadiusMeters,
      eventDate: entity.eventDate,
      isOfflineCached: entity.isOfflineCached,
    );
  }
}
