import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miam/core/providers/core_providers.dart';
import 'package:miam/features/favorites/application/favorites_providers.dart';
import 'package:miam/features/favorites/data/favorites_repository.dart';
import 'package:miam/features/recipes/application/recipe_providers.dart';
import 'package:miam/features/settings/application/settings_providers.dart';
import 'package:miam/features/settings/domain/app_settings.dart';
import 'package:miam/features/shopping_list/application/shopping_list_providers.dart';
import 'package:miam/features/shopping_list/data/shopping_list_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_data.dart';

/// Chaque test démarre sur un stockage vierge ; recréer un conteneur sur
/// le même stockage simule un redémarrage de l'application.
Future<ProviderContainer> createContainer([Map<String, Object> values = const {}]) async {
  SharedPreferences.setMockInitialValues(values);
  final prefs = await SharedPreferences.getInstance();
  return restart(prefs);
}

ProviderContainer restart(SharedPreferences prefs) => ProviderContainer.test(
  overrides: [
    sharedPreferencesProvider.overrideWithValue(prefs),
    recipeRepositoryProvider.overrideWithValue(FakeRecipeRepository(sampleRecipes)),
  ],
);

void main() {
  group('FavoritesNotifier', () {
    test('bascule un favori et le persiste', () async {
      final container = await createContainer();
      final notifier = container.read(favoritesProvider.notifier);

      await notifier.toggle('boeuf');
      await notifier.toggle('crepes');
      await notifier.toggle('boeuf');

      expect(container.read(favoritesProvider), {'crepes'});
      final prefs = container.read(sharedPreferencesProvider);
      expect(prefs.getStringList(FavoritesRepository.storageKey), ['crepes']);
      expect(restart(prefs).read(favoritesProvider), {'crepes'});
    });

    test('isFavoriteProvider ne notifie que la recette concernée', () async {
      final container = await createContainer();
      var crepesNotifications = 0;
      var boeufNotifications = 0;
      container.listen(isFavoriteProvider('crepes'), (_, _) => crepesNotifications++);
      container.listen(isFavoriteProvider('boeuf'), (_, _) => boeufNotifications++);

      await container.read(favoritesProvider.notifier).toggle('crepes');

      expect(container.read(isFavoriteProvider('crepes')), isTrue);
      expect(crepesNotifications, 1);
      expect(boeufNotifications, 0, reason: 'pas de rebuild inutile des autres cartes');
    });

    test('favoriteRecipesProvider liste les favoris du plus récent au plus ancien', () async {
      final container = await createContainer();
      await container.read(recipesProvider.future);
      final notifier = container.read(favoritesProvider.notifier);

      await notifier.toggle('salade');
      await notifier.toggle('omelette');

      final favorites = container.read(favoriteRecipesProvider).requireValue;
      expect(favorites.map((recipe) => recipe.id), ['omelette', 'salade']);
    });
  });

  group('ShoppingListNotifier', () {
    test('ajoute une recette, persiste et recharge au redémarrage', () async {
      final container = await createContainer();
      final notifier = container.read(shoppingListProvider.notifier);

      await notifier.addRecipe(sampleRecipes.first, servings: 2);
      await notifier.toggle(container.read(shoppingListProvider).items.first.key);

      final prefs = container.read(sharedPreferencesProvider);
      final reloaded = restart(prefs).read(shoppingListProvider);
      expect(reloaded, container.read(shoppingListProvider));
      expect(reloaded.checkedCount, 1);
      expect(container.read(shoppingRemainingCountProvider), 3);
    });

    test('une donnée corrompue donne une liste vide au lieu de planter', () async {
      final container = await createContainer({ShoppingListRepository.storageKey: '{oups'});
      expect(container.read(shoppingListProvider).isEmpty, isTrue);
    });
  });

  group('SettingsNotifier', () {
    test('valeurs par défaut au premier lancement', () async {
      final container = await createContainer();
      expect(container.read(settingsProvider), const AppSettings());
    });

    test('persiste thème, langue et onboarding', () async {
      final container = await createContainer();
      final notifier = container.read(settingsProvider.notifier);

      await notifier.setTheme(ThemePreference.dark);
      await notifier.setLanguage(LanguagePreference.english);
      await notifier.completeOnboarding();

      final reloaded = restart(container.read(sharedPreferencesProvider)).read(settingsProvider);
      expect(
        reloaded,
        const AppSettings(
          theme: ThemePreference.dark,
          language: LanguagePreference.english,
          onboardingCompleted: true,
        ),
      );
    });

    test('revenir à la langue système efface la préférence', () async {
      final container = await createContainer();
      final notifier = container.read(settingsProvider.notifier);

      await notifier.setLanguage(LanguagePreference.french);
      await notifier.setLanguage(LanguagePreference.system);

      expect(container.read(sharedPreferencesProvider).getString('settings.language'), isNull);
    });
  });
}
