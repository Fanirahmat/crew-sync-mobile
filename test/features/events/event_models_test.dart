import 'package:flutter_test/flutter_test.dart';
import 'package:crewsync_mobile/features/events/data/models/event_model.dart';
import 'package:crewsync_mobile/features/events/data/models/rundown_item_model.dart';
import 'package:crewsync_mobile/features/events/domain/entities/rundown_item_entity.dart';

void main() {
  group('EventModel & RundownItemModel serialization', () {
    test('EventModel should parse from and serialize to JSON correctly', () {
      final jsonMap = {
        'id': 'evt_1',
        'title': 'Pernikahan Rian & Sasa',
        'clientName': 'Rian & Sasa',
        'venueName': 'Grand Ballroom Hotel Mulia',
        'venueAddress': 'Jl. Asia Afrika',
        'venueLat': -6.2195,
        'venueLng': 106.8000,
        'geofenceRadiusMeters': 100,
        'eventDate': '2026-10-11T08:00:00.000',
        'isOfflineCached': false,
      };

      final model = EventModel.fromJson(jsonMap);
      expect(model.id, 'evt_1');
      expect(model.title, 'Pernikahan Rian & Sasa');
      expect(model.venueLat, -6.2195);
      expect(model.geofenceRadiusMeters, 100);

      final serialized = model.toJson();
      expect(serialized['id'], 'evt_1');
      expect(serialized['venueName'], 'Grand Ballroom Hotel Mulia');
    });

    test('RundownItemModel should handle status strings properly', () {
      final activeJson = {
        'id': 'rd_2',
        'eventId': 'evt_1',
        'title': 'Akad Nikah',
        'description': 'Prosesi ijab kabul',
        'startTime': '2026-10-11T08:00:00.000',
        'endTime': '2026-10-11T09:00:00.000',
        'zone': 'Ruang Utama',
        'picName': 'Budi',
        'picRole': 'Stage Manager',
        'status': 'ACTIVE',
        'orderIndex': 2,
      };

      final item = RundownItemModel.fromJson(activeJson);
      expect(item.status, RundownStatus.active);
      expect(item.status.toDisplayBadge(), 'SEDANG BERLANGSUNG');
      expect(item.zone, 'Ruang Utama');
      expect(item.picName, 'Budi');

      final serialized = item.toJson();
      expect(serialized['status'], 'ACTIVE');
    });
  });
}
