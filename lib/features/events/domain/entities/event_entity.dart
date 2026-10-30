/// Domain entity representing an event with venue geofence parameters.
class EventEntity {
  final String id;
  final String title;
  final String clientName;
  final String venueName;
  final String? venueAddress;
  final double venueLat;
  final double venueLng;
  final int geofenceRadiusMeters;
  final DateTime eventDate;
  final bool isOfflineCached;

  const EventEntity({
    required this.id,
    required this.title,
    required this.clientName,
    required this.venueName,
    this.venueAddress,
    required this.venueLat,
    required this.venueLng,
    required this.geofenceRadiusMeters,
    required this.eventDate,
    this.isOfflineCached = false,
  });

  EventEntity copyWith({
    String? id,
    String? title,
    String? clientName,
    String? venueName,
    String? venueAddress,
    double? venueLat,
    double? venueLng,
    int? geofenceRadiusMeters,
    DateTime? eventDate,
    bool? isOfflineCached,
  }) {
    return EventEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      clientName: clientName ?? this.clientName,
      venueName: venueName ?? this.venueName,
      venueAddress: venueAddress ?? this.venueAddress,
      venueLat: venueLat ?? this.venueLat,
      venueLng: venueLng ?? this.venueLng,
      geofenceRadiusMeters: geofenceRadiusMeters ?? this.geofenceRadiusMeters,
      eventDate: eventDate ?? this.eventDate,
      isOfflineCached: isOfflineCached ?? this.isOfflineCached,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
