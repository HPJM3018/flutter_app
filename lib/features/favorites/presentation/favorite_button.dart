import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n.dart';
import '../application/favorites_providers.dart';

/// Cœur favori. N'écoute que le statut de *sa* recette (`isFavoriteProvider`)
/// pour que basculer un favori ne reconstruise pas toute la grille.
class FavoriteButton extends ConsumerWidget {
  const FavoriteButton({required this.recipeId, this.filled = false, super.key});

  final String recipeId;

  /// Fond tonal, pour rester lisible par-dessus une photo.
  final bool filled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(isFavoriteProvider(recipeId));
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final tooltip = isFavorite ? l10n.removeFromFavorites : l10n.addToFavorites;

    void toggle() => ref.read(favoritesProvider.notifier).toggle(recipeId);

    final icon = AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
      child: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        key: ValueKey(isFavorite),
        color: isFavorite ? colorScheme.primary : null,
      ),
    );

    // `tooltip` fournit aussi le libellé accessible ; `toggled` annonce
    // l'état « activé / désactivé » au lecteur d'écran.
    return Semantics(
      toggled: isFavorite,
      child: filled
          ? IconButton.filledTonal(
              onPressed: toggle,
              tooltip: tooltip,
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.surfaceContainerLowest.withValues(alpha: 0.9),
              ),
              icon: icon,
            )
          : IconButton(onPressed: toggle, tooltip: tooltip, icon: icon),
    );
  }
}
