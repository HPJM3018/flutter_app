import 'package:flutter_test/flutter_test.dart';
import 'package:miam/features/recipes/domain/quantity.dart';

void main() {
  group('Quantity.toBase', () {
    test('convertit kg → g et l → ml', () {
      expect(
        const Quantity(1.5, IngredientUnit.kilogram).toBase(),
        const Quantity(1500, IngredientUnit.gram),
      );
      expect(
        const Quantity(0.25, IngredientUnit.liter).toBase(),
        const Quantity(250, IngredientUnit.milliliter),
      );
    });

    test('laisse les unités comptées inchangées', () {
      expect(
        const Quantity(2, IngredientUnit.clove).toBase(),
        const Quantity(2, IngredientUnit.clove),
      );
    });
  });

  group('Quantity.normalized', () {
    test('passe à l’unité supérieure à partir de 1000', () {
      expect(
        const Quantity(1250, IngredientUnit.gram).normalized(),
        const Quantity(1.25, IngredientUnit.kilogram),
      );
      expect(
        const Quantity(1500, IngredientUnit.milliliter).normalized(),
        const Quantity(1.5, IngredientUnit.liter),
      );
    });

    test('redescend vers l’unité de base sous 1 kg / 1 l', () {
      expect(
        const Quantity(0.3, IngredientUnit.kilogram).normalized(),
        const Quantity(300, IngredientUnit.gram),
      );
    });

    test('arrondit à 5 g au-delà de 100 g, au gramme en dessous', () {
      expect(
        const Quantity(333.33, IngredientUnit.gram).normalized(),
        const Quantity(335, IngredientUnit.gram),
      );
      expect(
        const Quantity(12.4, IngredientUnit.gram).normalized(),
        const Quantity(12, IngredientUnit.gram),
      );
      expect(
        const Quantity(998, IngredientUnit.gram).normalized(),
        const Quantity(1, IngredientUnit.kilogram),
      );
    });

    test('arrondit les unités comptées au quart, jamais à zéro', () {
      expect(
        const Quantity(1.6, IngredientUnit.piece).normalized(),
        const Quantity(1.5, IngredientUnit.piece),
      );
      expect(
        const Quantity(0.1, IngredientUnit.pinch).normalized(),
        const Quantity(0.25, IngredientUnit.pinch),
      );
    });
  });

  group('Quantity.formatValue', () {
    test('utilise le séparateur décimal de la langue', () {
      const quantity = Quantity(1.25, IngredientUnit.kilogram);
      expect(quantity.formatValue('fr'), '1,25');
      expect(quantity.formatValue('en'), '1.25');
    });

    test('affiche des fractions typographiques pour les unités comptées', () {
      expect(const Quantity(1.5, IngredientUnit.piece).formatValue('fr'), '1½');
      expect(const Quantity(0.25, IngredientUnit.teaspoon).formatValue('en'), '¼');
      expect(const Quantity(3, IngredientUnit.piece).formatValue('fr'), '3');
    });
  });
}
