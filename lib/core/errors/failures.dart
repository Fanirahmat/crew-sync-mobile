/// Base failure representation for domain layer
abstract class Failure {
  final String message;
  final int? statusCode;

  const Failure(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, [super.statusCode]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Tidak dapat terhubung ke server. Mode offline aktif.']);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, [super.statusCode]);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Gagal mengakses data offline.']);
}

class GeofenceFailure extends Failure {
  const GeofenceFailure(super.message);
}

class BiometricFailure extends Failure {
  const BiometricFailure(super.message);
}
