import '../../domain/entities/rundown_item_entity.dart';

/// Data model representing a rundown timeline item with JSON & Hive Map serialization.
class RundownItemModel extends RundownItemEntity {
  const RundownItemModel({
    required super.id,
    required super.eventId,
    required super.title,
    super.description,
    required super.startTime,
    required super.endTime,
    required super.zone,
    required super.picName,
    super.picRole,
    required super.status,
    required super.orderIndex,
  });

  factory RundownItemModel.fromJson(Map<String, dynamic> json) {
    return RundownItemModel(
      id: json['id']?.toString() ?? '',
      eventId: json['eventId']?.toString() ?? json['event_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      startTime: json['startTime'] != null
          ? DateTime.tryParse(json['startTime'].toString()) ?? DateTime.now()
          : (json['start_time'] != null
              ? DateTime.tryParse(json['start_time'].toString()) ?? DateTime.now()
              : DateTime.now()),
      endTime: json['endTime'] != null
          ? DateTime.tryParse(json['endTime'].toString()) ?? DateTime.now()
          : (json['end_time'] != null
              ? DateTime.tryParse(json['end_time'].toString()) ?? DateTime.now()
              : DateTime.now()),
      zone: json['zone']?.toString() ?? json['locationSection']?.toString() ?? json['location']?.toString() ?? 'Venue',
      picName: json['picUser'] is Map
          ? (json['picUser']['fullName']?.toString() ?? 'Koordinator')
          : (json['picName']?.toString() ?? json['pic_name']?.toString() ?? 'Koordinator'),
      picRole: json['picRole']?.toString() ?? json['pic_role']?.toString(),
      status: RundownStatus.fromString(json['status']?.toString()),
      orderIndex: int.tryParse((json['orderIndex'] ?? json['order_index'] ?? 0).toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'zone': zone,
      'picName': picName,
      'picRole': picRole,
      'status': status.toApiString(),
      'orderIndex': orderIndex,
    };
  }

  factory RundownItemModel.fromEntity(RundownItemEntity entity) {
    return RundownItemModel(
      id: entity.id,
      eventId: entity.eventId,
      title: entity.title,
      description: entity.description,
      startTime: entity.startTime,
      endTime: entity.endTime,
      zone: entity.zone,
      picName: entity.picName,
      picRole: entity.picRole,
      status: entity.status,
      orderIndex: entity.orderIndex,
    );
  }
}
