// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Miam';

  @override
  String get navRecipes => 'Recettes';

  @override
  String get navFavorites => 'Favoris';

  @override
  String get navShoppingList => 'Courses';

  @override
  String get navSettings => 'Réglages';

  @override
  String get recipesTitle => 'Que cuisine-t-on ?';

  @override
  String get searchHint => 'Recette ou ingrédient';

  @override
  String get searchLabel => 'Rechercher une recette';

  @override
  String get searchClear => 'Effacer la recherche';

  @override
  String get filtersLabel => 'Filtres';

  @override
  String get filterQuick => 'Rapide';

  @override
  String get filterVegetarian => 'Végétarien';

  @override
  String get categoryStarter => 'Entrées';

  @override
  String get categoryMain => 'Plats';

  @override
  String get categoryDessert => 'Desserts';

  @override
  String get categoryBreakfast => 'Petit-déj';

  @override
  String recipesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recettes',
      one: '1 recette',
      zero: 'Aucune recette',
    );
    return '$_temp0';
  }

  @override
  String get noResultsTitle => 'Aucune recette trouvée';

  @override
  String get noResultsMessage => 'Essayez un autre mot-clé ou retirez des filtres.';

  @override
  String get resetFilters => 'Réinitialiser les filtres';

  @override
  String get loading => 'Chargement…';

  @override
  String get errorTitle => 'Oups, un problème est survenu';

  @override
  String get errorRecipesMessage => 'Impossible de charger les recettes.';

  @override
  String get retry => 'Réessayer';

  @override
  String recipeCardSemantics(String title, String duration, String difficulty) {
    return '$title. $duration. Difficulté : $difficulty.';
  }

  @override
  String recipeImageSemantics(String title) {
    return 'Photo : $title';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String durationHours(int hours) {
    return '$hours h';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes';
  }

  @override
  String get difficultyEasy => 'Facile';

  @override
  String get difficultyMedium => 'Moyen';

  @override
  String get difficultyHard => 'Difficile';

  @override
  String get addToFavorites => 'Ajouter aux favoris';

  @override
  String get removeFromFavorites => 'Retirer des favoris';

  @override
  String get favoritesTitle => 'Mes favoris';

  @override
  String get favoritesEmptyTitle => 'Pas encore de favoris';

  @override
  String get favoritesEmptyMessage => 'Touchez le cœur d\'une recette pour la retrouver ici.';

  @override
  String get browseRecipes => 'Parcourir les recettes';

  @override
  String favoriteRemoved(String title) {
    return '« $title » retiré des favoris';
  }

  @override
  String get undo => 'Annuler';

  @override
  String get prepTime => 'Préparation';

  @override
  String get cookTime => 'Cuisson';

  @override
  String get difficultyLabel => 'Difficulté';

  @override
  String get servingsTitle => 'Portions';

  @override
  String servingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personnes',
      one: '1 personne',
    );
    return '$_temp0';
  }

  @override
  String get decreaseServings => 'Retirer une portion';

  @override
  String get increaseServings => 'Ajouter une portion';

  @override
  String get ingredientsTitle => 'Ingrédients';

  @override
  String get stepsTitle => 'Étapes';

  @override
  String stepNumber(int number) {
    return 'Étape $number';
  }

  @override
  String get toTaste => 'selon votre goût';

  @override
  String get addToShoppingList => 'Ajouter aux courses';

  @override
  String addedToShoppingList(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ingrédients ajoutés aux courses',
      one: '1 ingrédient ajouté aux courses',
    );
    return '$_temp0';
  }

  @override
  String get view => 'Voir';

  @override
  String get startCooking => 'Mode cuisine';

  @override
  String get recipeNotFound => 'Cette recette est introuvable.';

  @override
  String cookingStepProgress(int current, int total) {
    return 'Étape $current sur $total';
  }

  @override
  String get previousStep => 'Précédent';

  @override
  String get nextStep => 'Suivant';

  @override
  String get finishCooking => 'Terminer';

  @override
  String get cookingDone => 'Bon appétit !';

  @override
  String get shoppingListTitle => 'Liste de courses';

  @override
  String shoppingRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles à acheter',
      one: '1 article à acheter',
      zero: 'Tout est dans le panier !',
    );
    return '$_temp0';
  }

  @override
  String get clearChecked => 'Retirer les articles cochés';

  @override
  String get clearAll => 'Vider la liste';

  @override
  String get clearAllConfirmTitle => 'Vider la liste de courses ?';

  @override
  String get clearAllConfirmMessage => 'Tous les articles seront supprimés.';

  @override
  String get cancel => 'Annuler';

  @override
  String get confirmClear => 'Vider';

  @override
  String get shoppingEmptyTitle => 'Votre liste est vide';

  @override
  String get shoppingEmptyMessage =>
      'Ajoutez les ingrédients d\'une recette en un geste : les doublons sont regroupés.';

  @override
  String itemRemoved(String name) {
    return '« $name » supprimé';
  }

  @override
  String fromRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Pour $count recettes',
      one: 'Pour 1 recette',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get languageSection => 'Langue';

  @override
  String get languageSystem => 'Langue de l\'appareil';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String get themeSection => 'Apparence';

  @override
  String get themeSystem => 'Automatique';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get aboutSection => 'À propos';

  @override
  String get replayOnboarding => 'Revoir l\'introduction';

  @override
  String get aboutApp => 'À propos de Miam';

  @override
  String get appLegalese => 'Photos : TheMealDB.com. Recettes adaptées pour l\'application.';

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String get onboardingTitle1 => 'Des recettes qui donnent faim';

  @override
  String get onboardingBody1 =>
      'Un carnet de recettes simples, du petit-déjeuner au dessert, en français et en anglais.';

  @override
  String get onboardingTitle2 => 'Des portions sur mesure';

  @override
  String get onboardingBody2 =>
      'Les quantités se recalculent automatiquement selon le nombre d\'invités.';

  @override
  String get onboardingTitle3 => 'Des courses sans effort';

  @override
  String get onboardingBody3 =>
      'Ajoutez les ingrédients à votre liste : les doublons sont additionnés pour vous.';

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get onboardingNext => 'Suivant';

  @override
  String get onboardingStart => 'C\'est parti !';

  @override
  String onboardingPageIndicator(int current, int total) {
    return 'Page $current sur $total';
  }

  @override
  String get unitGram => 'g';

  @override
  String get unitKilogram => 'kg';

  @override
  String get unitMilliliter => 'ml';

  @override
  String get unitLiter => 'l';

  @override
  String get unitTablespoon => 'c. à soupe';

  @override
  String get unitTeaspoon => 'c. à café';

  @override
  String unitPinch(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'pincées',
      one: 'pincée',
    );
    return '$_temp0';
  }

  @override
  String unitClove(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'gousses',
      one: 'gousse',
    );
    return '$_temp0';
  }

  @override
  String unitSlice(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'tranches',
      one: 'tranche',
    );
    return '$_temp0';
  }
}
