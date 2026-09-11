import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/favorites/presentation/favorites_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/recipes/presentation/cooking_mode_screen.dart';
import '../../features/recipes/presentation/recipe_detail_screen.dart';
import '../../features/recipes/presentation/recipes_screen.dart';
import '../../features/settings/application/settings_providers.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/shell/presentation/app_shell.dart';
import '../../features/shopping_list/presentation/shopping_list_screen.dart';

abstract final class AppRoutes {
  static const onboarding = '/onboarding';
  static const recipes = '/recipes';
  static const favorites = '/favorites';
  static const shoppingList = '/shopping-list';
  static const settings = '/settings';

  static String recipeDetail(String id) => '/recipe/$id';
  static String cookingMode(String id) => '/recipe/$id/cook';
}

/// Emplacement initial, surchargé par les tests pour ouvrir un écran précis.
final initialLocationProvider = Provider<String>(
  (ref) => AppRoutes.recipes,
  name: 'initialLocationProvider',
);

final routerProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: ref.read(initialLocationProvider),
    redirect: (context, state) {
      final onboarded = ref.read(settingsProvider).onboardingCompleted;
      final onOnboarding = state.matchedLocation == AppRoutes.onboarding;
      if (!onboarded && !onOnboarding) return AppRoutes.onboarding;
      if (onboarded && onOnboarding) return AppRoutes.recipes;
      return null;
    },
    routes: [
      GoRoute(path: '/', redirect: (_, _) => AppRoutes.recipes),
      GoRoute(path: AppRoutes.onboarding, builder: (context, state) => const OnboardingScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: AppRoutes.recipes, builder: (context, state) => const RecipesScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.favorites,
                builder: (context, state) => const FavoritesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.shoppingList,
                builder: (context, state) => const ShoppingListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      // Hors du shell : le détail s'ouvre en plein écran par-dessus
      // n'importe quel onglet, et le retour ramène à cet onglet.
      GoRoute(
        path: '/recipe/:id',
        builder: (context, state) => RecipeDetailScreen(recipeId: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'cook',
            builder: (context, state) => CookingModeScreen(recipeId: state.pathParameters['id']!),
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
}, name: 'routerProvider');
