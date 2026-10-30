import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import '../errors/exceptions.dart';

/// Service managing device biometric hardware (Fingerprint, TouchID, FaceID).
class BiometricService {
  final LocalAuthentication _auth;

  BiometricService({LocalAuthentication? auth})
      : _auth = auth ?? LocalAuthentication();

  /// Checks if the device has biometric hardware and enrolled biometrics
  Future<bool> isBiometricsAvailable() async {
    try {
      final isSupported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      return isSupported && canCheck;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[BiometricService] Availability check failed: $e');
      }
      return false;
    }
  }

  /// Prompts native fingerprint or FaceID dialog
  Future<bool> authenticate({
    String localizedReason = 'Pindai sidik jari atau Face ID untuk verifikasi kehadiran kru',
  }) async {
    try {
      final available = await isBiometricsAvailable();
      if (!available) {
        throw const BiometricException(
          'Perangkat tidak mendukung biometrik atau belum ada sidik jari/Face ID yang didaftarkan.',
        );
      }

      final authenticated = await _auth.authenticate(
        localizedReason: localizedReason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );

      return authenticated;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[BiometricService] Authentication failed: $e');
      }
      if (e is BiometricException) rethrow;
      throw BiometricException('Autentikasi biometrik gagal atau dibatalkan ($e).');
    }
  }
}
