import 'package:flutter_test/flutter_test.dart';
import 'package:miam/core/utils/text_normalizer.dart';
import 'package:miam/features/recipes/domain/recipe.dart';
import 'package:miam/features/recipes/domain/recipe_query.dart';

import '../../helpers/test_data.dart';

List<String> ids(List<Recipe> recipes) => recipes.map((recipe) => recipe.id).toList();

void main() {
  group('TextNormalizer', () {
    test('supprime casse, accents, ligatures et espaces multiples', () {
      expect(TextNormalizer.normalize('  Crème   BRÛLÉE '), 'creme brulee');
      expect(TextNormalizer.normalize('Bœuf'), 'boeuf');
    });

    test('découpe en mots, liste vide pour une saisie blanche', () {
      expect(TextNormalizer.tokenize('Salade  Niçoise'), ['salade', 'nicoise']);
      expect(TextNormalizer.tokenize('   '), isEmpty);
    });
  });

  group('RecipeQuery', () {
    test('une requête vide renvoie tout le catalogue', () {
      const query = RecipeQuery();
      expect(query.isEmpty, isTrue);
      expect(query.apply(sampleRecipes), hasLength(sampleRecipes.length));
    });

    test('recherche insensible aux accents et à la casse', () {
      expect(ids(const RecipeQuery(searchTerm: 'BOEUF').apply(sampleRecipes)), ['boeuf']);
      expect(ids(const RecipeQuery(searchTerm: 'crepes').apply(sampleRecipes)), ['crepes']);
    });

    test('recherche dans toutes les langues et dans les ingrédients', () {
      expect(ids(const RecipeQuery(searchTerm: 'beef').apply(sampleRecipes)), ['boeuf']);
      expect(ids(const RecipeQuery(searchTerm: 'thon').apply(sampleRecipes)), ['salade']);
    });

    test('tous les mots doivent correspondre', () {
      expect(ids(const RecipeQuery(searchTerm: 'œufs lait').apply(sampleRecipes)), ['crepes']);
      expect(const RecipeQuery(searchTerm: 'œufs chocolat').apply(sampleRecipes), isEmpty);
    });

    test('filtre par catégorie, végétarien et rapidité', () {
      expect(ids(const RecipeQuery(category: RecipeCategory.main).apply(sampleRecipes)), ['boeuf']);
      expect(ids(const RecipeQuery(vegetarianOnly: true).apply(sampleRecipes)), [
        'crepes',
        'omelette',
      ]);
      expect(ids(const RecipeQuery(quickOnly: true).apply(sampleRecipes)), [
        'crepes',
        'salade',
        'omelette',
      ]);
    });

    test('combine les filtres', () {
      const query = RecipeQuery(quickOnly: true, vegetarianOnly: true, searchTerm: 'omelette');
      expect(ids(query.apply(sampleRecipes)), ['omelette']);
    });

    test('copyWith permet de retirer la catégorie', () {
      const query = RecipeQuery(category: RecipeCategory.dessert, searchTerm: 'a');
      final cleared = query.copyWith(category: () => null);
      expect(cleared.category, isNull);
      expect(cleared.searchTerm, 'a');
    });
  });
}
