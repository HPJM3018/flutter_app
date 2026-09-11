import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miam/core/router/app_router.dart';
import 'package:miam/features/shopping_list/application/shopping_list_providers.dart';
import 'package:miam/features/shopping_list/presentation/shopping_list_screen.dart';

import '../helpers/pump_app.dart';

void main() {
  setUp(() {
    // Écran haut : tous les ingrédients sont visibles sans défilement.
    final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(800, 1400);
    view.devicePixelRatio = 1;
    addTearDown(view.reset);
  });

  testWidgets('les quantités suivent le nombre de portions', (tester) async {
    await pumpMiamApp(tester, initialLocation: AppRoutes.recipeDetail('crepes'));

    expect(find.text('4 personnes'), findsOneWidget);
    expect(find.text('250 g'), findsOneWidget);
    expect(find.text('500 ml'), findsOneWidget);

    await tester.tap(find.byTooltip('Retirer une portion'));
    await tester.pump();
    await tester.tap(find.byTooltip('Retirer une portion'));
    await tester.pump();

    expect(find.text('2 personnes'), findsOneWidget);
    expect(find.text('125 g'), findsOneWidget);
    expect(find.text('1½'), findsOneWidget); // 3 œufs pour 4 → 1½ pour 2
    expect(find.text('selon votre goût'), findsOneWidget);
  });

  testWidgets('ajoute les ingrédients aux courses et propose de les voir', (tester) async {
    final container = await pumpMiamApp(tester, initialLocation: AppRoutes.recipeDetail('crepes'));

    await tester.scrollUntilVisible(find.text('Ajouter aux courses'), 200);
    await tester.tap(find.text('Ajouter aux courses'));
    await tester.pumpAndSettle();

    expect(container.read(shoppingListProvider).items, hasLength(4));
    expect(find.text('4 ingrédients ajoutés aux courses'), findsOneWidget);

    await tester.tap(find.text('Voir'));
    await tester.pumpAndSettle();
    expect(find.byType(ShoppingListScreen), findsOneWidget);
    expect(find.text('4 articles à acheter'), findsOneWidget);
  });

  testWidgets('la confirmation d’ajout disparaît seule malgré son action', (tester) async {
    await pumpMiamApp(tester, initialLocation: AppRoutes.recipeDetail('crepes'));

    await tester.tap(find.text('Ajouter aux courses'));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('recette inconnue : message dédié', (tester) async {
    await pumpMiamApp(tester, initialLocation: AppRoutes.recipeDetail('inexistante'));

    expect(find.text('Cette recette est introuvable.'), findsOneWidget);
    expect(find.text('Parcourir les recettes'), findsOneWidget);
  });

  testWidgets('mode cuisine : navigation entre les étapes puis fin', (tester) async {
    await pumpMiamApp(tester, initialLocation: AppRoutes.recipeDetail('crepes'));

    await tester.tap(find.text('Mode cuisine'));
    await tester.pumpAndSettle();
    expect(find.text('Mélanger la farine et les œufs.'), findsOneWidget);

    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
    expect(find.text('Ajouter le lait progressivement.'), findsOneWidget);

    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
    expect(find.text('Étape 3 sur 3'), findsWidgets);

    await tester.tap(find.text('Terminer'));
    await tester.pumpAndSettle();
    expect(find.text('Bon appétit !'), findsOneWidget);
    expect(find.text('Ingrédients'), findsOneWidget, reason: 'retour au détail');
  });
}
