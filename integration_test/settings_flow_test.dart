import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';

import 'support/harness.dart';

/// Internationalisation et thème appliqués à toute l'application,
/// contenu des recettes compris.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('passer en anglais et en thème sombre, puis revoir l’introduction', (tester) async {
    resetStorage(onboarded: true);
    await launchApp(tester);
    await pumpUntilFound(tester, find.text('Ratatouille provençale'));

    await tester.tap(find.text('Réglages'));
    await tester.pumpAndSettle();

    // Langue : l'interface et le contenu basculent immédiatement.
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsWidgets);
    expect(find.text('Recipes'), findsOneWidget);

    // Thème sombre.
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(Theme.of(tester.element(find.text('Appearance'))).brightness, Brightness.dark);

    await tester.tap(find.text('Recipes'));
    await tester.pumpAndSettle();
    expect(find.text("What's cooking?"), findsOneWidget);
    expect(find.text('Provençal ratatouille'), findsOneWidget);
    expect(find.text('Ratatouille provençale'), findsNothing);

    // L'introduction peut être rejouée, dans la nouvelle langue.
    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Replay introduction'), 200);
    await tester.tap(find.text('Replay introduction'));
    await tester.pumpAndSettle();
    expect(find.text('Recipes that make you hungry'), findsOneWidget);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.text("What's cooking?"), findsOneWidget);
  });
}
