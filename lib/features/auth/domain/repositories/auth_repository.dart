import '../entities/user_entity.dart';

/// Contract interface defining authentication and session operations.
abstract class AuthRepository {
  /// Authenticates user using identifier (phone number or email) and password.
  Future<UserEntity> login({
    required String identifier,
    required String password,
  });

  /// Clears local session and notifies backend of session revocation.
  Future<void> logout();

  /// Retrieves currently cached crew user from local storage.
  Future<UserEntity?> getCurrentUser();

  /// Checks if valid JWT exists in local storage.
  bool hasActiveSession();

  /// Sends device FCM token to backend for topic routing and cues.
  Future<void> registerFcmToken(String fcmToken);
}
