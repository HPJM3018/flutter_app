import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/status_views.dart';
import '../application/shopping_list_providers.dart';
import '../domain/shopping_list.dart';

class ShoppingListScreen extends ConsumerWidget {
  const ShoppingListScreen({super.key});

  Future<void> _confirmClearAll(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearAllConfirmTitle),
        content: Text(l10n.clearAllConfirmMessage),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.confirmClear),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await ref.read(shoppingListProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final list = ref.watch(shoppingListProvider);
    final notifier = ref.read(shoppingListProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.shoppingListTitle),
        actions: [
          if (list.checkedCount > 0)
            IconButton(
              tooltip: l10n.clearChecked,
              icon: const Icon(Icons.remove_done),
              onPressed: notifier.clearChecked,
            ),
          if (!list.isEmpty)
            IconButton(
              tooltip: l10n.clearAll,
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () => _confirmClearAll(context, ref),
            ),
        ],
      ),
      body: list.isEmpty
          ? MessageView(
              icon: Icons.shopping_basket_outlined,
              title: l10n.shoppingEmptyTitle,
              message: l10n.shoppingEmptyMessage,
              actionLabel: l10n.browseRecipes,
              onAction: () => context.go(AppRoutes.recipes),
            )
          : _ShoppingListView(list: list),
    );
  }
}

class _ShoppingListView extends StatelessWidget {
  const _ShoppingListView({required this.list});

  final ShoppingList list;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = list.sortedItems;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  liveRegion: true,
                  child: Text(
                    l10n.shoppingRemaining(list.remainingCount),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 8),
                ExcludeSemantics(
                  child: LinearProgressIndicator(
                    value: list.checkedCount / list.items.length,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverList.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _ShoppingItemTile(
              key: ValueKey(item.key),
              item: item,
              originalIndex: list.items.indexOf(item),
            );
          },
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _ShoppingItemTile extends ConsumerWidget {
  const _ShoppingItemTile({required this.item, required this.originalIndex, super.key});

  final ShoppingItem item;
  final int originalIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final name = context.tr(item.name);
    final notifier = ref.read(shoppingListProvider.notifier);

    final mutedStyle = TextStyle(
      decoration: item.isChecked ? TextDecoration.lineThrough : null,
      color: item.isChecked ? theme.colorScheme.onSurfaceVariant : null,
    );

    return Dismissible(
      key: ValueKey('dismiss-${item.key}'),
      direction: DismissDirection.endToStart,
      background: ColoredBox(
        color: theme.colorScheme.errorContainer,
        child: Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Icon(Icons.delete_outline, color: theme.colorScheme.onErrorContainer),
          ),
        ),
      ),
      onDismissed: (_) {
        notifier.remove(item.key);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              persist: false,
              content: Text(l10n.itemRemoved(name)),
              action: SnackBarAction(
                label: l10n.undo,
                onPressed: () => notifier.insert(originalIndex, item),
              ),
            ),
          );
      },
      child: CheckboxListTile(
        value: item.isChecked,
        onChanged: (_) => notifier.toggle(item.key),
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(name, style: mutedStyle),
        subtitle: Text(l10n.fromRecipes(item.recipeIds.length)),
        secondary: Text(
          l10n.quantity(item.displayQuantity),
          style: theme.textTheme.titleSmall?.merge(mutedStyle),
        ),
      ),
    );
  }
}
