import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../domain/recipe.dart';

/// Source de données des recettes. L'interface permet de remplacer
/// l'implémentation (asset local aujourd'hui, API REST demain) et de
/// l'isoler dans les tests.
abstract interface class RecipeRepository {
  Future<List<Recipe>> fetchRecipes();

  /// Lève [RecipeNotFoundException] si l'identifiant est inconnu.
  Future<Recipe> fetchRecipe(String id);
}

class RecipeNotFoundException implements Exception {
  const RecipeNotFoundException(this.id);

  final String id;

  @override
  String toString() => 'RecipeNotFoundException: $id';
}

class RecipeParseException implements Exception {
  const RecipeParseException(this.message);

  final String message;

  @override
  String toString() => 'RecipeParseException: $message';
}

/// Lit le catalogue embarqué dans `assets/data/recipes.json`.
///
/// Le décodage JSON s'exécute dans un isolate via [compute] pour ne jamais
/// bloquer le thread UI (pas de frame perdue au démarrage), et le résultat
/// est mis en cache pour la durée de vie du dépôt.
class AssetRecipeRepository implements RecipeRepository {
  AssetRecipeRepository({AssetBundle? bundle, this.assetPath = defaultAssetPath})
    : _bundle = bundle ?? rootBundle;

  static const defaultAssetPath = 'assets/data/recipes.json';

  final AssetBundle _bundle;
  final String assetPath;
  Future<List<Recipe>>? _cache;

  @override
  Future<List<Recipe>> fetchRecipes() {
    return _cache ??= _load().catchError((Object error, StackTrace stackTrace) {
      // Un échec ne doit pas rester en cache : on pourra réessayer.
      _cache = null;
      Error.throwWithStackTrace(error, stackTrace);
    });
  }

  Future<List<Recipe>> _load() async {
    final raw = await _bundle.loadString(assetPath, cache: false);
    return compute(parseRecipes, raw, debugLabel: 'parseRecipes');
  }

  @override
  Future<Recipe> fetchRecipe(String id) async {
    final recipes = await fetchRecipes();
    return recipes.firstWhere(
      (recipe) => recipe.id == id,
      orElse: () => throw RecipeNotFoundException(id),
    );
  }
}

/// Décode le catalogue. Fonction de premier niveau pour être exécutable
/// dans un isolate.
List<Recipe> parseRecipes(String source) {
  try {
    final decoded = jsonDecode(source) as Map<String, Object?>;
    final items = decoded['recipes']! as List<Object?>;
    return List.unmodifiable([
      for (final item in items) Recipe.fromJson(item! as Map<String, Object?>),
    ]);
  } on Object catch (error) {
    // FormatException, TypeError (cast) ou champ manquant : on uniformise.
    throw RecipeParseException(error.toString());
  }
}
