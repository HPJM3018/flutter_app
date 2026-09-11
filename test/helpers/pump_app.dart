import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/misc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miam/app.dart';
import 'package:miam/core/images/recipe_image.dart';
import 'package:miam/core/l10n/l10n.dart';
import 'package:miam/core/providers/core_providers.dart';
import 'package:miam/core/router/app_router.dart';
import 'package:miam/core/theme/app_theme.dart';
import 'package:miam/features/recipes/application/recipe_providers.dart';
import 'package:miam/features/recipes/data/recipe_repository.dart';
import 'package:miam/features/settings/data/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes.dart';
import 'test_data.dart';

/// Réinitialise le stockage clé-valeur (en mémoire) et renvoie l'instance.
Future<SharedPreferences> mockPreferences({
  bool onboarded = true,
  String languageCode = 'fr',
  Map<String, Object> extra = const {},
}) async {
  SharedPreferences.setMockInitialValues({
    SettingsRepository.onboardingKey: onboarded,
    SettingsRepository.languageKey: languageCode,
    ...extra,
  });
  return SharedPreferences.getInstance();
}

/// Démarre l'application complète (routeur, thème, l10n) avec des
/// dépendances de test. Renvoie le conteneur pour inspecter l'état.
Future<ProviderContainer> pumpMiamApp(
  WidgetTester tester, {
  String initialLocation = AppRoutes.recipes,
  bool onboarded = true,
  String languageCode = 'fr',
  RecipeRepository? repository,
  Map<String, Object> preferences = const {},
  List<Override> overrides = const [],
  bool settle = true,
}) async {
  final prefs = await mockPreferences(
    onboarded: onboarded,
    languageCode: languageCode,
    extra: preferences,
  );
  final container = ProviderContainer.test(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      recipeRepositoryProvider.overrideWithValue(repository ?? FakeRecipeRepository(sampleRecipes)),
      recipeImageProviderBuilderProvider.overrideWithValue(testImageProviderBuilder),
      initialLocationProvider.overrideWithValue(initialLocation),
      ...overrides,
    ],
    // Pas de nouvelle tentative automatique : les erreurs restent visibles
    // et aucun minuteur ne reste en attente à la fin du test.
    retry: (_, _) => null,
  );
  await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MiamApp()));
  if (settle) await tester.pumpAndSettle();
  return container;
}

/// Monte un widget isolé dans un `MaterialApp` localisé.
Future<ProviderContainer> pumpLocalized(
  WidgetTester tester,
  Widget child, {
  Locale locale = const Locale('fr'),
  List<Override> overrides = const [],
  SharedPreferences? preferences,
}) async {
  final prefs = preferences ?? await mockPreferences();
  final container = ProviderContainer.test(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      recipeImageProviderBuilderProvider.overrideWithValue(testImageProviderBuilder),
      ...overrides,
    ],
    retry: (_, _) => null,
  );
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.light,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: MiamApp.localizationsDelegates,
        home: Scaffold(body: child),
      ),
    ),
  );
  await tester.pump();
  return container;
}
