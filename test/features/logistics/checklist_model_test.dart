import 'package:flutter_test/flutter_test.dart';
import 'package:crewsync_mobile/features/logistics/data/models/checklist_item_model.dart';
import 'package:crewsync_mobile/features/logistics/domain/entities/checklist_item_entity.dart';

void main() {
  group('ChecklistItemModel Serialization', () {
    test('should parse from JSON and serialize back accurately', () {
      final jsonMap = {
        'id': 'chk_101',
        'eventId': 'evt_1',
        'stage': 'LOAD_IN',
        'itemName': 'HT Motorola GP328',
        'targetQuantity': 10,
        'actualQuantity': 10,
        'unit': 'Unit',
        'condition': 'GOOD',
        'verifiedBy': 'Dimas',
        'notes': 'Semua batere full',
        'isVerified': true,
      };

      final item = ChecklistItemModel.fromJson(jsonMap);
      expect(item.id, 'chk_101');
      expect(item.stage, ChecklistStage.loadIn);
      expect(item.itemName, 'HT Motorola GP328');
      expect(item.targetQuantity, 10);
      expect(item.actualQuantity, 10);
      expect(item.condition, ItemCondition.good);
      expect(item.verifiedBy, 'Dimas');
      expect(item.isVerified, isTrue);

      final serialized = item.toJson();
      expect(serialized['stage'], 'LOAD_IN');
      expect(serialized['condition'], 'GOOD');
    });

    test('should handle condition and stage string representations', () {
      expect(ChecklistStage.fromString('LOAD_OUT'), ChecklistStage.loadOut);
      expect(ChecklistStage.fromString('POST_EVENT'), ChecklistStage.postEvent);
      expect(ItemCondition.fromString('DAMAGED'), ItemCondition.damaged);
      expect(ItemCondition.fromString('MISSING'), ItemCondition.missing);
    });
  });
}
