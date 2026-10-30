import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crewsync_mobile/features/events/domain/entities/event_entity.dart';
import 'package:crewsync_mobile/features/events/domain/entities/rundown_item_entity.dart';
import 'package:crewsync_mobile/features/events/presentation/providers/event_providers.dart';
import 'package:crewsync_mobile/features/events/presentation/screens/rundown_timeline_screen.dart';

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

  final testRundown = [
    RundownItemEntity(
      id: 'item_1',
      eventId: 'evt_wedding_rian_sasa',
      title: 'Load-In Sound & HT',
      startTime: DateTime(2026, 10, 11, 7, 0),
      endTime: DateTime(2026, 10, 11, 8, 0),
      zone: 'Foyer',
      picName: 'Andi',
      status: RundownStatus.completed,
      orderIndex: 1,
    ),
    RundownItemEntity(
      id: 'item_2',
      eventId: 'evt_wedding_rian_sasa',
      title: 'Akad Nikah',
      startTime: DateTime(2026, 10, 11, 8, 0),
      endTime: DateTime(2026, 10, 11, 9, 0),
      zone: 'Ruang Utama',
      picName: 'Budi',
      picRole: 'Stage Manager',
      status: RundownStatus.active,
      orderIndex: 2,
    ),
    RundownItemEntity(
      id: 'item_3',
      eventId: 'evt_wedding_rian_sasa',
      title: 'Kirab Pengantin & Masuk Pelaminan',
      startTime: DateTime(2026, 10, 11, 9, 0),
      endTime: DateTime(2026, 10, 11, 10, 0),
      zone: 'Foyer Utama',
      picName: 'Laras',
      status: RundownStatus.pending,
      orderIndex: 3,
    ),
  ];

  testWidgets('RundownTimelineScreen displays timeline items and bottom button', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          rundownNotifierProvider(testEvent.id).overrideWith(
            () => _FakeRundownNotifier(testEvent.id, testRundown),
          ),
        ],
        child: MaterialApp(
          home: RundownTimelineScreen(event: testEvent),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify header details
    expect(find.text('Pernikahan Rian & Sasa'), findsOneWidget);
    expect(find.text('Offline Siap ✓'), findsOneWidget);
    expect(find.text('Grand Ballroom Hotel Mulia'), findsOneWidget);

    // Verify chronological items
    // Item 1 (Finished)
    expect(find.text('Load-In Sound & HT'), findsOneWidget);
    expect(find.text('Selesai'), findsOneWidget);

    // Item 2 (Active Cue)
    expect(find.text('Akad Nikah'), findsOneWidget);
    expect(find.text('SEDANG BERLANGSUNG'), findsOneWidget);
    expect(find.text('Ruang Utama • PIC: Budi (Stage Manager)'), findsOneWidget);

    // Item 3 (Upcoming)
    expect(find.text('Kirab Pengantin & Masuk Pelaminan'), findsOneWidget);
    expect(find.text('Berikutnya'), findsOneWidget);

    // Verify docked quick action button
    expect(find.text('Buka Presensi Hari Ini'), findsOneWidget);
  });
}

class _FakeRundownNotifier extends RundownNotifier {
  final List<RundownItemEntity> _initialData;
  _FakeRundownNotifier(super.eventId, this._initialData);

  @override
  Future<List<RundownItemEntity>> build() async {
    return _initialData;
  }
}
