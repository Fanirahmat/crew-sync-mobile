import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';

/// Centralized local storage service using Hive.
/// Manages auth sessions, cached events, and offline rundowns.
class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  bool _isInitialized = false;

  /// Initialize Hive Flutter and open foundational boxes.
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      await Hive.initFlutter();

      // Open primary boxes
      await Hive.openBox(AppConstants.authBox);
      await Hive.openBox(AppConstants.eventsBox);
      await Hive.openBox(AppConstants.rundownsBox);
      await Hive.openBox(AppConstants.logisticsBox);

      _isInitialized = true;
      if (kDebugMode) {
        debugPrint('[HiveService] Hive initialized and core boxes opened successfully.');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[HiveService] Initialization error: $e');
      }
      throw CacheException('Gagal menginisialisasi penyimpanan lokal Hive: $e');
    }
  }

  Box get _authBox => Hive.box(AppConstants.authBox);
  Box get _eventsBox => Hive.box(AppConstants.eventsBox);
  Box get _rundownsBox => Hive.box(AppConstants.rundownsBox);
  Box get _logisticsBox => Hive.box(AppConstants.logisticsBox);

  // -------------------------------------------------------------
  // Auth & Session Storage
  // -------------------------------------------------------------

  Future<void> saveToken(String token) async {
    await _authBox.put(AppConstants.tokenKey, token);
  }

  String? getToken() {
    return _authBox.get(AppConstants.tokenKey) as String?;
  }

  bool get hasValidToken => getToken() != null && getToken()!.isNotEmpty;

  Future<void> saveUser(Map<String, dynamic> userMap) async {
    await _authBox.put(AppConstants.userKey, userMap);
  }

  Map<String, dynamic>? getUser() {
    final raw = _authBox.get(AppConstants.userKey);
    if (raw == null) return null;
    return Map<String, dynamic>.from(raw as Map);
  }

  Future<void> saveFcmToken(String fcmToken) async {
    await _authBox.put(AppConstants.fcmTokenKey, fcmToken);
  }

  String? getFcmToken() {
    return _authBox.get(AppConstants.fcmTokenKey) as String?;
  }

  Future<void> clearAuthSession() async {
    await _authBox.delete(AppConstants.tokenKey);
    await _authBox.delete(AppConstants.userKey);
  }

  // -------------------------------------------------------------
  // Offline Events & Rundowns Cache
  // -------------------------------------------------------------

  Box get eventsBox => _eventsBox;
  Box get rundownsBox => _rundownsBox;
  Box get logisticsBox => _logisticsBox;

  Future<void> cacheEvents(List<Map<String, dynamic>> eventsList) async {
    await _eventsBox.put('active_events', eventsList);
  }

  List<Map<String, dynamic>>? getCachedEvents() {
    final raw = _eventsBox.get('active_events');
    if (raw == null) return null;
    return (raw as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> cacheRundown(String eventId, List<Map<String, dynamic>> items) async {
    await _rundownsBox.put('rundown_$eventId', items);
  }

  List<Map<String, dynamic>>? getCachedRundown(String eventId) {
    final raw = _rundownsBox.get('rundown_$eventId');
    if (raw == null) return null;
    return (raw as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> clearAllCache() async {
    await _eventsBox.clear();
    await _rundownsBox.clear();
    await _logisticsBox.clear();
  }
}
