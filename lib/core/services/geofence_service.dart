import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../errors/exceptions.dart';
import '../utils/geofence_calculator.dart';

/// Result object encapsulating client coordinate reading and geofence verification.
class GeofenceStatusResult {
  final double clientLat;
  final double clientLng;
  final double distanceMeters;
  final bool isWithinGeofence;
  final int allowedRadiusMeters;
  final String? errorMessage;

  const GeofenceStatusResult({
    required this.clientLat,
    required this.clientLng,
    required this.distanceMeters,
    required this.isWithinGeofence,
    required this.allowedRadiusMeters,
    this.errorMessage,
  });

  factory GeofenceStatusResult.error({
    required String message,
    required int allowedRadiusMeters,
  }) {
    return GeofenceStatusResult(
      clientLat: 0.0,
      clientLng: 0.0,
      distanceMeters: 999999.0,
      isWithinGeofence: false,
      allowedRadiusMeters: allowedRadiusMeters,
      errorMessage: message,
    );
  }
}

/// On-demand Geolocation & Geofence Service.
/// Note: Only queried when crew opens the attendance sheet to conserve battery.
class GeofenceService {
  /// Evaluates whether the crew's current GPS location is within the venue's radius.
  Future<GeofenceStatusResult> evaluateGeofence({
    required double venueLat,
    required double venueLng,
    required int allowedRadiusMeters,
  }) async {
    try {
      // 1. Check if location services are enabled
      final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        throw const GeofenceException(
          'Layanan GPS perangkat belum aktif. Mohon aktifkan GPS pada perangkat Anda.',
        );
      }

      // 2. Check and request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw const GeofenceException(
            'Izin akses lokasi ditolak. Aplikasi membutuhkan lokasi untuk memverifikasi kehadiran di venue.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw const GeofenceException(
          'Izin lokasi ditolak permanen. Silakan aktifkan izin lokasi melalui Pengaturan Aplikasi.',
        );
      }

      // 3. Acquire current coordinates with high accuracy
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      // 4. Compute distance locally
      final distance = GeofenceCalculator.calculateDistance(
        startLatitude: position.latitude,
        startLongitude: position.longitude,
        endLatitude: venueLat,
        endLongitude: venueLng,
      );

      final isWithin = GeofenceCalculator.isWithinRadius(
        distanceMeters: distance,
        allowedRadiusMeters: allowedRadiusMeters,
      );

      if (kDebugMode) {
        debugPrint(
          '[GeofenceService] GPS: (${position.latitude}, ${position.longitude}) | Venue: ($venueLat, $venueLng) | Distance: ${distance.round()}m | Within: $isWithin',
        );
      }

      return GeofenceStatusResult(
        clientLat: position.latitude,
        clientLng: position.longitude,
        distanceMeters: distance,
        isWithinGeofence: isWithin,
        allowedRadiusMeters: allowedRadiusMeters,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[GeofenceService] Error evaluating geofence: $e');
      }
      return GeofenceStatusResult.error(
        message: e is GeofenceException ? e.message : 'Gagal memperoleh koordinat GPS perangkat ($e).',
        allowedRadiusMeters: allowedRadiusMeters,
      );
    }
  }
}
