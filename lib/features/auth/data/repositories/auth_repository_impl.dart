import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<UserEntity> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final response = await _remoteDataSource.login(
        identifier: identifier,
        password: password,
      );

      // Save token and user info to local storage
      await _localDataSource.saveToken(response.token);
      await _localDataSource.saveUser(response.user);

      // Opportunistically register device FCM token if available
      final existingFcmToken = _localDataSource.getFcmToken();
      if (existingFcmToken != null) {
        try {
          await _remoteDataSource.registerFcmToken(existingFcmToken);
        } catch (_) {
          // Do not fail login if FCM registration fails
        }
      }

      return response.user;
    } on DioException catch (dioErr) {
      if (dioErr.error is AppException) {
        final appErr = dioErr.error as AppException;
        throw AuthFailure(appErr.message, appErr.statusCode);
      }
      throw AuthFailure(dioErr.message ?? 'Gagal menghubungi server autentikasi.');
    } catch (e) {
      if (e is Failure) rethrow;
      throw AuthFailure('Gagal melakukan login: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } finally {
      await _localDataSource.clearSession();
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    return _localDataSource.getUser();
  }

  @override
  bool hasActiveSession() {
    return _localDataSource.hasActiveSession();
  }

  @override
  Future<void> registerFcmToken(String fcmToken) async {
    await _localDataSource.saveFcmToken(fcmToken);
    if (hasActiveSession()) {
      await _remoteDataSource.registerFcmToken(fcmToken);
    }
  }
}
