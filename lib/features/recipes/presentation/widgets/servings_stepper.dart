import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/l10n.dart';
import '../../domain/recipe.dart';

/// Sélecteur − / + du nombre de portions, borné à
/// [Recipe.minServings]…[Recipe.maxServings].
///
/// Exposé au lecteur d'écran comme un curseur ajustable (glisser vers le
/// haut / bas avec TalkBack ou VoiceOver).
class ServingsStepper extends StatelessWidget {
  const ServingsStepper({required this.servings, required this.onChanged, super.key});

  final int servings;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final canDecrease = servings > Recipe.minServings;
    final canIncrease = servings < Recipe.maxServings;

    return Semantics(
      container: true,
      label: l10n.servingsTitle,
      value: l10n.servingsCount(servings),
      increasedValue: canIncrease ? l10n.servingsCount(servings + 1) : null,
      decreasedValue: canDecrease ? l10n.servingsCount(servings - 1) : null,
      onIncrease: canIncrease ? () => onChanged(servings + 1) : null,
      onDecrease: canDecrease ? () => onChanged(servings - 1) : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton.outlined(
            onPressed: canDecrease ? () => onChanged(servings - 1) : null,
            tooltip: l10n.decreaseServings,
            icon: const Icon(Icons.remove),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 110),
            child: ExcludeSemantics(
              child: Text(
                l10n.servingsCount(servings),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          IconButton.outlined(
            onPressed: canIncrease ? () => onChanged(servings + 1) : null,
            tooltip: l10n.increaseServings,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
