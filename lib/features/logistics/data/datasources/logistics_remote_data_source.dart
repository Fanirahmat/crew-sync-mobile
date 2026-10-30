import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/checklist_item_model.dart';

abstract class LogisticsRemoteDataSource {
  Future<List<ChecklistItemModel>> getChecklist(String eventId);
  Future<ChecklistItemModel> verifyItem({
    required String itemId,
    required int actualQuantity,
    required String condition,
    String? notes,
    File? photoEvidence,
  });
}

class LogisticsRemoteDataSourceImpl implements LogisticsRemoteDataSource {
  final DioClient _client;

  LogisticsRemoteDataSourceImpl(this._client);

  @override
  Future<List<ChecklistItemModel>> getChecklist(String eventId) async {
    final response = await _client.get('/events/$eventId/checklists');
    final data = response.data;

    List rawList = [];
    if (data is List) {
      rawList = data;
    } else if (data is Map && data['data'] is List) {
      rawList = data['data'] as List;
    }

    final List<ChecklistItemModel> items = [];
    for (final element in rawList) {
      if (element is Map && element['items'] is List) {
        final stageStr = element['stage']?.toString();
        for (final subItem in element['items'] as List) {
          if (subItem is Map) {
            final itemMap = Map<String, dynamic>.from(subItem);
            if (stageStr != null && !itemMap.containsKey('stage')) {
              itemMap['stage'] = stageStr;
            }
            if (!itemMap.containsKey('eventId')) {
              itemMap['eventId'] = eventId;
            }
            items.add(ChecklistItemModel.fromJson(itemMap));
          }
        }
      } else if (element is Map) {
        items.add(ChecklistItemModel.fromJson(Map<String, dynamic>.from(element)));
      }
    }

    return items;
  }

  @override
  Future<ChecklistItemModel> verifyItem({
    required String itemId,
    required int actualQuantity,
    required String condition,
    String? notes,
    File? photoEvidence,
  }) async {
    final Map<String, dynamic> map = {
      'quantity_actual': actualQuantity,
      'condition': condition,
      'notes': ?notes,
    };

    if (photoEvidence != null) {
      map['photo'] = await MultipartFile.fromFile(
        photoEvidence.path,
        filename: 'evidence_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
    }

    final formData = FormData.fromMap(map);

    final response = await _client.patch(
      '/checklists/items/$itemId/verify',
      data: formData,
    );

    final data = response.data;
    final json = data is Map && data['data'] is Map ? data['data'] : (data is Map ? data : {});
    return ChecklistItemModel.fromJson(Map<String, dynamic>.from(json as Map));
  }
}
