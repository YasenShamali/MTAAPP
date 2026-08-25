import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/generated/app_localizations.dart';

/// Manages the app language for English / Arabic UI.
///
/// Persists the user's choice with [SharedPreferences], exposes the current
/// locale through a [ValueNotifier] so [MaterialApp] can rebuild instantly on
/// switch, and falls back to the device locale on first launch.
class LocaleService {
  LocaleService._();

  static const String _prefKey = 'app_locale';

  /// Set to `true` once [initialize] completes.
  static bool _initialized = false;

  /// Current resolved locale. Listeners are notified on change.
  static final ValueNotifier<Locale> locale = ValueNotifier<Locale>(
    const Locale('ar'),
  );

  /// Whether a language was explicitly chosen by the user.
  static bool _userChosen = false;

  static Locale get current => locale.value;

  static bool get isArabic => locale.value.languageCode == 'ar';

  static bool get userChosen => _userChosen;

  /// Loads the saved preference or falls back to the device locale.
  static Future<void> initialize() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    if (saved != null && (saved == 'ar' || saved == 'en')) {
      _userChosen = true;
      locale.value = Locale(saved);
    } else {
      locale.value = _deviceLocale();
    }
    _initialized = true;
  }

  /// Switches the language and persists the user's choice.
  static Future<void> setLocale(Locale value) async {
    if (!_initialized) await initialize();
    _userChosen = true;
    locale.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, value.languageCode);
  }

  /// Resolves the device locale to the closest supported language.
  static Locale _deviceLocale() {
    return WidgetsBinding.instance.platformDispatcher.locales
        .where(
          (locale) => locale.languageCode == 'ar' || locale.languageCode == 'en',
        )
        .firstOrNull ??
        const Locale('ar');
  }

  /// Convenience accessor for app-wide localization lookups.
  static AppLocalizations get l10n => lookupAppLocalizations(locale.value);
}