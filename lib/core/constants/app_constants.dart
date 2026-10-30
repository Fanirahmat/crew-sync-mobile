/// Global application constants for CrewSync Mobile
class AppConstants {
  AppConstants._();

  // Application Info
  static const String appName = 'CrewSync';
  static const String appSubtitle = 'CrewSync - Field Ops';

  // Network & API Defaults
  static const String defaultBaseUrl = 'https://crew-sync-backend-production.up.railway.app'; // 
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Hive Box Identifiers
  static const String authBox = 'auth_box';
  static const String eventsBox = 'events_box';
  static const String rundownsBox = 'rundowns_box';
  static const String logisticsBox = 'logistics_box';

  // Secure / Storage Keys
  static const String tokenKey = 'jwt_token';
  static const String userKey = 'cached_user';
  static const String fcmTokenKey = 'fcm_device_token';

  // Geofence Defaults
  static const int defaultGeofenceRadiusMeters = 100;

  // Image Upload Limits
  static const int maxImageUploadSizeKb = 300;
  static const int imageCompressionQuality = 75;
}
