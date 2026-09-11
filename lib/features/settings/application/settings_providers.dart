import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/settings_repository.dart';
import '../domain/app_settings.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(sharedPreferencesProvider)),
  name: 'settingsRepositoryProvider',
);

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.watch(settingsRepositoryProvider).load();

  Future<void> setTheme(ThemePreference theme) => _update(state.copyWith(theme: theme));

  Future<void> setLanguage(LanguagePreference language) =>
      _update(state.copyWith(language: language));

  Future<void> completeOnboarding() => _update(state.copyWith(onboardingCompleted: true));

  Future<void> resetOnboarding() => _update(state.copyWith(onboardingCompleted: false));

  Future<void> _update(AppSettings next) async {
    if (next == state) return;
    state = next;
    await ref.read(settingsRepositoryProvider).save(next);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
  name: 'settingsProvider',
);
