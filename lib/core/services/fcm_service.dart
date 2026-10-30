import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../storage/hive_service.dart';

/// Top-level background message handler required by Firebase Messaging.
/// Must be annotated with @pragma('vm:entry-point') so it can be invoked in background isolates.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized in background isolate
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Already initialized or running in mock/offline mode
  }

  if (kDebugMode) {
    debugPrint('[FCM Background] Received message ID: ${message.messageId}');
    debugPrint('[FCM Background] Data: ${message.data}');
  }
}

/// Service managing Firebase Cloud Messaging token, permissions, topic subscriptions,
/// and live cue dispatching.
class FcmService {
  final HiveService _storage;
  FirebaseMessaging? _fcm;

  FcmService({
    FirebaseMessaging? fcm,
    HiveService? storage,
  })  : _fcm = fcm,
        _storage = storage ?? HiveService();

  FirebaseMessaging? get _fcmInstance {
    if (_fcm != null) return _fcm;
    try {
      if (Firebase.apps.isNotEmpty) {
        _fcm = FirebaseMessaging.instance;
        return _fcm;
      }
    } catch (_) {}
    return null;
  }

  /// Request iOS / Android 13+ notification permissions
  Future<NotificationSettings?> requestPermission() async {
    final client = _fcmInstance;
    if (client == null) {
      if (kDebugMode) {
        debugPrint('[FcmService] Firebase not initialized, skipping notification permission');
      }
      return null;
    }
    try {
      final settings = await client.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: true,
        provisional: false,
        sound: true,
      );

      if (kDebugMode) {
        debugPrint(
          '[FcmService] Permission status: ${settings.authorizationStatus}',
        );
      }
      return settings;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[FcmService] Error requesting notification permissions: $e');
      }
      return null;
    }
  }

  /// Retrieve current FCM device registration token
  Future<String?> getDeviceToken() async {
    final client = _fcmInstance;
    if (client == null) return null;
    try {
      // ignore: deprecated_member_use
      final token = await client.getToken();
      if (token != null) {
        await _storage.saveFcmToken(token);
        if (kDebugMode) {
          debugPrint('[FcmService] FCM Device Token: $token');
        }
      }
      return token;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[FcmService] Failed to get device token: $e');
      }
      return null;
    }
  }

  /// Subscribe to event-specific broadcast topic (e.g. `event_123`)
  Future<void> subscribeToEvent(String eventId) async {
    final client = _fcmInstance;
    if (client == null) return;
    try {
      final topic = 'event_$eventId';
      await client.subscribeToTopic(topic);
      if (kDebugMode) {
        debugPrint('[FcmService] Subscribed to topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[FcmService] Failed to subscribe to topic event_$eventId: $e');
      }
    }
  }

  /// Unsubscribe from event topic
  Future<void> unsubscribeFromEvent(String eventId) async {
    final client = _fcmInstance;
    if (client == null) return;
    try {
      final topic = 'event_$eventId';
      await client.unsubscribeFromTopic(topic);
      if (kDebugMode) {
        debugPrint('[FcmService] Unsubscribed from topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[FcmService] Failed to unsubscribe from topic event_$eventId: $e');
      }
    }
  }

  /// Listen for foreground notification stream
  Stream<RemoteMessage> get onForegroundMessage {
    final client = _fcmInstance;
    if (client == null) return const Stream.empty();
    try {
      return FirebaseMessaging.onMessage;
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// Listen for messages when app is opened from a background state
  Stream<RemoteMessage> get onMessageOpenedApp {
    final client = _fcmInstance;
    if (client == null) return const Stream.empty();
    try {
      return FirebaseMessaging.onMessageOpenedApp;
    } catch (_) {
      return const Stream.empty();
    }
  }
}
