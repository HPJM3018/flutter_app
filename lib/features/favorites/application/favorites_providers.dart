import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../recipes/application/recipe_providers.dart';
import '../../recipes/domain/recipe.dart';
import '../data/favorites_repository.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>(
  (ref) => FavoritesRepository(ref.watch(sharedPreferencesProvider)),
  name: 'favoritesRepositoryProvider',
);

/// Identifiants favoris, dans l'ordre d'ajout.
class FavoritesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => Set.unmodifiable(ref.watch(favoritesRepositoryProvider).load());

  Future<void> toggle(String recipeId) async {
    final next = {...state};
    if (!next.remove(recipeId)) next.add(recipeId);
    state = Set.unmodifiable(next);
    await ref.read(favoritesRepositoryProvider).save(state);
  }

  Future<void> remove(String recipeId) async {
    if (!state.contains(recipeId)) return;
    await toggle(recipeId);
  }
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, Set<String>>(
  FavoritesNotifier.new,
  name: 'favoritesProvider',
);

/// Statut favori d'une seule recette. Grâce à `select`, basculer une
/// recette ne reconstruit que les widgets qui affichent *cette* recette.
final isFavoriteProvider = Provider.autoDispose.family<bool, String>(
  (ref, recipeId) => ref.watch(favoritesProvider.select((ids) => ids.contains(recipeId))),
  name: 'isFavoriteProvider',
);

/// Recettes favorites, les plus récemment ajoutées en premier.
final favoriteRecipesProvider = Provider<AsyncValue<List<Recipe>>>((ref) {
  final ids = ref.watch(favoritesProvider);
  return ref.watch(recipesProvider).whenData((recipes) {
    final byId = {for (final recipe in recipes) recipe.id: recipe};
    return [
      for (final id in ids.toList().reversed)
        if (byId[id] case final Recipe recipe) recipe,
    ];
  });
}, name: 'favoriteRecipesProvider');
