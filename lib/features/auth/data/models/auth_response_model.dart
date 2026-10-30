import 'user_model.dart';

/// Response payload received after successful authentication.
class AuthResponseModel {
  final String token;
  final UserModel user;
  final int? expiresIn;

  const AuthResponseModel({
    required this.token,
    required this.user,
    this.expiresIn,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    // Supports nested { "data": { "token": "...", "user": {...} } } or flat
    final target = json['data'] is Map<String, dynamic> ? json['data'] : json;

    return AuthResponseModel(
      token: target['token']?.toString() ?? target['access_token']?.toString() ?? '',
      user: UserModel.fromJson(
        Map<String, dynamic>.from(target['user'] as Map? ?? {}),
      ),
      expiresIn: target['expiresIn'] as int? ?? target['expires_in'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
      'expiresIn': expiresIn,
    };
  }
}
