import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/images/recipe_image.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/status_views.dart';
import '../../favorites/presentation/favorite_button.dart';
import '../../shopping_list/application/shopping_list_providers.dart';
import '../application/recipe_providers.dart';
import '../data/recipe_repository.dart';
import '../domain/recipe.dart';
import 'widgets/servings_stepper.dart';

class RecipeDetailScreen extends ConsumerWidget {
  const RecipeDetailScreen({required this.recipeId, super.key});

  final String recipeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return ref
        .watch(recipeProvider(recipeId))
        .when(
          data: (recipe) => _RecipeDetailView(recipe: recipe),
          loading: () => Scaffold(appBar: AppBar(), body: const LoadingView()),
          error: (error, _) => Scaffold(
            appBar: AppBar(),
            body: error is RecipeNotFoundException
                ? MessageView(
                    icon: Icons.no_meals_outlined,
                    title: l10n.recipeNotFound,
                    actionLabel: l10n.browseRecipes,
                    onAction: () => context.go(AppRoutes.recipes),
                  )
                : ErrorView(
                    message: l10n.errorRecipesMessage,
                    onRetry: () => ref.invalidate(recipesProvider),
                  ),
          ),
        );
  }
}

class _RecipeDetailView extends HookConsumerWidget {
  const _RecipeDetailView({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final title = context.tr(recipe.title);

    final servings = useState(recipe.servings);
    // Recalcul uniquement quand le nombre de portions change.
    final ingredients = useMemoized(() => recipe.ingredientsFor(servings.value), [
      recipe,
      servings.value,
    ]);

    Future<void> addToShoppingList() async {
      final messenger = ScaffoldMessenger.of(context);
      final router = GoRouter.of(context);
      await ref.read(shoppingListProvider.notifier).addRecipe(recipe, servings: servings.value);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            // Avec une action, Material garde la snackbar affichée par défaut ;
            // on veut qu'elle disparaisse seule après quelques secondes.
            persist: false,
            content: Text(l10n.addedToShoppingList(ingredients.length)),
            action: SnackBarAction(
              label: l10n.view,
              onPressed: () => router.go(AppRoutes.shoppingList),
            ),
          ),
        );
    }

    final overlayButtonStyle = IconButton.styleFrom(
      backgroundColor: theme.colorScheme.surfaceContainerLowest.withValues(alpha: 0.9),
    );

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.cookingMode(recipe.id)),
        icon: const Icon(Icons.play_arrow_rounded),
        label: Text(l10n.startCooking),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 840),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                stretch: true,
                expandedHeight: 280,
                leading: Padding(
                  padding: const EdgeInsets.all(4),
                  child: BackButton(style: overlayButtonStyle),
                ),
                actions: [
                  FavoriteButton(recipeId: recipe.id, filled: true),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: RecipeImage(
                    url: recipe.imageUrl,
                    semanticLabel: l10n.recipeImageSemantics(title),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                sliver: SliverList.list(
                  children: [
                    Semantics(
                      header: true,
                      child: Text(title, style: theme.textTheme.headlineSmall),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.tr(recipe.description),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoChip(
                          icon: Icons.timer_outlined,
                          label: '${l10n.prepTime} · ${l10n.duration(recipe.prepMinutes)}',
                        ),
                        if (recipe.cookMinutes > 0)
                          _InfoChip(
                            icon: Icons.local_fire_department_outlined,
                            label: '${l10n.cookTime} · ${l10n.duration(recipe.cookMinutes)}',
                          ),
                        _InfoChip(
                          icon: Icons.signal_cellular_alt_rounded,
                          label: '${l10n.difficultyLabel} · ${recipe.difficulty.label(l10n)}',
                        ),
                        if (recipe.isVegetarian)
                          _InfoChip(icon: Icons.eco_outlined, label: l10n.filterVegetarian),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      runSpacing: 8,
                      children: [
                        _SectionTitle(l10n.ingredientsTitle),
                        ServingsStepper(
                          servings: servings.value,
                          onChanged: (value) => servings.value = value,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList.separated(
                  itemCount: ingredients.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final ingredient = ingredients[index];
                    return _IngredientRow(
                      name: context.tr(ingredient.name),
                      quantity: l10n.quantity(ingredient.amount),
                    );
                  },
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                sliver: SliverToBoxAdapter(
                  child: FilledButton.tonalIcon(
                    onPressed: addToShoppingList,
                    icon: const Icon(Icons.add_shopping_cart),
                    label: Text(l10n.addToShoppingList),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(child: _SectionTitle(l10n.stepsTitle)),
              ),
              SliverPadding(
                // Marge basse pour ne pas masquer la dernière étape sous le FAB.
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 112),
                sliver: SliverList.builder(
                  itemCount: recipe.steps.length,
                  itemBuilder: (context, index) =>
                      _StepTile(number: index + 1, text: context.tr(recipe.steps[index])),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(text, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: colorScheme.onSecondaryContainer),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: colorScheme.onSecondaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({required this.name, required this.quantity});

  final String name;
  final String quantity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(name, style: theme.textTheme.bodyLarge)),
            const SizedBox(width: 16),
            Text(
              quantity,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: context.l10n.stepNumber(number),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: CircleAvatar(
                radius: 16,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  '$number',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: theme.textTheme.bodyLarge)),
          ],
        ),
      ),
    );
  }
}
