import '../../../../core/storage/hive_service.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  String? getToken();
  Future<void> saveUser(UserModel user);
  UserModel? getUser();
  Future<void> clearSession();
  bool hasActiveSession();
  Future<void> saveFcmToken(String token);
  String? getFcmToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final HiveService _storage;

  AuthLocalDataSourceImpl(this._storage);

  @override
  Future<void> saveToken(String token) => _storage.saveToken(token);

  @override
  String? getToken() => _storage.getToken();

  @override
  Future<void> saveUser(UserModel user) => _storage.saveUser(user.toJson());

  @override
  UserModel? getUser() {
    final map = _storage.getUser();
    if (map == null) return null;
    return UserModel.fromJson(map);
  }

  @override
  Future<void> clearSession() => _storage.clearAuthSession();

  @override
  bool hasActiveSession() => _storage.hasValidToken;

  @override
  Future<void> saveFcmToken(String token) => _storage.saveFcmToken(token);

  @override
  String? getFcmToken() => _storage.getFcmToken();
}
