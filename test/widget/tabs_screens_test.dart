import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miam/core/router/app_router.dart';
import 'package:miam/features/favorites/application/favorites_providers.dart';
import 'package:miam/features/favorites/data/favorites_repository.dart';
import 'package:miam/features/settings/application/settings_providers.dart';
import 'package:miam/features/settings/domain/app_settings.dart';
import 'package:miam/features/shopping_list/application/shopping_list_providers.dart';
import 'package:miam/features/shopping_list/data/shopping_list_repository.dart';
import 'package:miam/features/shopping_list/domain/shopping_list.dart';

import '../helpers/pump_app.dart';
import '../helpers/test_data.dart';

void main() {
  group('Favoris', () {
    testWidgets('état vide avec lien vers le catalogue', (tester) async {
      await pumpMiamApp(tester, initialLocation: AppRoutes.favorites);

      expect(find.text('Pas encore de favoris'), findsOneWidget);
      await tester.tap(find.text('Parcourir les recettes'));
      await tester.pumpAndSettle();
      expect(find.text('Que cuisine-t-on ?'), findsOneWidget);
    });

    testWidgets('balayer retire un favori, « Annuler » le restaure', (tester) async {
      final container = await pumpMiamApp(
        tester,
        initialLocation: AppRoutes.favorites,
        preferences: {
          FavoritesRepository.storageKey: ['crepes', 'boeuf'],
        },
      );

      expect(find.text('Bœuf bourguignon'), findsOneWidget);
      await tester.drag(find.text('Bœuf bourguignon'), const Offset(-600, 0));
      await tester.pumpAndSettle();

      expect(container.read(favoritesProvider), {'crepes'});
      expect(find.text('« Bœuf bourguignon » retiré des favoris'), findsOneWidget);

      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      expect(container.read(favoritesProvider), containsAll(['crepes', 'boeuf']));
    });
  });

  group('Liste de courses', () {
    final list = const ShoppingList().addRecipe(buildRecipe(), servings: 4);

    testWidgets('cocher un article met à jour le résumé et le badge', (tester) async {
      final container = await pumpMiamApp(
        tester,
        initialLocation: AppRoutes.shoppingList,
        preferences: {ShoppingListRepository.storageKey: jsonEncode(list.toJson())},
      );

      expect(find.text('4 articles à acheter'), findsOneWidget);
      expect(find.text('250 g'), findsOneWidget);

      await tester.tap(find.text('Farine'));
      await tester.pumpAndSettle();

      expect(find.text('3 articles à acheter'), findsOneWidget);
      expect(container.read(shoppingRemainingCountProvider), 3);

      await tester.tap(find.byTooltip('Retirer les articles cochés'));
      await tester.pumpAndSettle();
      expect(find.text('Farine'), findsNothing);
    });

    testWidgets('vider la liste demande confirmation', (tester) async {
      await pumpMiamApp(
        tester,
        initialLocation: AppRoutes.shoppingList,
        preferences: {ShoppingListRepository.storageKey: jsonEncode(list.toJson())},
      );

      await tester.tap(find.byTooltip('Vider la liste'));
      await tester.pumpAndSettle();
      expect(find.text('Vider la liste de courses ?'), findsOneWidget);

      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      expect(find.text('Farine'), findsOneWidget);

      await tester.tap(find.byTooltip('Vider la liste'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Vider'));
      await tester.pumpAndSettle();
      expect(find.text('Votre liste est vide'), findsOneWidget);
    });
  });

  group('Réglages', () {
    testWidgets("changer de langue traduit toute l'interface", (tester) async {
      final container = await pumpMiamApp(tester, initialLocation: AppRoutes.settings);

      expect(find.text('Réglages'), findsWidgets);
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      expect(container.read(settingsProvider).language, LanguagePreference.english);
      expect(find.text('Settings'), findsWidgets);
      expect(find.text('Recipes'), findsOneWidget, reason: 'barre de navigation traduite');
    });

    testWidgets('choisir le thème sombre applique la luminosité sombre', (tester) async {
      await pumpMiamApp(tester, initialLocation: AppRoutes.settings);

      await tester.tap(find.text('Sombre'));
      await tester.pumpAndSettle();

      final context = tester.element(find.text('Apparence'));
      expect(Theme.of(context).brightness, Brightness.dark);
    });
  });

  group('Onboarding', () {
    testWidgets('au premier lancement, parcourt les pages puis ouvre le catalogue', (tester) async {
      final container = await pumpMiamApp(tester, onboarded: false);

      expect(find.text('Des recettes qui donnent faim'), findsOneWidget);
      expect(find.bySemanticsLabel('Page 1 sur 3'), findsOneWidget);

      await tester.tap(find.text('Suivant'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Suivant'));
      await tester.pumpAndSettle();
      await tester.tap(find.text("C'est parti !"));
      await tester.pumpAndSettle();

      expect(find.text('Que cuisine-t-on ?'), findsOneWidget);
      expect(container.read(settingsProvider).onboardingCompleted, isTrue);
    });

    testWidgets('« Passer » termine directement l’introduction', (tester) async {
      await pumpMiamApp(tester, onboarded: false);

      await tester.tap(find.text('Passer'));
      await tester.pumpAndSettle();

      expect(find.text('Que cuisine-t-on ?'), findsOneWidget);
    });
  });

  group('Navigation adaptative', () {
    testWidgets('barre en bas sur téléphone, rail latéral sur grand écran', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await pumpMiamApp(tester);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);

      tester.view.physicalSize = const Size(1200, 800);
      await tester.pumpAndSettle();
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);

      await tester.tap(find.text('Courses'));
      await tester.pumpAndSettle();
      expect(find.text('Votre liste est vide'), findsOneWidget);
    });
  });
}
