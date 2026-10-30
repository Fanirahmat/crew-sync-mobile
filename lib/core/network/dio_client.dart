import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../storage/hive_service.dart';
import 'auth_interceptor.dart';
import 'error_interceptor.dart';

/// Centralized HTTP client wrapper around Dio.
/// Enforces timeouts, bearer token injection, error mapping, and logging.
class DioClient {
  final Dio _dio;
  final HiveService _storage;
  final AuthInterceptor _authInterceptor;

  DioClient({
    String? baseUrl,
    HiveService? storage,
    VoidCallback? onUnauthorized,
  })  : _storage = storage ?? HiveService(),
        _authInterceptor = AuthInterceptor(
          storage ?? HiveService(),
          onUnauthorized: onUnauthorized,
        ),
        _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl ?? AppConstants.defaultBaseUrl,
            connectTimeout: AppConstants.connectTimeout,
            receiveTimeout: AppConstants.receiveTimeout,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    _dio.interceptors.addAll([
      _authInterceptor,
      ErrorInterceptor(),
      if (kDebugMode)
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          logPrint: (obj) => debugPrint('[DioClient] $obj'),
        ),
    ]);
  }

  Dio get dio => _dio;
  HiveService get storage => _storage;

  void setOnUnauthorizedCallback(VoidCallback callback) {
    _authInterceptor.onUnauthorized = callback;
  }

  String _cleanPath(String path) {
    if (path.startsWith('/api/v1')) return path;
    if (path.startsWith('/')) return '/api/v1$path';
    return '/api/v1/$path';
  }

  // GET
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.get<T>(
      _cleanPath(path),
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  // POST
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    Options? effectiveOptions = options;
    if (data is FormData) {
      effectiveOptions = (options ?? Options()).copyWith(
        contentType: 'multipart/form-data',
      );
    }
    return _dio.post<T>(
      _cleanPath(path),
      data: data,
      queryParameters: queryParameters,
      options: effectiveOptions,
      cancelToken: cancelToken,
    );
  }

  // PUT
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    Options? effectiveOptions = options;
    if (data is FormData) {
      effectiveOptions = (options ?? Options()).copyWith(
        contentType: 'multipart/form-data',
      );
    }
    return _dio.put<T>(
      _cleanPath(path),
      data: data,
      queryParameters: queryParameters,
      options: effectiveOptions,
      cancelToken: cancelToken,
    );
  }

  // PATCH
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    Options? effectiveOptions = options;
    if (data is FormData) {
      effectiveOptions = (options ?? Options()).copyWith(
        contentType: 'multipart/form-data',
      );
    }
    return _dio.patch<T>(
      _cleanPath(path),
      data: data,
      queryParameters: queryParameters,
      options: effectiveOptions,
      cancelToken: cancelToken,
    );
  }

  // DELETE
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.delete<T>(
      _cleanPath(path),
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
}
