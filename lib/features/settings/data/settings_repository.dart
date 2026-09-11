import 'package:shared_preferences/shared_preferences.dart';

import '../domain/app_settings.dart';

class SettingsRepository {
  const SettingsRepository(this._prefs);

  static const themeKey = 'settings.theme';
  static const languageKey = 'settings.language';
  static const onboardingKey = 'settings.onboarding_completed';

  final SharedPreferences _prefs;

  AppSettings load() {
    final themeName = _prefs.getString(themeKey);
    return AppSettings(
      theme: ThemePreference.values.firstWhere(
        (theme) => theme.name == themeName,
        orElse: () => ThemePreference.system,
      ),
      language: LanguagePreference.fromCode(_prefs.getString(languageKey)),
      onboardingCompleted: _prefs.getBool(onboardingKey) ?? false,
    );
  }

  Future<void> save(AppSettings settings) async {
    await _prefs.setString(themeKey, settings.theme.name);
    final code = settings.language.languageCode;
    if (code == null) {
      await _prefs.remove(languageKey);
    } else {
      await _prefs.setString(languageKey, code);
    }
    await _prefs.setBool(onboardingKey, settings.onboardingCompleted);
  }
}
