import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/services/fcm_service.dart';
import 'core/storage/hive_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Hive local storage
  final hiveService = HiveService();
  await hiveService.init();

  // 2. Initialize Firebase & FCM Background Handler with fallback
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (e) {
    if (kDebugMode) {
      debugPrint('[Main] Firebase initialization bypassed / offline dev mode: $e');
    }
  }

  // 3. Launch application within Riverpod ProviderScope
  runApp(
    const ProviderScope(
      child: CrewSyncApp(),
    ),
  );
}
