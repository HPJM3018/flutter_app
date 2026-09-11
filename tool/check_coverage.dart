// Vérifie la couverture de `coverage/lcov.info` (hors code généré).
//
//   flutter test --coverage
//   dart run tool/check_coverage.dart 80
//
// Sort avec le code 1 si la couverture est sous le seuil (80 % par défaut).
// ignore_for_file: avoid_print
import 'dart:io';

const _excludedPrefixes = ['lib/l10n/generated/'];

void main(List<String> args) {
  final threshold = args.isEmpty ? 80.0 : double.parse(args.first);
  final file = File('coverage/lcov.info');
  if (!file.existsSync()) {
    stderr.writeln('coverage/lcov.info introuvable : lancez `flutter test --coverage`.');
    exit(2);
  }

  final perFile = <String, (int hit, int total)>{};
  String? current;
  for (final line in file.readAsLinesSync()) {
    if (line.startsWith('SF:')) {
      current = line.substring(3);
    } else if (line.startsWith('DA:') && current != null) {
      final hits = int.parse(line.substring(3).split(',')[1]);
      final (hit, total) = perFile[current] ?? (0, 0);
      perFile[current] = (hit + (hits > 0 ? 1 : 0), total + 1);
    }
  }

  var hit = 0;
  var total = 0;
  for (final MapEntry(key: path, value: (fileHit, fileTotal)) in perFile.entries) {
    if (_excludedPrefixes.any(path.startsWith)) continue;
    hit += fileHit;
    total += fileTotal;
  }

  final percent = total == 0 ? 0.0 : hit * 100 / total;
  print('Couverture : ${percent.toStringAsFixed(1)} % ($hit/$total lignes), seuil $threshold %');
  if (percent < threshold) exit(1);
}
