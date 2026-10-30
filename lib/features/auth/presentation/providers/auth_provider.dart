import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/hive_service.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

// Foundation Dependency Providers
final dioClientProvider = Provider<DioClient>((ref) {
  final client = DioClient();
  return client;
});

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl(HiveService());
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.watch(dioClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    localDataSource: ref.watch(authLocalDataSourceProvider),
  );
});

/// Riverpod AsyncNotifier managing the authenticated user state.
class AuthController extends AsyncNotifier<UserEntity?> {
  @override
  Future<UserEntity?> build() async {
    final dioClient = ref.watch(dioClientProvider);
    // Wire auto-logout on 401
    dioClient.setOnUnauthorizedCallback(() {
      state = const AsyncValue.data(null);
    });

    final repo = ref.watch(authRepositoryProvider);
    if (repo.hasActiveSession()) {
      return await repo.getCurrentUser();
    }
    return null;
  }

  /// Attempts login with identifier (WhatsApp or Email) and password
  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = await ref.read(authRepositoryProvider).login(
            identifier: identifier,
            password: password,
          );
      return user;
    });
  }

  /// Logs out user and resets state to null
  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await ref.read(authRepositoryProvider).logout();
    } finally {
      state = const AsyncValue.data(null);
    }
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, UserEntity?>(AuthController.new);
