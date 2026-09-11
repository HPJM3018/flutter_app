import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/misc.dart';
import 'package:miam/core/images/recipe_image.dart';
import 'package:miam/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../test/helpers/fakes.dart';

/// Images en mémoire : les parcours ne dépendent pas du réseau en CI.
final offlineImages = <Override>[
  recipeImageProviderBuilderProvider.overrideWithValue(testImageProviderBuilder),
];

/// Réinitialise le stockage : chaque test démarre comme une installation
/// neuve, en français, quelle que soit la langue de la machine.
void resetStorage({bool onboarded = false, String languageCode = 'fr'}) {
  SharedPreferences.setMockInitialValues({
    'settings.language': languageCode,
    'settings.onboarding_completed': onboarded,
  });
}

/// Lance l'application réelle (vrai catalogue, vrai routeur, vraie
/// persistance). La clé unique force un démarrage à froid, ce qui permet de
/// simuler un redémarrage dans un même test.
Future<void> launchApp(WidgetTester tester, {List<Override> overrides = const []}) async {
  final app = await bootstrap(overrides: [...offlineImages, ...overrides]);
  await tester.pumpWidget(KeyedSubtree(key: UniqueKey(), child: app));
  await tester.pumpAndSettle();
}

/// Attend qu'un élément apparaisse (chargement asynchrone réel, isolate…).
Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final end = DateTime.now().add(timeout);
  while (finder.evaluate().isEmpty) {
    if (DateTime.now().isAfter(end)) {
      throw TestFailure('Introuvable après $timeout : $finder');
    }
    await tester.pump(const Duration(milliseconds: 100));
  }
}
