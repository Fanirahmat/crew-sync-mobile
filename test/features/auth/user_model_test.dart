import 'package:flutter_test/flutter_test.dart';
import 'package:crewsync_mobile/features/auth/data/models/user_model.dart';

void main() {
  group('UserModel Serialization', () {
    const jsonMap = {
      'id': 'usr_123',
      'name': 'Budi Santoso',
      'email': 'budi@crewsync.com',
      'phone': '08123456789',
      'role': 'STAGE_MANAGER',
      'vendorName': 'Kinarya Wedding Organizer',
      'avatarUrl': 'https://crewsync.app/avatar.jpg',
    };

    test('should correctly parse from JSON', () {
      final user = UserModel.fromJson(jsonMap);

      expect(user.id, 'usr_123');
      expect(user.name, 'Budi Santoso');
      expect(user.email, 'budi@crewsync.com');
      expect(user.phone, '08123456789');
      expect(user.role, 'STAGE_MANAGER');
      expect(user.vendorName, 'Kinarya Wedding Organizer');
    });

    test('should correctly serialize to JSON', () {
      final user = UserModel.fromJson(jsonMap);
      final serialized = user.toJson();

      expect(serialized['id'], 'usr_123');
      expect(serialized['name'], 'Budi Santoso');
      expect(serialized['role'], 'STAGE_MANAGER');
      expect(serialized['vendorName'], 'Kinarya Wedding Organizer');
    });
  });
}
