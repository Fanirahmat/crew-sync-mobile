import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/attendance_model.dart';

abstract class AttendanceRemoteDataSource {
  Future<AttendanceModel> submitAttendance({
    required String eventId,
    required String type,
    required String method,
    required double clientLat,
    required double clientLng,
    required int clientDistanceMeters,
    required bool isWithinGeofence,
    String? photoPath,
    String? biometricTokenRef,
  });

  Future<List<AttendanceModel>> getAttendanceHistory(String eventId);
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final DioClient _client;

  AttendanceRemoteDataSourceImpl(this._client);

  @override
  Future<AttendanceModel> submitAttendance({
    required String eventId,
    required String type,
    required String method,
    required double clientLat,
    required double clientLng,
    required int clientDistanceMeters,
    required bool isWithinGeofence,
    String? photoPath,
    String? biometricTokenRef,
  }) async {
    final Map<String, dynamic> map = {
      'type': type,
      'method': method,
      'clientLat': clientLat,
      'clientLng': clientLng,
      'clientDistanceMeters': clientDistanceMeters,
      'isWithinGeofence': isWithinGeofence,
    };

    if (method == 'BIOMETRIC') {
      map['biometricTokenRef'] = biometricTokenRef ?? 'local_auth_verified_ok';
    } else if (method == 'PHOTO' && photoPath != null) {
      map['photo'] = await MultipartFile.fromFile(
        photoPath,
        filename: 'attendance_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
    }

    final formData = FormData.fromMap(map);

    final response = await _client.post(
      '/events/$eventId/attendances',
      data: formData,
    );

    final data = response.data;
    final json = data is Map && data['data'] is Map ? data['data'] : (data is Map ? data : {});
    return AttendanceModel.fromJson(Map<String, dynamic>.from(json as Map));
  }

  @override
  Future<List<AttendanceModel>> getAttendanceHistory(String eventId) async {
    final response = await _client.get('/events/$eventId/attendances');
    final data = response.data;
    List list = [];
    if (data is List) {
      list = data;
    } else if (data is Map && data['data'] is List) {
      list = data['data'] as List;
    }
    return list.map((item) => AttendanceModel.fromJson(Map<String, dynamic>.from(item as Map))).toList();
  }
}
