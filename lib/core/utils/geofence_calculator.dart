import 'package:geolocator/geolocator.dart';

/// Pure utility to calculate distance between client coordinates and venue
/// and evaluate geofence boundary compliance.
class GeofenceCalculator {
  GeofenceCalculator._();

  /// Computes distance in meters between user position and venue
  static double calculateDistance({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Checks if the calculated distance is strictly within allowed radius
  static bool isWithinRadius({
    required double distanceMeters,
    required int allowedRadiusMeters,
  }) {
    return distanceMeters <= allowedRadiusMeters;
  }

  /// Formats distance into clean human-readable text
  static String formatDistance(double distanceMeters) {
    if (distanceMeters < 1000) {
      return '${distanceMeters.round()} meter';
    } else {
      final km = (distanceMeters / 1000).toStringAsFixed(1);
      return '$km km';
    }
  }
}
