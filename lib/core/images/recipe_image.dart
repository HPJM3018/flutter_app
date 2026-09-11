import 'package:cached_network_image/cached_network_image.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'image_urls.dart';

/// Fabrique d'`ImageProvider` injectable : l'app utilise un cache disque
/// réseau, les tests une image en mémoire (aucun appel réseau).
typedef RecipeImageProviderBuilder = ImageProvider Function(String url, {int? cacheWidth});

ImageProvider _networkImageProvider(String url, {int? cacheWidth}) {
  // `ResizeImage` décode directement à la taille affichée : une vignette
  // de 170 dp n'occupe pas la mémoire d'une photo de 700 px.
  return ResizeImage.resizeIfNeeded(
    cacheWidth,
    null,
    CachedNetworkImageProvider(ImageUrls.forWidth(url, cacheWidth)),
  );
}

final recipeImageProviderBuilderProvider = Provider<RecipeImageProviderBuilder>(
  (ref) => _networkImageProvider,
  name: 'recipeImageProviderBuilderProvider',
);

/// Image de recette optimisée :
/// - taille de décodage calculée depuis la largeur réelle × densité d'écran ;
/// - variante serveur la plus légère suffisante ;
/// - cache disque (hors-ligne après la première visite) ;
/// - fondu à l'apparition, sans reconstruire le parent.
class RecipeImage extends ConsumerWidget {
  const RecipeImage({required this.url, this.semanticLabel, super.key});

  final String url;

  /// `null` pour une image décorative (ignorée par le lecteur d'écran).
  final String? semanticLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final builder = ref.watch(recipeImageProviderBuilderProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cacheWidth = constraints.hasBoundedWidth
            ? ImageUrls.bucketWidth(constraints.maxWidth, devicePixelRatio)
            : null;
        return Image(
          image: builder(url, cacheWidth: cacheWidth),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          semanticLabel: semanticLabel,
          excludeFromSemantics: semanticLabel == null,
          gaplessPlayback: true,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) return child;
            return ColoredBox(
              color: colorScheme.surfaceContainerHighest,
              child: AnimatedOpacity(
                opacity: frame == null ? 0 : 1,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                child: child,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => ColoredBox(
            color: colorScheme.surfaceContainerHighest,
            child: Center(
              child: Icon(Icons.restaurant_rounded, size: 40, color: colorScheme.onSurfaceVariant),
            ),
          ),
        );
      },
    );
  }
}
