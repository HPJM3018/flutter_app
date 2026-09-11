/// Choix de la variante d'image la plus légère adaptée à l'affichage.
///
/// TheMealDB expose chaque photo en plusieurs tailles via un suffixe :
/// `/small` (150 px), `/medium` (350 px), `/large` (500 px) et l'original
/// (700 px). Télécharger 46 Ko au lieu de 145 Ko pour une vignette réduit
/// la bande passante, le temps de décodage et la mémoire.
abstract final class ImageUrls {
  static const _variants = <(int, String)>[(150, '/small'), (350, '/medium'), (500, '/large')];

  static bool _supportsVariants(Uri uri) => uri.host.endsWith('themealdb.com');

  /// URL de la plus petite variante couvrant [targetPixelWidth] pixels
  /// physiques. Sans largeur connue ou pour un autre hôte, l'URL est
  /// renvoyée telle quelle.
  static String forWidth(String url, int? targetPixelWidth) {
    final uri = Uri.tryParse(url);
    if (uri == null || targetPixelWidth == null || !_supportsVariants(uri)) {
      return url;
    }
    for (final (maxWidth, suffix) in _variants) {
      if (targetPixelWidth <= maxWidth) return '$url$suffix';
    }
    return url;
  }

  /// Arrondit une largeur de décodage au palier supérieur de [step] pixels
  /// pour limiter le nombre de variantes en cache mémoire.
  static int bucketWidth(double logicalWidth, double devicePixelRatio, {int step = 100}) {
    final physical = (logicalWidth * devicePixelRatio).ceil();
    return ((physical + step - 1) ~/ step) * step;
  }
}
