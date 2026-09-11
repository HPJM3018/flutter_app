import 'package:flutter_test/flutter_test.dart';
import 'package:miam/core/router/app_router.dart';

import '../helpers/pump_app.dart';

/// Vérifie les recommandations d'accessibilité Android / iOS / WCAG sur
/// chaque écran : cibles tactiles ≥ 48 dp, éléments interactifs libellés,
/// contraste du texte suffisant.
void main() {
  final screens = <String, String>{
    'catalogue': AppRoutes.recipes,
    'détail': AppRoutes.recipeDetail('crepes'),
    'mode cuisine': AppRoutes.cookingMode('crepes'),
    'favoris': AppRoutes.favorites,
    'liste de courses': AppRoutes.shoppingList,
    'réglages': AppRoutes.settings,
  };

  for (final MapEntry(key: name, value: location) in screens.entries) {
    testWidgets('écran $name : recommandations d’accessibilité', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpMiamApp(tester, initialLocation: location);

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });
  }

  testWidgets('onboarding : recommandations d’accessibilité', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpMiamApp(tester, onboarded: false);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    handle.dispose();
  });
}
