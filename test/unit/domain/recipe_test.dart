import 'package:flutter_test/flutter_test.dart';
import 'package:miam/features/recipes/domain/localized_text.dart';
import 'package:miam/features/recipes/domain/quantity.dart';
import 'package:miam/features/recipes/domain/recipe.dart';

import '../../helpers/test_data.dart';

void main() {
  group('LocalizedText', () {
    const text = LocalizedText({'fr': 'Bonjour', 'en': 'Hello'});

    test('renvoie la traduction demandée', () {
      expect(text.resolve('fr'), 'Bonjour');
      expect(text.resolve('en'), 'Hello');
    });

    test("se replie sur l'anglais puis sur la première valeur", () {
      expect(text.resolve('de'), 'Hello');
      expect(const LocalizedText({'es': 'Hola'}).resolve('fr'), 'Hola');
      expect(const LocalizedText({}).resolve('fr'), isEmpty);
    });

    test('accepte une chaîne simple ou une map, rejette le reste', () {
      expect(LocalizedText.fromJson('Salt').resolve('fr'), 'Salt');
      expect(
        LocalizedText.fromJson(const {'fr': 'Sel', 'en': 'Salt'}),
        const LocalizedText({'fr': 'Sel', 'en': 'Salt'}),
      );
      expect(() => LocalizedText.fromJson(42), throwsFormatException);
    });
  });

  group('Recipe.fromJson', () {
    final json = <String, Object?>{
      'id': 'crepes',
      'title': {'fr': 'Crêpes', 'en': 'Crêpes'},
      'description': 'Simple',
      'imageUrl': 'https://example.com/crepes.jpg',
      'category': 'dessert',
      'difficulty': 'easy',
      'prepMinutes': 10,
      'cookMinutes': 20,
      'servings': 4,
      'vegetarian': true,
      'ingredients': [
        {
          'id': 'flour',
          'name': {'fr': 'Farine'},
          'quantity': 250,
          'unit': 'gram',
        },
        {'id': 'salt', 'name': 'Salt', 'quantity': null},
      ],
      'steps': ['Mix', 'Cook'],
    };

    test('décode tous les champs, avec valeurs par défaut', () {
      final recipe = Recipe.fromJson(json);

      expect(recipe.id, 'crepes');
      expect(recipe.category, RecipeCategory.dessert);
      expect(recipe.difficulty, Difficulty.easy);
      expect(recipe.totalMinutes, 30);
      expect(recipe.isVegetarian, isTrue);
      expect(recipe.ingredients, hasLength(2));
      expect(recipe.ingredients.first.amount, const Quantity(250, IngredientUnit.gram));
      expect(recipe.ingredients.last.quantity, isNull);
      expect(recipe.ingredients.last.unit, IngredientUnit.piece);
      expect(recipe.steps.map((step) => step.resolve('en')), ['Mix', 'Cook']);
    });

    test('rejette une catégorie inconnue', () {
      expect(
        () => Recipe.fromJson({...json, 'category': 'brunch'}),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('Recipe.ingredientsFor', () {
    final recipe = buildRecipe();

    test('recalcule les quantités proportionnellement', () {
      final doubled = recipe.ingredientsFor(8);

      expect(doubled.first.quantity, 500); // farine 250 g → 500 g
      expect(doubled[1].quantity, 6); // œufs 3 → 6
    });

    test('conserve les quantités libres (« selon votre goût »)', () {
      expect(recipe.ingredientsFor(2).last.quantity, isNull);
    });

    test("renvoie la liste d'origine pour le même nombre de portions", () {
      expect(identical(recipe.ingredientsFor(4), recipe.ingredients), isTrue);
    });

    test('refuse un nombre de portions nul ou négatif', () {
      expect(() => recipe.ingredientsFor(0), throwsArgumentError);
    });
  });
}
