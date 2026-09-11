import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../data/recipe_repository.dart';
import '../domain/recipe.dart';
import '../domain/recipe_query.dart';

final recipeRepositoryProvider = Provider<RecipeRepository>(
  (ref) => AssetRecipeRepository(),
  name: 'recipeRepositoryProvider',
);

/// Catalogue complet, chargé une fois puis partagé par tous les écrans.
final recipesProvider = FutureProvider<List<Recipe>>(
  (ref) => ref.watch(recipeRepositoryProvider).fetchRecipes(),
  name: 'recipesProvider',
);

/// Une recette par identifiant, dérivée du catalogue (source unique).
final recipeProvider = FutureProvider.autoDispose.family<Recipe, String>((ref, id) async {
  final recipes = await ref.watch(recipesProvider.future);
  return recipes.firstWhere(
    (recipe) => recipe.id == id,
    orElse: () => throw RecipeNotFoundException(id),
  );
}, name: 'recipeProvider');

class RecipeQueryNotifier extends Notifier<RecipeQuery> {
  @override
  RecipeQuery build() => const RecipeQuery();

  void setSearchTerm(String term) => state = state.copyWith(searchTerm: term);

  /// Sélectionner la catégorie active la désélectionne.
  void toggleCategory(RecipeCategory category) =>
      state = state.copyWith(category: () => state.category == category ? null : category);

  void toggleVegetarian() => state = state.copyWith(vegetarianOnly: !state.vegetarianOnly);

  void toggleQuick() => state = state.copyWith(quickOnly: !state.quickOnly);

  void reset() => state = const RecipeQuery();
}

final recipeQueryProvider = NotifierProvider<RecipeQueryNotifier, RecipeQuery>(
  RecipeQueryNotifier.new,
  name: 'recipeQueryProvider',
);

/// Résultats filtrés. Recalculés uniquement quand le catalogue ou la
/// requête changent ; les widgets qui n'écoutent que la requête ne sont
/// pas reconstruits par le chargement.
final filteredRecipesProvider = Provider<AsyncValue<List<Recipe>>>((ref) {
  final query = ref.watch(recipeQueryProvider);
  return ref.watch(recipesProvider).whenData(query.apply);
}, name: 'filteredRecipesProvider');
