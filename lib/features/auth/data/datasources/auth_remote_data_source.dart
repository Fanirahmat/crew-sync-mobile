import '../../../../core/network/dio_client.dart';
import '../models/auth_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login({
    required String identifier,
    required String password,
  });

  Future<void> registerFcmToken(String fcmToken);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _client;

  AuthRemoteDataSourceImpl(this._client);

  @override
  Future<AuthResponseModel> login({
    required String identifier,
    required String password,
  }) async {
    final response = await _client.post(
      '/auth/login',
      data: {
        'identifier': identifier.trim(),
        'password': password,
      },
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return AuthResponseModel.fromJson(data);
    }
    throw Exception('Format respon login tidak valid.');
  }

  @override
  Future<void> registerFcmToken(String fcmToken) async {
    await _client.post(
      '/auth/fcm-token',
      data: {
        'fcmToken': fcmToken,
        'platform': 'mobile',
      },
    );
  }

  @override
  Future<void> logout() async {
    try {
      await _client.post('/auth/logout');
    } catch (_) {
      // Ignore network errors on logout to allow local session clearing
    }
  }
}
