import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:miam/features/recipes/presentation/recipes_screen.dart';

import 'support/harness.dart';

/// Mesure le temps de construction des frames pendant un défilement rapide
/// du catalogue. Le budget d'une frame à 60 fps est de 16,7 ms.
///
/// En local, pour des chiffres représentatifs (mode profile) :
///   flutter drive --profile -d linux \
///     --driver=test_driver/perf_driver.dart \
///     --target=integration_test/performance_test.dart
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('défilement du catalogue sous le budget de 16 ms', (tester) async {
    resetStorage(onboarded: true);
    await launchApp(tester);
    await pumpUntilFound(tester, find.text('18 recettes'));

    final grid = find.byKey(RecipesScreen.scrollViewKey);
    await binding.watchPerformance(() async {
      for (var i = 0; i < 3; i++) {
        await tester.fling(grid, const Offset(0, -1500), 4000);
        await tester.pumpAndSettle();
        await tester.fling(grid, const Offset(0, 1500), 4000);
        await tester.pumpAndSettle();
      }
    }, reportKey: 'scrolling');

    final summary = binding.reportData!['scrolling'] as Map<String, dynamic>;
    debugPrint('Résumé des frames : $summary');

    final frameCount = summary['frame_count'] as num;
    final averageBuild = summary['average_frame_build_time_millis'] as num;
    final p99Build = summary['99th_percentile_frame_build_time_millis'] as num;
    final missedBuild = summary['missed_frame_build_budget_count'] as num;

    // Seuils sur le thread UI (construction + layout) : c'est ce que le code
    // de l'application contrôle. La rasterisation dépend du GPU de la
    // machine (rendu logiciel sous Xvfb en CI) et n'est que rapportée.
    if (kDebugMode) {
      // En debug (JIT, assertions), seules les régressions grossières sont
      // détectables : les chiffres réels se mesurent en mode profile.
      expect(averageBuild, lessThan(8), reason: 'construction moyenne (debug)');
    } else {
      expect(p99Build, lessThan(16.7), reason: '99e centile de construction');
      expect(missedBuild / frameCount, lessThan(0.01), reason: 'frames hors budget');
    }
  });
}
