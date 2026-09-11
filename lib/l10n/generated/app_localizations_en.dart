// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Miam';

  @override
  String get navRecipes => 'Recipes';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navShoppingList => 'Shopping';

  @override
  String get navSettings => 'Settings';

  @override
  String get recipesTitle => 'What\'s cooking?';

  @override
  String get searchHint => 'Recipe or ingredient';

  @override
  String get searchLabel => 'Search recipes';

  @override
  String get searchClear => 'Clear search';

  @override
  String get filtersLabel => 'Filters';

  @override
  String get filterQuick => 'Quick';

  @override
  String get filterVegetarian => 'Vegetarian';

  @override
  String get categoryStarter => 'Starters';

  @override
  String get categoryMain => 'Mains';

  @override
  String get categoryDessert => 'Desserts';

  @override
  String get categoryBreakfast => 'Breakfast';

  @override
  String recipesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recipes',
      one: '1 recipe',
      zero: 'No recipes',
    );
    return '$_temp0';
  }

  @override
  String get noResultsTitle => 'No recipes found';

  @override
  String get noResultsMessage => 'Try another keyword or remove some filters.';

  @override
  String get resetFilters => 'Reset filters';

  @override
  String get loading => 'Loading…';

  @override
  String get errorTitle => 'Oops, something went wrong';

  @override
  String get errorRecipesMessage => 'Recipes could not be loaded.';

  @override
  String get retry => 'Try again';

  @override
  String recipeCardSemantics(String title, String duration, String difficulty) {
    return '$title. $duration. Difficulty: $difficulty.';
  }

  @override
  String recipeImageSemantics(String title) {
    return 'Photo of $title';
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
    return '$hours h $minutes min';
  }

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get difficultyHard => 'Hard';

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String get favoritesTitle => 'My favorites';

  @override
  String get favoritesEmptyTitle => 'No favorites yet';

  @override
  String get favoritesEmptyMessage => 'Tap the heart on a recipe to find it here.';

  @override
  String get browseRecipes => 'Browse recipes';

  @override
  String favoriteRemoved(String title) {
    return '\"$title\" removed from favorites';
  }

  @override
  String get undo => 'Undo';

  @override
  String get prepTime => 'Prep';

  @override
  String get cookTime => 'Cook';

  @override
  String get difficultyLabel => 'Difficulty';

  @override
  String get servingsTitle => 'Servings';

  @override
  String servingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count servings',
      one: '1 serving',
    );
    return '$_temp0';
  }

  @override
  String get decreaseServings => 'Remove a serving';

  @override
  String get increaseServings => 'Add a serving';

  @override
  String get ingredientsTitle => 'Ingredients';

  @override
  String get stepsTitle => 'Steps';

  @override
  String stepNumber(int number) {
    return 'Step $number';
  }

  @override
  String get toTaste => 'to taste';

  @override
  String get addToShoppingList => 'Add to shopping list';

  @override
  String addedToShoppingList(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ingredients added to your list',
      one: '1 ingredient added to your list',
    );
    return '$_temp0';
  }

  @override
  String get view => 'View';

  @override
  String get startCooking => 'Cooking mode';

  @override
  String get recipeNotFound => 'This recipe could not be found.';

  @override
  String cookingStepProgress(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get previousStep => 'Previous';

  @override
  String get nextStep => 'Next';

  @override
  String get finishCooking => 'Finish';

  @override
  String get cookingDone => 'Enjoy your meal!';

  @override
  String get shoppingListTitle => 'Shopping list';

  @override
  String shoppingRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items to buy',
      one: '1 item to buy',
      zero: 'Everything is in the basket!',
    );
    return '$_temp0';
  }

  @override
  String get clearChecked => 'Remove checked items';

  @override
  String get clearAll => 'Clear list';

  @override
  String get clearAllConfirmTitle => 'Clear the shopping list?';

  @override
  String get clearAllConfirmMessage => 'All items will be removed.';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirmClear => 'Clear';

  @override
  String get shoppingEmptyTitle => 'Your list is empty';

  @override
  String get shoppingEmptyMessage =>
      'Add a recipe\'s ingredients in one tap: duplicates are merged.';

  @override
  String itemRemoved(String name) {
    return '\"$name\" removed';
  }

  @override
  String fromRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'For $count recipes',
      one: 'For 1 recipe',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get languageSection => 'Language';

  @override
  String get languageSystem => 'Device language';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String get themeSection => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get aboutSection => 'About';

  @override
  String get replayOnboarding => 'Replay introduction';

  @override
  String get aboutApp => 'About Miam';

  @override
  String get appLegalese => 'Photos: TheMealDB.com. Recipes adapted for the app.';

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String get onboardingTitle1 => 'Recipes that make you hungry';

  @override
  String get onboardingBody1 =>
      'A cookbook of simple recipes, from breakfast to dessert, in English and French.';

  @override
  String get onboardingTitle2 => 'Servings made to measure';

  @override
  String get onboardingBody2 => 'Quantities are recalculated automatically for your guests.';

  @override
  String get onboardingTitle3 => 'Effortless shopping';

  @override
  String get onboardingBody3 => 'Add ingredients to your list: duplicates are added up for you.';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Let\'s cook!';

  @override
  String onboardingPageIndicator(int current, int total) {
    return 'Page $current of $total';
  }

  @override
  String get unitGram => 'g';

  @override
  String get unitKilogram => 'kg';

  @override
  String get unitMilliliter => 'ml';

  @override
  String get unitLiter => 'L';

  @override
  String get unitTablespoon => 'tbsp';

  @override
  String get unitTeaspoon => 'tsp';

  @override
  String unitPinch(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'pinches',
      one: 'pinch',
    );
    return '$_temp0';
  }

  @override
  String unitClove(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'cloves', one: 'clove');
    return '$_temp0';
  }

  @override
  String unitSlice(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'slices', one: 'slice');
    return '$_temp0';
  }
}
