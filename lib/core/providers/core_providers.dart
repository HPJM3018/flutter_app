import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Instance chargée dans `main()` avant `runApp` puis injectée via
/// `ProviderScope.overrides` : les lectures deviennent synchrones.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider doit être surchargé au démarrage.'),
  name: 'sharedPreferencesProvider',
);
