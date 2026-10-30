import 'package:flutter_test/flutter_test.dart';
import 'package:crewsync_mobile/core/utils/geofence_calculator.dart';

void main() {
  group('GeofenceCalculator Tests', () {
    const venueLat = -6.2195;
    const venueLng = 106.8000;

    test('should calculate distance within radius correctly', () {
      // Coordinate very close to venue (~10 meters away)
      const clientLat = -6.21958;
      const clientLng = 106.80005;

      final distance = GeofenceCalculator.calculateDistance(
        startLatitude: clientLat,
        startLongitude: clientLng,
        endLatitude: venueLat,
        endLongitude: venueLng,
      );

      expect(distance, lessThan(30));
      expect(GeofenceCalculator.isWithinRadius(distanceMeters: distance, allowedRadiusMeters: 100), isTrue);
    });

    test('should identify coordinates outside radius correctly', () {
      // Coordinate ~1 km away
      const clientLat = -6.2300;
      const clientLng = 106.8100;

      final distance = GeofenceCalculator.calculateDistance(
        startLatitude: clientLat,
        startLongitude: clientLng,
        endLatitude: venueLat,
        endLongitude: venueLng,
      );

      expect(distance, greaterThan(100));
      expect(GeofenceCalculator.isWithinRadius(distanceMeters: distance, allowedRadiusMeters: 100), isFalse);
    });

    test('should format distance into human readable string', () {
      expect(GeofenceCalculator.formatDistance(8.2), '8 meter');
      expect(GeofenceCalculator.formatDistance(1500), '1.5 km');
    });
  });
}
