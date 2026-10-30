import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crewsync_mobile/features/events/domain/entities/event_entity.dart';
import 'package:crewsync_mobile/features/logistics/domain/entities/checklist_item_entity.dart';
import 'package:crewsync_mobile/features/logistics/presentation/providers/logistics_providers.dart';
import 'package:crewsync_mobile/features/logistics/presentation/screens/logistics_screen.dart';

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

  final testItems = [
    const ChecklistItemEntity(
      id: 'chk_1',
      eventId: 'evt_wedding_rian_sasa',
      stage: ChecklistStage.loadIn,
      itemName: 'HT Motorola GP328',
      targetQuantity: 10,
      actualQuantity: 10,
      unit: 'Unit',
      condition: ItemCondition.good,
      verifiedBy: 'Dimas',
      isVerified: true,
    ),
    const ChecklistItemEntity(
      id: 'chk_2',
      eventId: 'evt_wedding_rian_sasa',
      stage: ChecklistStage.loadIn,
      itemName: 'Kabel Roll 50m',
      targetQuantity: 4,
      actualQuantity: 3,
      unit: 'Unit',
      condition: ItemCondition.good,
      isVerified: false,
    ),
    const ChecklistItemEntity(
      id: 'chk_3',
      eventId: 'evt_wedding_rian_sasa',
      stage: ChecklistStage.loadOut,
      itemName: 'Lighting Bar LED',
      targetQuantity: 8,
      actualQuantity: 0,
      unit: 'Unit',
      condition: ItemCondition.good,
      isVerified: false,
    ),
  ];

  testWidgets('LogisticsScreen renders tabs, progress header, and items', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          logisticsNotifierProvider(testEvent.id).overrideWith(
            () => _FakeLogisticsNotifier(testEvent.id, testItems),
          ),
        ],
        child: MaterialApp(
          home: LogisticsScreen(event: testEvent),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Tab headers
    expect(find.text('Load-In'), findsOneWidget);
    expect(find.text('Load-Out'), findsOneWidget);
    expect(find.text('Pasca Acara'), findsOneWidget);

    // Verify Progress Summary (1 of 2 verified for Load-In = 50%)
    expect(find.text('1 dari 2 Barang Terverifikasi (50%)'), findsOneWidget);

    // Verify Verified Item Card 1
    expect(find.text('HT Motorola GP328 (10 Unit)'), findsOneWidget);
    expect(find.text('Dicek oleh Dimas • Fisik: Baik'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

    // Verify Unverified Item Card 2
    expect(find.text('Kabel Roll 50m (4 Unit)'), findsOneWidget);
    expect(find.text('Target: 4 Unit'), findsOneWidget);
    expect(find.text('Baik'), findsOneWidget);
    expect(find.text('Rusak'), findsOneWidget);
    expect(find.text('Hilang'), findsOneWidget);
    expect(find.text('Verifikasi'), findsOneWidget);

    // Tap Load-Out Tab
    await tester.tap(find.text('Load-Out'));
    await tester.pumpAndSettle();

    // Verify Load-Out items
    expect(find.text('Lighting Bar LED (8 Unit)'), findsOneWidget);
    expect(find.text('0 dari 1 Barang Terverifikasi (0%)'), findsOneWidget);
  });
}

class _FakeLogisticsNotifier extends LogisticsNotifier {
  final List<ChecklistItemEntity> _data;
  _FakeLogisticsNotifier(super.eventId, this._data);

  @override
  Future<List<ChecklistItemEntity>> build() async {
    return _data;
  }
}
