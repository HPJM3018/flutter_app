import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/l10n.dart';
import '../../domain/recipe.dart';

/// Ligne « ⏱ 45 min · Facile » affichée sous le titre d'une carte.
class RecipeMetaRow extends StatelessWidget {
  const RecipeMetaRow({required this.recipe, super.key});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    return Row(
      children: [
        Icon(Icons.schedule, size: 16, color: style?.color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            '${l10n.duration(recipe.totalMinutes)} · ${recipe.difficulty.label(l10n)}',
            style: style,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
