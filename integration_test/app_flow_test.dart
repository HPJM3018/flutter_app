import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miam/features/recipes/presentation/recipes_screen.dart';

import 'support/harness.dart';

/// Parcours utilisateur principal, de l'installation à la liste de courses,
/// avec redémarrage pour vérifier la persistance.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('onboarding → recherche → favori → courses → redémarrage', (tester) async {
    resetStorage();
    await launchApp(tester);

    // 1. Premier lancement : l'introduction s'affiche.
    expect(find.text('Des recettes qui donnent faim'), findsOneWidget);
    await tester.tap(find.text('Passer'));
    await tester.pumpAndSettle();

    // 2. Le vrai catalogue est chargé depuis les assets (décodé en isolate).
    await pumpUntilFound(tester, find.text('18 recettes'));

    // 3. Recherche insensible aux accents.
    await tester.enterText(find.byType(TextField), 'tatin');
    await tester.pump(RecipeSearchField.debounceDuration);
    await tester.pumpAndSettle();
    expect(find.text('1 recette'), findsOneWidget);

    // 4. Détail : favori + 8 portions au lieu de 6.
    await tester.tap(find.text('Tarte Tatin'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Ajouter aux favoris'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Retirer des favoris'), findsOneWidget);

    for (var i = 0; i < 2; i++) {
      await tester.tap(find.byTooltip('Ajouter une portion'));
      await tester.pump();
    }
    expect(find.text('8 personnes'), findsOneWidget);

    // 5. Ajout aux courses puis ouverture de la liste depuis la snackbar.
    await tester.scrollUntilVisible(
      find.text('Ajouter aux courses'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Ajouter aux courses'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Voir'));
    await tester.pumpAndSettle();

    expect(find.text('5 articles à acheter'), findsOneWidget);
    expect(find.text('Pommes'), findsOneWidget);
    expect(find.text('8'), findsOneWidget, reason: '6 pommes pour 6 → 8 pour 8');

    await tester.tap(find.text('Pommes'));
    await tester.pumpAndSettle();
    expect(find.text('4 articles à acheter'), findsOneWidget);

    // 6. Le favori apparaît dans l'onglet dédié.
    await tester.tap(find.text('Favoris'));
    await tester.pumpAndSettle();
    expect(find.text('Tarte Tatin'), findsOneWidget);

    // 7. Redémarrage à froid : pas d'onboarding, données conservées.
    await launchApp(tester);
    await pumpUntilFound(tester, find.text('Que cuisine-t-on ?'));
    await tester.tap(find.text('Courses'));
    await tester.pumpAndSettle();
    expect(find.text('4 articles à acheter'), findsOneWidget);
  });
}
