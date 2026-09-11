import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../recipes/domain/recipe.dart';
import '../data/shopping_list_repository.dart';
import '../domain/shopping_list.dart';

final shoppingListRepositoryProvider = Provider<ShoppingListRepository>(
  (ref) => ShoppingListRepository(ref.watch(sharedPreferencesProvider)),
  name: 'shoppingListRepositoryProvider',
);

class ShoppingListNotifier extends Notifier<ShoppingList> {
  @override
  ShoppingList build() => ref.watch(shoppingListRepositoryProvider).load();

  Future<void> addRecipe(Recipe recipe, {required int servings}) =>
      _update(state.addRecipe(recipe, servings: servings));

  Future<void> toggle(String key) => _update(state.toggle(key));

  Future<void> remove(String key) => _update(state.remove(key));

  Future<void> insert(int index, ShoppingItem item) => _update(state.insert(index, item));

  Future<void> clearChecked() => _update(state.clearChecked());

  Future<void> clear() => _update(const ShoppingList());

  Future<void> _update(ShoppingList next) async {
    state = next;
    await ref.read(shoppingListRepositoryProvider).save(next);
  }
}

final shoppingListProvider = NotifierProvider<ShoppingListNotifier, ShoppingList>(
  ShoppingListNotifier.new,
  name: 'shoppingListProvider',
);

/// Nombre d'articles restants, pour le badge de navigation : le badge ne
/// se reconstruit que si ce nombre change.
final shoppingRemainingCountProvider = Provider<int>(
  (ref) => ref.watch(shoppingListProvider.select((list) => list.remainingCount)),
  name: 'shoppingRemainingCountProvider',
);
