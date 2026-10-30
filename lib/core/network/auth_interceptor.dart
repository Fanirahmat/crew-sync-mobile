import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/hive_service.dart';

typedef VoidCallback = void Function();

/// Dio Interceptor that automatically attaches Bearer tokens to requests
/// and handles 401 Unauthorized responses to trigger automatic logout.
class AuthInterceptor extends QueuedInterceptor {
  final HiveService _storage;
  VoidCallback? onUnauthorized;

  AuthInterceptor(this._storage, {this.onUnauthorized});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Check if token exists in local storage
    final token = _storage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Set common json headers
    options.headers['Accept'] = 'application/json';

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      if (kDebugMode) {
        debugPrint('[AuthInterceptor] 401 Unauthorized detected. Clearing session.');
      }
      _storage.clearAuthSession();
      onUnauthorized?.call();
    }
    return handler.next(err);
  }
}
