import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/misc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/providers/core_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(await bootstrap());
}

/// Prépare les dépendances asynchrones puis construit l'arbre racine.
/// Partagé avec les tests d'intégration, qui peuvent ajouter des
/// surcharges (données de test, images hors-ligne…).
Future<Widget> bootstrap({List<Override> overrides = const []}) async {
  final preferences = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(preferences), ...overrides],
    child: const MiamApp(),
  );
}
