# Changelog

Toutes les évolutions notables de Miam sont documentées ici.

Format : [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/) ·
Versions : [Semantic Versioning](https://semver.org/lang/fr/). Le numéro de
build (`+N` dans `pubspec.yaml`) augmente à chaque version publiée.

## [Non publié]

### Prévu
- Keystore de production et job de publication (Play Store interne).
- Remontée des erreurs en production (Sentry ou Crashlytics).

## [1.0.0] - 2026-09-11 — Production-ready

### Ajouté
- Suite de tests complète : 59 tests unitaires, 33 tests de widgets et 3 tests
  d'intégration (parcours complet avec redémarrage à froid, langue et thème,
  performance du défilement).
- Audit d'accessibilité automatisé sur chaque écran (cibles tactiles,
  libellés, contraste).
- CI GitHub Actions : formatage, `flutter analyze --fatal-infos`, tests avec
  seuil de couverture de 85 %, tests d'intégration sous Xvfb, mesure des
  frames en mode profile, builds APK et Web.
- `tool/check_coverage.dart` : couverture hors code généré.
- Générateur de captures d'écran (`integration_test/screenshots/`).
- Dependabot pour les paquets pub et les actions GitHub.
- Raccourcis clavier ← / → dans le mode cuisine.

### Modifié
- Migration de `package:flutter/material.dart` vers `package:material_ui`
  (Flutter 3.44), aligné sur go_router 18.
- Recherche : `SearchBar` remplacé par un `TextField`, dont la zone tactile
  sémantique fait 56 dp au lieu de 24 dp.
- Analyse statique renforcée (`strict-casts`, `strict-inference`,
  `strict-raw-types` et 30 règles de lint en plus).

### Corrigé
- Les snackbars avec action (« Annuler », « Voir ») ne disparaissaient jamais
  et suivaient l'utilisateur d'un écran à l'autre (`persist: false`).
- Permission `INTERNET` absente du manifeste Android principal : pas de photos
  en build release.

### Performance
- Décodage des images à la taille affichée (`ResizeImage`, paliers de 100 px)
  et choix de la variante serveur la plus légère.
- Décodage du catalogue JSON dans un isolate, avec cache.
- APK release par ABI, obfusqué et sans infos DWARF : 16 à 20 Mo au lieu
  de 52 Mo pour l'APK universel.
- Rebuilds ciblés via `select` : favori par recette, badge du panier,
  thème et langue de `MaterialApp`.
- Mesuré en mode profile : 0 frame hors budget sur 230, 99e centile de
  construction à 3,8 ms.

## [0.3.0] - 2026-09-11 — Internationalisation et accessibilité

### Ajouté
- Interface en français et en anglais (`gen-l10n`, ARB avec descriptions,
  pluriels ICU).
- Contenu des recettes bilingue (`LocalizedText`) avec repli sur l'anglais.
- Choix de la langue (appareil / français / anglais) et du thème (auto /
  clair / sombre) dans les réglages, persistés.
- Formatage localisé des nombres, durées (`1 h 15`) et unités accordées
  (`1 gousse`, `2 gousses`).
- Libellés sémantiques : cartes lues d'un bloc, favori annoncé comme
  interrupteur, portions exposées comme un curseur ajustable, zones
  `liveRegion`, titres `header`.
- Écran d'introduction (3 pages), rejouable depuis les réglages.
- Navigation adaptative : `NavigationRail` à partir de 840 dp.

## [0.2.0] - 2026-09-11 — Favoris et liste de courses

### Ajouté
- Favoris persistés, avec balayage pour retirer et « Annuler ».
- Liste de courses : ajout des ingrédients d'une recette pour le nombre de
  portions choisi, fusion d'un même ingrédient entre recettes avec conversion
  d'unités (g ↔ kg, ml ↔ l), articles cochés en bas, badge dans la navigation.
- Mode cuisine pas-à-pas.
- Persistance locale via `shared_preferences`, résistante aux données
  corrompues.

## [0.1.0] - 2026-09-11 — Première version

### Ajouté
- Catalogue de 18 recettes embarqué (`assets/data/recipes.json`).
- Recherche sans accents et filtres (rapide, végétarien, catégorie).
- Fiche recette : temps, difficulté, ingrédients, étapes.
- Ajustement des portions (1 à 24) avec quantités recalculées et arrondies
  (1 250 g → 1,25 kg, fractions ½ ¼ ¾).
- Architecture par fonctionnalité : Riverpod 3, flutter_hooks, go_router.

[Non publié]: https://github.com/HPJM3018/flutter_app/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/HPJM3018/flutter_app/compare/v0.3.0...v1.0.0
[0.3.0]: https://github.com/HPJM3018/flutter_app/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/HPJM3018/flutter_app/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/HPJM3018/flutter_app/releases/tag/v0.1.0
