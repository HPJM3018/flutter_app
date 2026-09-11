import 'package:flutter_test/flutter_test.dart';
import 'package:miam/features/recipes/domain/quantity.dart';
import 'package:miam/features/shopping_list/domain/shopping_list.dart';

import '../../helpers/test_data.dart';

void main() {
  group('ShoppingList.addIngredients', () {
    test("ajoute chaque ingrédient d'une recette", () {
      final list = const ShoppingList().addRecipe(buildRecipe(), servings: 4);

      expect(list.items, hasLength(4));
      expect(list.remainingCount, 4);
      expect(list.containsRecipe('crepes'), isTrue);
    });

    test('additionne un même ingrédient venant de deux recettes', () {
      final list = const ShoppingList()
          .addIngredients([ingredient('egg', quantity: 3)], recipeId: 'a')
          .addIngredients([ingredient('egg', quantity: 2)], recipeId: 'b');

      expect(list.items, hasLength(1));
      expect(list.items.single.quantity, 5);
      expect(list.items.single.recipeIds, {'a', 'b'});
    });

    test('convertit les unités compatibles avant de les additionner', () {
      final list = const ShoppingList()
          .addIngredients([
            ingredient('flour', quantity: 200, unit: IngredientUnit.gram),
          ], recipeId: 'a')
          .addIngredients([
            ingredient('flour', quantity: 1, unit: IngredientUnit.kilogram),
          ], recipeId: 'b');

      expect(list.items.single.quantity, 1200);
      expect(list.items.single.displayQuantity, const Quantity(1.2, IngredientUnit.kilogram));
    });

    test('ne mélange pas des unités incompatibles', () {
      final list = const ShoppingList().addIngredients([
        ingredient('garlic', quantity: 2, unit: IngredientUnit.clove),
        ingredient('garlic', quantity: 1, unit: IngredientUnit.teaspoon),
      ], recipeId: 'a');

      expect(list.items, hasLength(2));
    });

    test('met à l’échelle selon le nombre de portions', () {
      final list = const ShoppingList().addRecipe(buildRecipe(), servings: 2);
      expect(list.items.first.quantity, 125); // 250 g de farine pour 4 → 125 g pour 2
    });

    test('un nouveau besoin décoche un article déjà acheté', () {
      final first = const ShoppingList().addIngredients([
        ingredient('egg', quantity: 1),
      ], recipeId: 'a');
      final checked = first.toggle(first.items.single.key);
      final again = checked.addIngredients([ingredient('egg', quantity: 1)], recipeId: 'b');

      expect(checked.items.single.isChecked, isTrue);
      expect(again.items.single.isChecked, isFalse);
    });
  });

  group('ShoppingList — gestion des articles', () {
    final list = const ShoppingList().addRecipe(buildRecipe(), servings: 4);
    final eggKey = list.items[1].key;

    test('toggle, tri et suppression des articles cochés', () {
      final toggled = list.toggle(eggKey);

      expect(toggled.checkedCount, 1);
      expect(toggled.sortedItems.last.key, eggKey);
      expect(toggled.clearChecked().items.map((item) => item.key), isNot(contains(eggKey)));
    });

    test('remove puis insert restaure la position (annulation)', () {
      final item = list.items[1];
      final restored = list.remove(eggKey).insert(1, item);

      expect(restored, list);
    });

    test('sérialisation JSON aller-retour sans perte', () {
      final toggled = list.toggle(eggKey);
      expect(ShoppingList.fromJson(toggled.toJson()), toggled);
    });
  });
}
