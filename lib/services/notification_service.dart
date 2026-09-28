import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';

/// Fired when the user taps a push notification that carries an offer id.
/// HomeScreen listens to this notifier and opens the offer detail screen.
final ValueNotifier<String?> pendingOfferIdNotifier = ValueNotifier<String?>(null);

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // The background isolate must not touch Flutter/Supabase widgets.
  // The notification is rendered by the OS; tapping it wakes the app and
  // onMessageOpenedApp / getInitialMessage take care of navigation.
}

class NotificationService {
  NotificationService._();

  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static bool _initialized = false;

  /// Whether the app is set up for push notifications (Firebase env keys exist).
  static bool get isEnabled => _initialized;

  static FirebaseOptions? _buildOptions() {
    final apiKey = AppConfig.firebaseApiKey;
    final appId = AppConfig.firebaseAppId;
    final messagingSenderId = AppConfig.firebaseMessagingSenderId;
    final projectId = AppConfig.firebaseProjectId;

    if (apiKey.isEmpty ||
        appId.isEmpty ||
        messagingSenderId.isEmpty ||
        projectId.isEmpty) {
      return null;
    }

    return FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
    );
  }

  /// Initializes Firebase for push notifications. Must be called once at
  /// startup (after dotenv is loaded). Fails silently when Firebase keys are
  /// missing so the rest of the app keeps working without push.
  static Future<void> init() async {
    if (_initialized || kIsWeb) {
      return;
    }
    final options = _buildOptions();
    if (options == null) {
      return;
    }

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(options: options);
      }
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      _initialized = true;
    } catch (error) {
      debugPrint('FCM init failed: $error');
    }
  }

  /// Requests permission (Android 13+), enables foreground presentation and
  /// registers the message listeners. Call after the user is signed in.
  static Future<void> setup() async {
    if (!_initialized || kIsWeb) {
      return;
    }

    final messaging = FirebaseMessaging.instance;
    try {
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('Notification permission: ${settings.authorizationStatus}');
    } catch (error) {
      debugPrint('requestPermission failed: $error');
    }

    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onOpenedApp);

    // Handle a notification that launched the app from a terminated state.
    await _handleInitialMessage();
  }

  static void _onForegroundMessage(RemoteMessage message) {
    final title = message.notification?.title ?? 'MTA';
    final body = message.notification?.body ?? '';
    messengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(body.isEmpty ? title : '$title\n$body'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
  }

  static void _onOpenedApp(RemoteMessage message) {
    final offerId = message.data['offer_id'];
    if (offerId is String && offerId.isNotEmpty) {
      pendingOfferIdNotifier.value = offerId;
    }
  }

  static Future<void> _handleInitialMessage() async {
    try {
      final message = await FirebaseMessaging.instance.getInitialMessage();
      if (message != null) {
        _onOpenedApp(message);
      }
    } catch (error) {
      debugPrint('getInitialMessage failed: $error');
    }
  }

  /// Registers this device token against the signed-in user.
  /// Called every time the home screen is opened; the upsert is idempotent.
  static Future<void> refreshToken() async {
    if (!_initialized || kIsWeb) {
      return;
    }
    try {
      final messaging = FirebaseMessaging.instance;
      final token = await messaging.getToken();
      if (token == null || token.isEmpty) {
        return;
      }
      await Supabase.instance.client.rpc('upsert_device_token', params: {
        'p_token': token,
        'p_platform': 'android',
      });
    } catch (error) {
      debugPrint('Token registration failed: $error');
    }
  }

  /// Removes this device token when the user signs out so notifications are
  /// not delivered to the wrong account on shared devices.
  static Future<void> clearToken() async {
    if (!_initialized || kIsWeb) {
      return;
    }
    try {
      final messaging = FirebaseMessaging.instance;
      final token = await messaging.getToken();
      if (token == null || token.isEmpty) {
        return;
      }
      await Supabase.instance.client
          .rpc('delete_device_token', params: {'p_token': token});
    } catch (error) {
      debugPrint('Token removal failed: $error');
    }
  }

  /// Requests the push-notification edge function to notify the parties
  /// involved in [offerId] about [event]. The function resolves the target
  /// users server-side. Failures are swallowed so the workflow is never
  /// blocked by notification problems.
  static Future<void> notifyOfferEvent(
    String offerId,
    String event, {
    Map<String, dynamic> extra = const {},
  }) async {
    try {
      await Supabase.instance.client.functions.invoke('push-notification', body: {
        'offer_id': offerId,
        'event': event,
        ...extra,
      });
    } catch (error) {
      debugPrint('push-notification invoke failed: $error');
    }
  }
}
