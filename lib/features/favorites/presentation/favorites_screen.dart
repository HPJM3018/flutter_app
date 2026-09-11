import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/images/recipe_image.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/status_views.dart';
import '../../recipes/application/recipe_providers.dart';
import '../../recipes/domain/recipe.dart';
import '../../recipes/presentation/widgets/recipe_meta.dart';
import '../application/favorites_providers.dart';
import 'favorite_button.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final favorites = ref.watch(favoriteRecipesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.favoritesTitle)),
      body: favorites.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(
          message: l10n.errorRecipesMessage,
          onRetry: () => ref.invalidate(recipesProvider),
        ),
        data: (recipes) {
          if (recipes.isEmpty) {
            return MessageView(
              icon: Icons.favorite_border_rounded,
              title: l10n.favoritesEmptyTitle,
              message: l10n.favoritesEmptyMessage,
              actionLabel: l10n.browseRecipes,
              onAction: () => context.go(AppRoutes.recipes),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: recipes.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return _FavoriteTile(key: ValueKey(recipe.id), recipe: recipe);
            },
          );
        },
      ),
    );
  }
}

class _FavoriteTile extends ConsumerWidget {
  const _FavoriteTile({required this.recipe, super.key});

  final Recipe recipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final title = context.tr(recipe.title);

    void removeWithUndo() {
      final notifier = ref.read(favoritesProvider.notifier);
      notifier.remove(recipe.id);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            // Avec une action, Material garde la snackbar affichée par défaut ;
            // on veut qu'elle disparaisse seule après quelques secondes.
            persist: false,
            content: Text(l10n.favoriteRemoved(title)),
            action: SnackBarAction(label: l10n.undo, onPressed: () => notifier.toggle(recipe.id)),
          ),
        );
    }

    return Dismissible(
      key: ValueKey('dismiss-${recipe.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => removeWithUndo(),
      background: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Icon(Icons.delete_outline, color: colorScheme.onErrorContainer),
          ),
        ),
      ),
      child: Card(
        child: ListTile(
          contentPadding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
          onTap: () => context.push(AppRoutes.recipeDetail(recipe.id)),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox.square(dimension: 56, child: RecipeImage(url: recipe.imageUrl)),
          ),
          title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: RecipeMetaRow(recipe: recipe),
          // Alternative accessible au balayage : le cœur retire le favori.
          trailing: FavoriteButton(recipeId: recipe.id),
        ),
      ),
    );
  }
}
