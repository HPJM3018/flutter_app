import 'dart:async';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/status_views.dart';
import '../application/recipe_providers.dart';
import '../domain/recipe.dart';
import 'widgets/recipe_card.dart';

/// Catalogue : recherche, filtres et grille de recettes.
///
/// L'écran lui-même est constant ; chaque zone (recherche, filtres,
/// résultats) écoute uniquement l'état dont elle a besoin.
class RecipesScreen extends StatelessWidget {
  const RecipesScreen({super.key});

  static const scrollViewKey = Key('recipes-scroll-view');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        key: scrollViewKey,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            title: Semantics(header: true, child: Text(context.l10n.recipesTitle)),
          ),
          const SliverToBoxAdapter(
            child: Padding(padding: EdgeInsets.fromLTRB(16, 4, 16, 8), child: RecipeSearchField()),
          ),
          const SliverToBoxAdapter(child: RecipeFilterBar()),
          const _RecipeResults(),
        ],
      ),
    );
  }
}

/// Champ de recherche avec anti-rebond de 300 ms : on ne filtre pas à
/// chaque frappe, et seul ce widget se reconstruit pendant la saisie.
class RecipeSearchField extends HookConsumerWidget {
  const RecipeSearchField({super.key});

  static const debounceDuration = Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final controller = useTextEditingController(text: ref.read(recipeQueryProvider).searchTerm);
    final hasText = useListenableSelector(controller, () => controller.text.isNotEmpty);

    useEffect(() {
      Timer? debounce;
      var lastText = controller.text;
      void onChanged() {
        if (controller.text == lastText) return; // simple déplacement du curseur
        lastText = controller.text;
        debounce?.cancel();
        debounce = Timer(debounceDuration, () {
          ref.read(recipeQueryProvider.notifier).setSearchTerm(controller.text);
        });
      }

      controller.addListener(onChanged);
      return () {
        debounce?.cancel();
        controller.removeListener(onChanged);
      };
    }, [controller]);

    // « Réinitialiser les filtres » vide aussi le champ.
    ref.listen(recipeQueryProvider.select((query) => query.searchTerm), (_, term) {
      if (controller.text != term) controller.text = term;
    });

    // `TextField` plutôt que `SearchBar` : sa zone sémantique couvre tout
    // le champ (56 dp) et respecte la taille minimale des cibles tactiles.
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onSubmitted: (value) => ref.read(recipeQueryProvider.notifier).setSearchTerm(value),
      decoration: InputDecoration(
        hintText: l10n.searchHint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: hasText
            ? IconButton(
                tooltip: l10n.searchClear,
                icon: const Icon(Icons.close),
                onPressed: () {
                  controller.clear();
                  ref.read(recipeQueryProvider.notifier).setSearchTerm('');
                },
              )
            : null,
      ),
    );
  }
}

class RecipeFilterBar extends ConsumerWidget {
  const RecipeFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final query = ref.watch(recipeQueryProvider);
    final notifier = ref.read(recipeQueryProvider.notifier);

    final chips = <Widget>[
      FilterChip(
        label: Text(l10n.filterQuick),
        avatar: query.quickOnly ? null : const Icon(Icons.bolt),
        selected: query.quickOnly,
        onSelected: (_) => notifier.toggleQuick(),
      ),
      FilterChip(
        label: Text(l10n.filterVegetarian),
        avatar: query.vegetarianOnly ? null : const Icon(Icons.eco_outlined),
        selected: query.vegetarianOnly,
        onSelected: (_) => notifier.toggleVegetarian(),
      ),
      for (final category in RecipeCategory.values)
        FilterChip(
          label: Text(category.label(l10n)),
          selected: query.category == category,
          onSelected: (_) => notifier.toggleCategory(category),
        ),
    ];

    return Semantics(
      container: true,
      label: l10n.filtersLabel,
      explicitChildNodes: true,
      child: SizedBox(
        height: 56,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          itemCount: chips.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, index) => chips[index],
        ),
      ),
    );
  }
}

class _RecipeResults extends ConsumerWidget {
  const _RecipeResults();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final results = ref.watch(filteredRecipesProvider);

    return results.when(
      loading: () => const SliverFillRemaining(hasScrollBody: false, child: LoadingView()),
      error: (error, _) => SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorView(
          message: l10n.errorRecipesMessage,
          onRetry: () => ref.invalidate(recipesProvider),
        ),
      ),
      data: (recipes) {
        if (recipes.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: MessageView(
              icon: Icons.search_off_rounded,
              title: l10n.noResultsTitle,
              message: l10n.noResultsMessage,
              actionLabel: l10n.resetFilters,
              onAction: () => ref.read(recipeQueryProvider.notifier).reset(),
            ),
          );
        }
        return SliverMainAxisGroup(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                // Annonce le nombre de résultats après chaque filtrage.
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    l10n.recipesCount(recipes.length),
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: _RecipeGrid(recipes: recipes),
            ),
          ],
        );
      },
    );
  }
}

class _RecipeGrid extends StatelessWidget {
  const _RecipeGrid({required this.recipes});

  final List<Recipe> recipes;

  @override
  Widget build(BuildContext context) {
    // Cartes plus hautes quand l'utilisateur agrandit le texte : pas de
    // débordement avec une taille de police d'accessibilité.
    final textScale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);

    // `SliverGrid.builder` ne construit que les cartes visibles (+ marge
    // de cache) : les images hors écran ne sont jamais chargées.
    return SliverGrid.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.74 / textScale,
      ),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return RecipeCard(
          key: ValueKey(recipe.id),
          recipe: recipe,
          onTap: () => context.push(AppRoutes.recipeDetail(recipe.id)),
        );
      },
    );
  }
}
