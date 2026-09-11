import 'package:material_ui/material_ui.dart';

import '../../../../core/images/recipe_image.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../favorites/presentation/favorite_button.dart';
import '../../domain/recipe.dart';
import 'recipe_meta.dart';

/// Carte de la grille. `StatelessWidget` pur : seule la [FavoriteButton]
/// qu'elle contient réagit à l'état global.
class RecipeCard extends StatelessWidget {
  const RecipeCard({required this.recipe, required this.onTap, super.key});

  final Recipe recipe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final title = context.tr(recipe.title);
    final semanticsLabel = l10n.recipeCardSemantics(
      title,
      l10n.duration(recipe.totalMinutes),
      recipe.difficulty.label(l10n),
    );

    return Stack(
      children: [
        Positioned.fill(
          child: Card(
            child: Semantics(
              button: true,
              label: semanticsLabel,
              excludeSemantics: true,
              onTap: onTap,
              child: InkWell(
                onTap: onTap,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: RecipeImage(url: recipe.imageUrl)),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleSmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          RecipeMetaRow(recipe: recipe),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(top: 4, right: 4, child: FavoriteButton(recipeId: recipe.id, filled: true)),
      ],
    );
  }
}
