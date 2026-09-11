import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miam/features/recipes/data/recipe_repository.dart';

/// Bundle d'assets en mémoire qui compte les lectures.
class _FakeBundle extends CachingAssetBundle {
  _FakeBundle(this.content);

  final String content;
  int loads = 0;

  @override
  Future<ByteData> load(String key) async {
    loads++;
    return ByteData.sublistView(utf8.encode(content));
  }
}

const _validJson = '''
{"recipes": [
  {"id": "a", "title": "A", "description": "", "imageUrl": "https://x/a.jpg",
   "category": "main", "difficulty": "easy", "prepMinutes": 5, "servings": 2,
   "ingredients": [], "steps": []},
  {"id": "b", "title": "B", "description": "", "imageUrl": "https://x/b.jpg",
   "category": "dessert", "difficulty": "hard", "prepMinutes": 5, "servings": 2,
   "ingredients": [], "steps": []}
]}
''';

void main() {
  group('AssetRecipeRepository', () {
    test('décode le catalogue et le garde en cache', () async {
      final bundle = _FakeBundle(_validJson);
      final repository = AssetRecipeRepository(bundle: bundle);

      final first = await repository.fetchRecipes();
      final second = await repository.fetchRecipes();

      expect(first.map((recipe) => recipe.id), ['a', 'b']);
      expect(identical(first, second), isTrue);
      expect(bundle.loads, 1);
    });

    test('fetchRecipe trouve par identifiant ou lève RecipeNotFoundException', () async {
      final repository = AssetRecipeRepository(bundle: _FakeBundle(_validJson));

      expect((await repository.fetchRecipe('b')).id, 'b');
      await expectLater(repository.fetchRecipe('zzz'), throwsA(isA<RecipeNotFoundException>()));
    });

    test("un JSON invalide lève RecipeParseException et n'est pas mis en cache", () async {
      final bundle = _FakeBundle('{"recipes": [{"id": 1}]}');
      final repository = AssetRecipeRepository(bundle: bundle);

      await expectLater(repository.fetchRecipes(), throwsA(isA<RecipeParseException>()));
      await expectLater(repository.fetchRecipes(), throwsA(isA<RecipeParseException>()));
      expect(bundle.loads, 2, reason: "l'échec doit permettre une nouvelle tentative");
    });
  });

  test('le catalogue embarqué est valide, bilingue et sans doublon', () {
    final source = File('assets/data/recipes.json').readAsStringSync();
    final recipes = parseRecipes(source);

    expect(recipes.length, greaterThanOrEqualTo(12));
    expect(recipes.map((recipe) => recipe.id).toSet(), hasLength(recipes.length));
    for (final recipe in recipes) {
      expect(recipe.title.translations.keys, containsAll(['fr', 'en']), reason: recipe.id);
      expect(recipe.steps, isNotEmpty, reason: recipe.id);
      expect(recipe.ingredients, isNotEmpty, reason: recipe.id);
      for (final step in recipe.steps) {
        expect(step.translations.keys, containsAll(['fr', 'en']), reason: recipe.id);
      }
    }
  });
}
