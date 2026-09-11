import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n.dart';
import '../../shopping_list/application/shopping_list_providers.dart';

/// Squelette à onglets. Barre de navigation en bas sur téléphone,
/// rail latéral à partir de 840 dp (tablette, desktop, web).
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  static const wideLayoutBreakpoint = 840.0;

  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      // Retoucher l'onglet actif revient à sa racine.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isWide = MediaQuery.sizeOf(context).width >= wideLayoutBreakpoint;

    final destinations = <_Destination>[
      _Destination(Icons.restaurant_menu_outlined, Icons.restaurant_menu, l10n.navRecipes),
      _Destination(Icons.favorite_border, Icons.favorite, l10n.navFavorites),
      _Destination(
        Icons.shopping_basket_outlined,
        Icons.shopping_basket,
        l10n.navShoppingList,
        showsShoppingBadge: true,
      ),
      _Destination(Icons.settings_outlined, Icons.settings, l10n.navSettings),
    ];

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _onDestinationSelected,
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (final destination in destinations)
                  NavigationRailDestination(
                    icon: _DestinationIcon(destination: destination, selected: false),
                    selectedIcon: _DestinationIcon(destination: destination, selected: true),
                    label: Text(destination.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: [
          for (final destination in destinations)
            NavigationDestination(
              icon: _DestinationIcon(destination: destination, selected: false),
              selectedIcon: _DestinationIcon(destination: destination, selected: true),
              label: destination.label,
            ),
        ],
      ),
    );
  }
}

class _Destination {
  const _Destination(this.icon, this.selectedIcon, this.label, {this.showsShoppingBadge = false});

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool showsShoppingBadge;
}

/// Seule l'icône du panier écoute la liste de courses : ajouter un article
/// ne reconstruit ni la barre ni les autres onglets.
class _DestinationIcon extends ConsumerWidget {
  const _DestinationIcon({required this.destination, required this.selected});

  final _Destination destination;
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final icon = Icon(selected ? destination.selectedIcon : destination.icon);
    if (!destination.showsShoppingBadge) return icon;
    final count = ref.watch(shoppingRemainingCountProvider);
    return Badge.count(count: count, isLabelVisible: count > 0, child: icon);
  }
}
