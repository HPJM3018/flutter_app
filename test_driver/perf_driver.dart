import 'package:integration_test/integration_test_driver.dart';

/// Écrit le résumé des frames dans `build/scrolling.json`
/// pour `flutter drive --profile` (voir integration_test/performance_test.dart).
Future<void> main() => integrationDriver(
  responseDataCallback: (data) async {
    if (data != null) {
      await writeResponseData(data, testOutputFilename: 'scrolling');
    }
  },
);
