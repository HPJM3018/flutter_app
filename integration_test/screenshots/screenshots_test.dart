import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miam/main.dart';

import '../support/harness.dart';

/// Génère les captures d'écran du README (vraies photos, réseau requis).
///
///   flutter test integration_test/screenshots/screenshots_test.dart -d linux \
///     --dart-define=SCREENSHOT_DIR=$PWD/docs/screenshots
///
/// Ignoré sans `SCREENSHOT_DIR` : il ne tourne jamais en CI.
const _outputDir = String.fromEnvironment('SCREENSHOT_DIR');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final boundaryKey = GlobalKey();

  Future<void> settle(WidgetTester tester, {Duration wait = const Duration(seconds: 2)}) async {
    // Laisse le temps aux photos d'arriver du réseau puis de s'afficher.
    await tester.pumpAndSettle();
    await Future<void>.delayed(wait);
    await tester.pumpAndSettle();
  }

  Future<void> capture(WidgetTester tester, String name) async {
    await settle(tester, wait: const Duration(milliseconds: 600));
    final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(boundaryKey));
    final image = await boundary.toImage(pixelRatio: tester.view.devicePixelRatio);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await File('$_outputDir/$name.png').writeAsBytes(bytes!.buffer.asUint8List());
  }

  testWidgets('captures d’écran', skip: _outputDir.isEmpty, (tester) async {
    Directory(_outputDir).createSync(recursive: true);
    // Format téléphone (390 × 844 dp) rendu en 2,5×.
    tester.view.physicalSize = const Size(975, 2110);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);

    resetStorage();
    final app = await bootstrap();
    await tester.pumpWidget(RepaintBoundary(key: boundaryKey, child: app));

    await capture(tester, '01_onboarding');
    await tester.tap(find.text('Passer'));
    await settle(tester, wait: const Duration(seconds: 4));
    await capture(tester, '02_recettes');

    await tester.tap(find.text('Ratatouille provençale'));
    await settle(tester);
    await capture(tester, '03_detail');

    await tester.tap(find.byTooltip('Ajouter aux favoris'));
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -520));
    await settle(tester, wait: Duration.zero);
    await capture(tester, '04_ingredients');

    await tester.tap(find.text('Ajouter aux courses'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mode cuisine'));
    await settle(tester, wait: const Duration(seconds: 5));
    await tester.tap(find.text('Suivant'));
    await capture(tester, '05_mode_cuisine');

    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Courses'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aubergine'));
    await capture(tester, '06_courses');

    await tester.tap(find.text('Favoris'));
    await capture(tester, '07_favoris');

    await tester.tap(find.text('Réglages'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
    await capture(tester, '08_settings_dark_en');

    await tester.tap(find.text('Recipes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quick'));
    await capture(tester, '09_recipes_dark_en');
  });
}
