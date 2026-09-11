import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miam/features/recipes/data/recipe_repository.dart';
import 'package:miam/features/recipes/presentation/recipe_detail_screen.dart';
import 'package:miam/features/recipes/presentation/recipes_screen.dart';
import 'package:miam/features/recipes/presentation/widgets/recipe_card.dart';

import '../helpers/fakes.dart';
import '../helpers/pump_app.dart';
import '../helpers/test_data.dart';

void main() {
  testWidgets('affiche le catalogue et le nombre de recettes', (tester) async {
    await pumpMiamApp(tester);

    expect(find.text('Que cuisine-t-on ?'), findsOneWidget);
    expect(find.text('4 recettes'), findsOneWidget);
    expect(find.byType(RecipeCard), findsNWidgets(4));
  });

  testWidgets('la recherche est appliquée après l’anti-rebond', (tester) async {
    await pumpMiamApp(tester);

    await tester.enterText(find.byType(TextField), 'boeuf');
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(RecipeCard), findsNWidgets(4), reason: 'pas encore filtré');

    await tester.pump(RecipeSearchField.debounceDuration);
    await tester.pumpAndSettle();
    expect(find.text('1 recette'), findsOneWidget);
    expect(find.text('Bœuf bourguignon'), findsOneWidget);
  });

  testWidgets('les filtres se combinent', (tester) async {
    await pumpMiamApp(tester);

    await tester.tap(find.widgetWithText(FilterChip, 'Rapide'));
    await tester.pumpAndSettle();
    expect(find.text('3 recettes'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilterChip, 'Végétarien'));
    await tester.pumpAndSettle();
    expect(find.text('2 recettes'), findsOneWidget);
    expect(find.text('Bœuf bourguignon'), findsNothing);
  });

  testWidgets('état vide puis réinitialisation des filtres et de la recherche', (tester) async {
    await pumpMiamApp(tester);

    await tester.enterText(find.byType(TextField), 'chocolat');
    await tester.pump(RecipeSearchField.debounceDuration);
    await tester.pumpAndSettle();

    expect(find.text('Aucune recette trouvée'), findsOneWidget);
    await tester.tap(find.text('Réinitialiser les filtres'));
    await tester.pumpAndSettle();

    expect(find.byType(RecipeCard), findsNWidgets(4));
    expect(find.text('chocolat'), findsNothing);
  });

  testWidgets('erreur de chargement puis nouvelle tentative réussie', (tester) async {
    final repository = FakeRecipeRepository(
      sampleRecipes,
      error: const RecipeParseException('réseau'),
    );
    await pumpMiamApp(tester, repository: repository);

    expect(find.text('Impossible de charger les recettes.'), findsOneWidget);

    repository.error = null;
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();

    expect(find.byType(RecipeCard), findsNWidgets(4));
    expect(repository.fetchCount, 2);
  });

  testWidgets('toucher une carte ouvre le détail', (tester) async {
    await pumpMiamApp(tester);

    await tester.tap(find.text('Salade niçoise'));
    await tester.pumpAndSettle();

    expect(find.byType(RecipeDetailScreen), findsOneWidget);
    expect(find.text('Description Salade niçoise'), findsOneWidget);
  });
}
