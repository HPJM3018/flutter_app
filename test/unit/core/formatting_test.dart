import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miam/core/app_info.dart';
import 'package:miam/core/images/image_urls.dart';
import 'package:miam/core/l10n/l10n.dart';
import 'package:miam/features/recipes/domain/quantity.dart';

void main() {
  final fr = lookupAppLocalizations(const Locale('fr'));
  final en = lookupAppLocalizations(const Locale('en'));

  group('Durées localisées', () {
    test('minutes, heures pleines et heures + minutes', () {
      expect(fr.duration(45), '45 min');
      expect(fr.duration(120), '2 h');
      expect(fr.duration(75), '1 h 15');
      expect(en.duration(75), '1 h 15 min');
    });
  });

  group('Quantités localisées', () {
    test('unités accordées au nombre et séparateur décimal', () {
      expect(fr.quantity(const Quantity(2, IngredientUnit.clove)), '2 gousses');
      expect(fr.quantity(const Quantity(1, IngredientUnit.clove)), '1 gousse');
      expect(en.quantity(const Quantity(1250, IngredientUnit.gram)), '1.25 kg');
      expect(fr.quantity(const Quantity(1250, IngredientUnit.gram)), '1,25 kg');
    });

    test('pièces sans unité, quantité libre traduite', () {
      expect(fr.quantity(const Quantity(1.5, IngredientUnit.piece)), '1½');
      expect(fr.quantity(null), 'selon votre goût');
      expect(en.quantity(null), 'to taste');
    });
  });

  group('ImageUrls', () {
    const url = 'https://www.themealdb.com/images/media/meals/abc.jpg';

    test('choisit la plus petite variante suffisante', () {
      expect(ImageUrls.forWidth(url, 120), '$url/small');
      expect(ImageUrls.forWidth(url, 300), '$url/medium');
      expect(ImageUrls.forWidth(url, 500), '$url/large');
      expect(ImageUrls.forWidth(url, 1200), url);
    });

    test('ne modifie pas les autres hôtes ni une largeur inconnue', () {
      expect(ImageUrls.forWidth('https://example.com/a.jpg', 100), 'https://example.com/a.jpg');
      expect(ImageUrls.forWidth(url, null), url);
    });

    test('arrondit la largeur de décodage au palier supérieur', () {
      expect(ImageUrls.bucketWidth(170, 2.625), 500); // 447 px → 500
      expect(ImageUrls.bucketWidth(100, 1), 100);
    });
  });

  test('AppInfo.version reste synchronisée avec pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final version = RegExp(r'^version:\s*([\d.]+)', multiLine: true).firstMatch(pubspec)!.group(1);
    expect(AppInfo.version, version);
  });
}
