import 'package:equatable/equatable.dart';

import '../../../core/utils/text_normalizer.dart';
import 'recipe.dart';

/// Critères de recherche du catalogue. Immuable : chaque modification
/// produit une nouvelle instance, ce qui rend le filtrage trivial à tester.
class RecipeQuery extends Equatable {
  const RecipeQuery({
    this.searchTerm = '',
    this.category,
    this.vegetarianOnly = false,
    this.quickOnly = false,
  });

  /// Durée totale maximale d'une recette « rapide ».
  static const quickThresholdMinutes = 30;

  final String searchTerm;
  final RecipeCategory? category;
  final bool vegetarianOnly;
  final bool quickOnly;

  bool get isEmpty =>
      searchTerm.trim().isEmpty && category == null && !vegetarianOnly && !quickOnly;

  RecipeQuery copyWith({
    String? searchTerm,
    RecipeCategory? Function()? category,
    bool? vegetarianOnly,
    bool? quickOnly,
  }) {
    return RecipeQuery(
      searchTerm: searchTerm ?? this.searchTerm,
      category: category != null ? category() : this.category,
      vegetarianOnly: vegetarianOnly ?? this.vegetarianOnly,
      quickOnly: quickOnly ?? this.quickOnly,
    );
  }

  /// Une recette correspond si elle respecte chaque filtre actif et si
  /// *tous* les mots recherchés apparaissent dans son titre ou ses
  /// ingrédients, quelle que soit la langue.
  bool matches(Recipe recipe) {
    if (category != null && recipe.category != category) return false;
    if (vegetarianOnly && !recipe.isVegetarian) return false;
    if (quickOnly && recipe.totalMinutes > quickThresholdMinutes) return false;

    final tokens = TextNormalizer.tokenize(searchTerm);
    if (tokens.isEmpty) return true;

    final haystack = TextNormalizer.normalize(
      [
        ...recipe.title.allValues,
        for (final ingredient in recipe.ingredients) ...ingredient.name.allValues,
      ].join(' '),
    );
    return tokens.every(haystack.contains);
  }

  List<Recipe> apply(Iterable<Recipe> recipes) => recipes.where(matches).toList(growable: false);

  @override
  List<Object?> get props => [searchTerm, category, vegetarianOnly, quickOnly];
}
