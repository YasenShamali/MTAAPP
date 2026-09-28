import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Single source of truth for the app's build-time configuration.
///
/// Values are resolved in this order:
///
/// 1. `.env`, when that file is bundled as an asset. This is convenient for
///    local `flutter run`, but it also means the file is embedded verbatim in
///    the built APK/AAB where anyone can unpack and read it.
/// 2. `--dart-define` / `--dart-define-from-file` values, compiled into the
///    binary. These are not stored as plain files, so this is what release
///    builds should use.
///
/// Release builds should therefore keep `.env` out of `pubspec.yaml` assets and
/// pass the configuration explicitly, for example:
///
///   flutter build apk --release --dart-define-from-file=config/release.json
///
/// The keys resolved here are all public client keys (the Supabase anon key and
/// the Firebase web config). They are safe to ship *because* row level security
/// is what actually protects the data — the real secrets are the Supabase
/// service-role key and the FCM service account, and those live in Edge Function
/// secrets, never in the client.
class AppConfig {
  const AppConfig._();

  /// Compile-time values. `String.fromEnvironment` can only be built from a
  /// const key, so the lookups are declared explicitly rather than dynamically.
  static const Map<String, String> _compiledValues = <String, String>{
    'SUPABASE_URL': String.fromEnvironment('SUPABASE_URL'),
    'SUPABASE_ANON_KEY': String.fromEnvironment('SUPABASE_ANON_KEY'),
    'FIREBASE_API_KEY': String.fromEnvironment('FIREBASE_API_KEY'),
    'FIREBASE_APP_ID': String.fromEnvironment('FIREBASE_APP_ID'),
    'FIREBASE_MESSAGING_SENDER_ID':
        String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
    'FIREBASE_PROJECT_ID': String.fromEnvironment('FIREBASE_PROJECT_ID'),
  };

  static String _read(String key) {
    String? fromAsset;
    try {
      fromAsset = dotenv.env[key]?.trim();
    } on Object {
      // `.env` is not bundled (release builds) — fall through to dart-define.
      fromAsset = null;
    }
    if (fromAsset != null && fromAsset.isNotEmpty) {
      return fromAsset;
    }
    return _compiledValues[key]?.trim() ?? '';
  }

  static String get supabaseUrl => _read('SUPABASE_URL');
  static String get supabaseAnonKey => _read('SUPABASE_ANON_KEY');

  static String get firebaseApiKey => _read('FIREBASE_API_KEY');
  static String get firebaseAppId => _read('FIREBASE_APP_ID');
  static String get firebaseMessagingSenderId =>
      _read('FIREBASE_MESSAGING_SENDER_ID');
  static String get firebaseProjectId => _read('FIREBASE_PROJECT_ID');
}
