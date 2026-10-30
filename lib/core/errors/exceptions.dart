/// Base class for all application exceptions
class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, [this.statusCode]);

  @override
  String toString() => 'AppException: $message (Status: $statusCode)';
}

class ServerException extends AppException {
  const ServerException(super.message, [super.statusCode]);
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Koneksi internet bermasalah. Periksa jaringan Anda.']);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([String message = 'Sesi Anda telah kedaluwarsa. Silakan masuk kembali.'])
      : super(message, 401);
}

class CacheException extends AppException {
  const CacheException([super.message = 'Gagal membaca atau menyimpan data lokal.']);
}

class GeofenceException extends AppException {
  const GeofenceException(super.message);
}

class BiometricException extends AppException {
  const BiometricException(super.message);
}
