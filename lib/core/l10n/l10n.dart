import 'package:flutter/widgets.dart';

import '../../features/recipes/domain/localized_text.dart';
import '../../features/recipes/domain/quantity.dart';
import '../../features/recipes/domain/recipe.dart';
import '../../l10n/generated/app_localizations.dart';

export '../../l10n/generated/app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// Code de langue effectif (`fr`, `en`), utilisé pour le contenu.
  String get languageCode => Localizations.localeOf(this).languageCode;

  /// Raccourci pour afficher un contenu de recette dans la langue courante.
  String tr(LocalizedText text) => text.resolve(languageCode);
}

extension RecipeCategoryL10n on RecipeCategory {
  String label(AppLocalizations l10n) => switch (this) {
    RecipeCategory.starter => l10n.categoryStarter,
    RecipeCategory.main => l10n.categoryMain,
    RecipeCategory.dessert => l10n.categoryDessert,
    RecipeCategory.breakfast => l10n.categoryBreakfast,
  };
}

extension DifficultyL10n on Difficulty {
  String label(AppLocalizations l10n) => switch (this) {
    Difficulty.easy => l10n.difficultyEasy,
    Difficulty.medium => l10n.difficultyMedium,
    Difficulty.hard => l10n.difficultyHard,
  };
}

extension AppLocalizationsFormatting on AppLocalizations {
  /// `45 min`, `1 h`, `1 h 15` (fr) / `1 h 15 min` (en).
  String duration(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours == 0) return durationMinutes(minutes);
    if (minutes == 0) return durationHours(hours);
    return durationHoursMinutes(hours, minutes);
  }

  /// Libellé d'unité accordé à la quantité ; `null` pour les pièces
  /// (« 3 Œufs » plutôt que « 3 pièces Œufs »).
  String? unitLabel(IngredientUnit unit, num value) => switch (unit) {
    IngredientUnit.gram => unitGram,
    IngredientUnit.kilogram => unitKilogram,
    IngredientUnit.milliliter => unitMilliliter,
    IngredientUnit.liter => unitLiter,
    IngredientUnit.tablespoon => unitTablespoon,
    IngredientUnit.teaspoon => unitTeaspoon,
    IngredientUnit.pinch => unitPinch(value),
    IngredientUnit.clove => unitClove(value),
    IngredientUnit.slice => unitSlice(value),
    IngredientUnit.piece => null,
  };

  /// Quantité complète et lisible : `1,25 kg`, `2 gousses`, `1½`,
  /// ou « selon votre goût » quand la quantité est libre.
  String quantity(Quantity? quantity) {
    if (quantity == null) return toTaste;
    final normalized = quantity.normalized();
    final value = normalized.formatValue(localeName);
    final unit = unitLabel(normalized.unit, normalized.value);
    return unit == null ? value : '$value $unit';
  }
}
