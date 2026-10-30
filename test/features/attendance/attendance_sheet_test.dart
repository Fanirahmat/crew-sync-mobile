import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crewsync_mobile/core/services/geofence_service.dart';
import 'package:crewsync_mobile/features/attendance/presentation/providers/attendance_providers.dart';
import 'package:crewsync_mobile/features/attendance/presentation/sheets/attendance_bottom_sheet.dart';
import 'package:crewsync_mobile/features/events/domain/entities/event_entity.dart';

void main() {
  final testEvent = EventEntity(
    id: 'evt_wedding_rian_sasa',
    title: 'Pernikahan Rian & Sasa',
    clientName: 'Rian & Sasa',
    venueName: 'Grand Ballroom Hotel Mulia',
    venueAddress: 'Senayan, Jakarta',
    venueLat: -6.2195,
    venueLng: 106.8000,
    geofenceRadiusMeters: 100,
    eventDate: DateTime(2026, 10, 11),
    isOfflineCached: true,
  );

  testWidgets('AttendanceBottomSheet displays radar status and dual verification options', (tester) async {
    const verifiedGeofence = GeofenceStatusResult(
      clientLat: -6.21952,
      clientLng: 106.80002,
      distanceMeters: 8.0,
      isWithinGeofence: true,
      allowedRadiusMeters: 100,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          geofenceEvaluationProvider(testEvent).overrideWith(
            (_) async => verifiedGeofence,
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: AttendanceBottomSheet(event: testEvent),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify title and header
    expect(find.text('Presensi Lapangan'), findsOneWidget);
    expect(find.text('Tiba di Venue (In)'), findsOneWidget);
    expect(find.text('Selesai Shift (Out)'), findsOneWidget);

    // Verify Geofence Radar Card
    expect(find.text('Lokasi Terverifikasi'), findsOneWidget);
    expect(find.text('Di Dalam Radius ✓'), findsOneWidget);
    expect(find.text('Jarak Anda: 8 meter dari venue (Maks. radius: 100m)'), findsOneWidget);

    // Verify Dual Verification Options
    expect(find.text('PILIH METODE VERIFIKASI'), findsOneWidget);
    expect(find.text('Presensi Biometrik'), findsOneWidget);
    expect(find.text('Gunakan sidik jari atau Face ID perangkat'), findsOneWidget);
    expect(find.text('Presensi Swafoto'), findsOneWidget);
    expect(find.text('Ambil foto diri di area venue'), findsOneWidget);
  });
}
