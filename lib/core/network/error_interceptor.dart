import 'package:dio/dio.dart';
import '../errors/exceptions.dart';

/// Centralized Dio error handling interceptor.
/// Translates low-level network issues and HTTP status codes into domain-friendly exceptions.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppException exception;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        exception = const NetworkException(
          'Waktu koneksi habis. Mohon periksa kembali sinyal di venue acara.',
        );
        break;

      case DioExceptionType.connectionError:
        exception = const NetworkException(
          'Tidak dapat terhubung ke server. Menggunakan mode cache offline.',
        );
        break;

      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        final responseData = err.response?.data;
        String errorMessage = 'Terjadi kesalahan pada server ($statusCode).';

        if (responseData is Map && responseData['message'] != null) {
          errorMessage = responseData['message'].toString();
        }

        if (statusCode == 401) {
          exception = UnauthorizedException(errorMessage);
        } else if (statusCode == 403) {
          exception = ServerException(
            'Akses ditolak: Anda tidak memiliki izin untuk aksi ini.',
            statusCode,
          );
        } else if (statusCode == 404) {
          exception = ServerException(
            'Data atau endpoint tidak ditemukan (404).',
            statusCode,
          );
        } else if (statusCode != null && statusCode >= 500) {
          exception = ServerException(
            'Server mengalami kendala internal ($statusCode). Coba sesaat lagi.',
            statusCode,
          );
        } else {
          exception = ServerException(errorMessage, statusCode);
        }
        break;

      case DioExceptionType.cancel:
        exception = const AppException('Permintaan dibatalkan.');
        break;

      case DioExceptionType.badCertificate:
        exception = const NetworkException('Sertifikat keamanan server tidak valid.');
        break;

      case DioExceptionType.unknown:
        exception = AppException(
          err.message ?? 'Terjadi kesalahan yang tidak terduga.',
        );
        break;
    }

    // Pass custom exception to next handler
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: exception,
        message: exception.message,
      ),
    );
  }
}
