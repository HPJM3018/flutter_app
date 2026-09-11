import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miam/features/favorites/application/favorites_providers.dart';
import 'package:miam/features/favorites/presentation/favorite_button.dart';
import 'package:miam/features/recipes/presentation/widgets/recipe_card.dart';
import 'package:miam/features/recipes/presentation/widgets/servings_stepper.dart';

import '../helpers/pump_app.dart';
import '../helpers/test_data.dart';

void main() {
  group('RecipeCard', () {
    Widget card({VoidCallback? onTap}) => Center(
      child: SizedBox(
        width: 220,
        height: 300,
        child: RecipeCard(recipe: buildRecipe(), onTap: onTap ?? () {}),
      ),
    );

    testWidgets('affiche le titre, la durée et la difficulté', (tester) async {
      await pumpLocalized(tester, card());

      expect(find.text('Crêpes de la Chandeleur'), findsOneWidget);
      expect(find.text('30 min · Facile'), findsOneWidget);
    });

    testWidgets('expose un libellé accessible complet et réagit au tap', (tester) async {
      final handle = tester.ensureSemantics();
      var taps = 0;
      await pumpLocalized(tester, card(onTap: () => taps++));

      final semantics = find.bySemanticsLabel(
        'Crêpes de la Chandeleur. 30 min. Difficulté : Facile.',
      );
      expect(semantics, findsOneWidget);
      expect(
        tester.getSemantics(semantics),
        matchesSemantics(
          label: 'Crêpes de la Chandeleur. 30 min. Difficulté : Facile.',
          isButton: true,
          hasTapAction: true,
        ),
      );

      await tester.tap(find.text('Crêpes de la Chandeleur'));
      expect(taps, 1);
      handle.dispose();
    });

    testWidgets('affiche la langue choisie pour le contenu', (tester) async {
      await pumpLocalized(tester, card(), locale: const Locale('en'));

      expect(find.text('Candlemas crêpes'), findsOneWidget);
      expect(find.text('30 min · Easy'), findsOneWidget);
    });
  });

  group('FavoriteButton', () {
    testWidgets('bascule le favori et met à jour son libellé accessible', (tester) async {
      final container = await pumpLocalized(tester, const FavoriteButton(recipeId: 'crepes'));

      expect(find.byTooltip('Ajouter aux favoris'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);

      await tester.tap(find.byType(FavoriteButton));
      await tester.pumpAndSettle();

      expect(container.read(favoritesProvider), {'crepes'});
      expect(find.byTooltip('Retirer des favoris'), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });
  });

  group('ServingsStepper', () {
    Future<List<int>> pumpStepper(WidgetTester tester, int servings) async {
      final changes = <int>[];
      await pumpLocalized(
        tester,
        Center(
          child: ServingsStepper(servings: servings, onChanged: changes.add),
        ),
      );
      return changes;
    }

    testWidgets('augmente et diminue le nombre de portions', (tester) async {
      final changes = await pumpStepper(tester, 4);

      expect(find.text('4 personnes'), findsOneWidget);
      await tester.tap(find.byTooltip('Ajouter une portion'));
      await tester.tap(find.byTooltip('Retirer une portion'));

      expect(changes, [5, 3]);
    });

    testWidgets('désactive « − » au minimum et expose une valeur ajustable', (tester) async {
      final handle = tester.ensureSemantics();
      final changes = await pumpStepper(tester, 1);

      await tester.tap(find.byTooltip('Retirer une portion'));
      expect(changes, isEmpty);

      final node = tester.getSemantics(find.bySemanticsLabel('Portions'));
      expect(node.value, '1 personne');
      expect(node.getSemanticsData().hasAction(SemanticsAction.increase), isTrue);
      expect(node.getSemanticsData().hasAction(SemanticsAction.decrease), isFalse);
      handle.dispose();
    });
  });
}
