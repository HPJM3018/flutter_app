import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('fr')];

  /// Nom de l'application.
  ///
  /// In fr, this message translates to:
  /// **'Miam'**
  String get appTitle;

  /// Onglet de navigation : catalogue.
  ///
  /// In fr, this message translates to:
  /// **'Recettes'**
  String get navRecipes;

  /// Onglet de navigation : favoris.
  ///
  /// In fr, this message translates to:
  /// **'Favoris'**
  String get navFavorites;

  /// Onglet de navigation : liste de courses (libellé court).
  ///
  /// In fr, this message translates to:
  /// **'Courses'**
  String get navShoppingList;

  /// Onglet de navigation : réglages.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get navSettings;

  /// Titre de l'écran catalogue.
  ///
  /// In fr, this message translates to:
  /// **'Que cuisine-t-on ?'**
  String get recipesTitle;

  /// Indication du champ de recherche.
  ///
  /// In fr, this message translates to:
  /// **'Recette ou ingrédient'**
  String get searchHint;

  /// Libellé accessible du champ de recherche.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une recette'**
  String get searchLabel;

  /// Bouton vidant le champ de recherche.
  ///
  /// In fr, this message translates to:
  /// **'Effacer la recherche'**
  String get searchClear;

  /// Libellé accessible de la rangée de filtres.
  ///
  /// In fr, this message translates to:
  /// **'Filtres'**
  String get filtersLabel;

  /// Filtre : recettes de 30 minutes ou moins.
  ///
  /// In fr, this message translates to:
  /// **'Rapide'**
  String get filterQuick;

  /// Filtre et badge : recettes végétariennes.
  ///
  /// In fr, this message translates to:
  /// **'Végétarien'**
  String get filterVegetarian;

  /// Catégorie de recette.
  ///
  /// In fr, this message translates to:
  /// **'Entrées'**
  String get categoryStarter;

  /// Catégorie de recette.
  ///
  /// In fr, this message translates to:
  /// **'Plats'**
  String get categoryMain;

  /// Catégorie de recette.
  ///
  /// In fr, this message translates to:
  /// **'Desserts'**
  String get categoryDessert;

  /// Catégorie de recette (libellé court).
  ///
  /// In fr, this message translates to:
  /// **'Petit-déj'**
  String get categoryBreakfast;

  /// Nombre de résultats affichés.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune recette} =1{1 recette} other{{count} recettes}}'**
  String recipesCount(int count);

  /// Titre de l'état vide de recherche.
  ///
  /// In fr, this message translates to:
  /// **'Aucune recette trouvée'**
  String get noResultsTitle;

  /// Message de l'état vide de recherche.
  ///
  /// In fr, this message translates to:
  /// **'Essayez un autre mot-clé ou retirez des filtres.'**
  String get noResultsMessage;

  /// Bouton réinitialisant recherche et filtres.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser les filtres'**
  String get resetFilters;

  /// Libellé accessible des indicateurs de chargement.
  ///
  /// In fr, this message translates to:
  /// **'Chargement…'**
  String get loading;

  /// Titre générique d'erreur.
  ///
  /// In fr, this message translates to:
  /// **'Oups, un problème est survenu'**
  String get errorTitle;

  /// Message d'erreur de chargement du catalogue.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les recettes.'**
  String get errorRecipesMessage;

  /// Bouton pour relancer une action échouée.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// Libellé lu par le lecteur d'écran pour une carte de recette.
  ///
  /// In fr, this message translates to:
  /// **'{title}. {duration}. Difficulté : {difficulty}.'**
  String recipeCardSemantics(String title, String duration, String difficulty);

  /// Description de la photo d'une recette.
  ///
  /// In fr, this message translates to:
  /// **'Photo : {title}'**
  String recipeImageSemantics(String title);

  /// Durée de moins d'une heure.
  ///
  /// In fr, this message translates to:
  /// **'{minutes} min'**
  String durationMinutes(int minutes);

  /// Durée en heures pleines.
  ///
  /// In fr, this message translates to:
  /// **'{hours} h'**
  String durationHours(int hours);

  /// Durée en heures et minutes.
  ///
  /// In fr, this message translates to:
  /// **'{hours} h {minutes}'**
  String durationHoursMinutes(int hours, int minutes);

  /// Niveau de difficulté.
  ///
  /// In fr, this message translates to:
  /// **'Facile'**
  String get difficultyEasy;

  /// Niveau de difficulté.
  ///
  /// In fr, this message translates to:
  /// **'Moyen'**
  String get difficultyMedium;

  /// Niveau de difficulté.
  ///
  /// In fr, this message translates to:
  /// **'Difficile'**
  String get difficultyHard;

  /// Action du bouton cœur (recette non favorite).
  ///
  /// In fr, this message translates to:
  /// **'Ajouter aux favoris'**
  String get addToFavorites;

  /// Action du bouton cœur (recette favorite).
  ///
  /// In fr, this message translates to:
  /// **'Retirer des favoris'**
  String get removeFromFavorites;

  /// Titre de l'écran des favoris.
  ///
  /// In fr, this message translates to:
  /// **'Mes favoris'**
  String get favoritesTitle;

  /// Titre de l'état vide des favoris.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de favoris'**
  String get favoritesEmptyTitle;

  /// Message de l'état vide des favoris.
  ///
  /// In fr, this message translates to:
  /// **'Touchez le cœur d\'une recette pour la retrouver ici.'**
  String get favoritesEmptyMessage;

  /// Bouton menant au catalogue.
  ///
  /// In fr, this message translates to:
  /// **'Parcourir les recettes'**
  String get browseRecipes;

  /// Confirmation de suppression d'un favori.
  ///
  /// In fr, this message translates to:
  /// **'« {title} » retiré des favoris'**
  String favoriteRemoved(String title);

  /// Action d'annulation dans une snackbar.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get undo;

  /// Libellé du temps de préparation.
  ///
  /// In fr, this message translates to:
  /// **'Préparation'**
  String get prepTime;

  /// Libellé du temps de cuisson.
  ///
  /// In fr, this message translates to:
  /// **'Cuisson'**
  String get cookTime;

  /// Libellé du niveau de difficulté.
  ///
  /// In fr, this message translates to:
  /// **'Difficulté'**
  String get difficultyLabel;

  /// Titre du sélecteur de portions.
  ///
  /// In fr, this message translates to:
  /// **'Portions'**
  String get servingsTitle;

  /// Nombre de personnes servies.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 personne} other{{count} personnes}}'**
  String servingsCount(int count);

  /// Bouton diminuant le nombre de portions.
  ///
  /// In fr, this message translates to:
  /// **'Retirer une portion'**
  String get decreaseServings;

  /// Bouton augmentant le nombre de portions.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une portion'**
  String get increaseServings;

  /// Titre de la section ingrédients.
  ///
  /// In fr, this message translates to:
  /// **'Ingrédients'**
  String get ingredientsTitle;

  /// Titre de la section des étapes.
  ///
  /// In fr, this message translates to:
  /// **'Étapes'**
  String get stepsTitle;

  /// Numéro d'une étape.
  ///
  /// In fr, this message translates to:
  /// **'Étape {number}'**
  String stepNumber(int number);

  /// Quantité libre (sel, poivre…).
  ///
  /// In fr, this message translates to:
  /// **'selon votre goût'**
  String get toTaste;

  /// Bouton ajoutant les ingrédients à la liste de courses.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter aux courses'**
  String get addToShoppingList;

  /// Confirmation d'ajout à la liste de courses.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 ingrédient ajouté aux courses} other{{count} ingrédients ajoutés aux courses}}'**
  String addedToShoppingList(int count);

  /// Action « voir » dans une snackbar.
  ///
  /// In fr, this message translates to:
  /// **'Voir'**
  String get view;

  /// Bouton lançant le mode pas-à-pas.
  ///
  /// In fr, this message translates to:
  /// **'Mode cuisine'**
  String get startCooking;

  /// Erreur quand l'identifiant de recette est inconnu.
  ///
  /// In fr, this message translates to:
  /// **'Cette recette est introuvable.'**
  String get recipeNotFound;

  /// Progression dans le mode cuisine.
  ///
  /// In fr, this message translates to:
  /// **'Étape {current} sur {total}'**
  String cookingStepProgress(int current, int total);

  /// Bouton : étape précédente.
  ///
  /// In fr, this message translates to:
  /// **'Précédent'**
  String get previousStep;

  /// Bouton : étape suivante.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get nextStep;

  /// Bouton de la dernière étape.
  ///
  /// In fr, this message translates to:
  /// **'Terminer'**
  String get finishCooking;

  /// Message affiché en quittant le mode cuisine.
  ///
  /// In fr, this message translates to:
  /// **'Bon appétit !'**
  String get cookingDone;

  /// Titre de l'écran liste de courses.
  ///
  /// In fr, this message translates to:
  /// **'Liste de courses'**
  String get shoppingListTitle;

  /// Résumé de la liste de courses.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Tout est dans le panier !} =1{1 article à acheter} other{{count} articles à acheter}}'**
  String shoppingRemaining(int count);

  /// Action supprimant les articles cochés.
  ///
  /// In fr, this message translates to:
  /// **'Retirer les articles cochés'**
  String get clearChecked;

  /// Action supprimant tous les articles.
  ///
  /// In fr, this message translates to:
  /// **'Vider la liste'**
  String get clearAll;

  /// Titre du dialogue de confirmation.
  ///
  /// In fr, this message translates to:
  /// **'Vider la liste de courses ?'**
  String get clearAllConfirmTitle;

  /// Message du dialogue de confirmation.
  ///
  /// In fr, this message translates to:
  /// **'Tous les articles seront supprimés.'**
  String get clearAllConfirmMessage;

  /// Bouton d'annulation d'un dialogue.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// Bouton de confirmation du vidage.
  ///
  /// In fr, this message translates to:
  /// **'Vider'**
  String get confirmClear;

  /// Titre de l'état vide de la liste de courses.
  ///
  /// In fr, this message translates to:
  /// **'Votre liste est vide'**
  String get shoppingEmptyTitle;

  /// Message de l'état vide de la liste de courses.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez les ingrédients d\'une recette en un geste : les doublons sont regroupés.'**
  String get shoppingEmptyMessage;

  /// Confirmation de suppression d'un article.
  ///
  /// In fr, this message translates to:
  /// **'« {name} » supprimé'**
  String itemRemoved(String name);

  /// Nombre de recettes ayant ajouté l'article.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{Pour 1 recette} other{Pour {count} recettes}}'**
  String fromRecipes(int count);

  /// Titre de l'écran réglages.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get settingsTitle;

  /// Section de choix de la langue.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get languageSection;

  /// Option : suivre la langue du système.
  ///
  /// In fr, this message translates to:
  /// **'Langue de l\'appareil'**
  String get languageSystem;

  /// Option : français (toujours écrit en français).
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// Option : anglais (toujours écrit en anglais).
  ///
  /// In fr, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Section de choix du thème.
  ///
  /// In fr, this message translates to:
  /// **'Apparence'**
  String get themeSection;

  /// Option : suivre le thème du système.
  ///
  /// In fr, this message translates to:
  /// **'Automatique'**
  String get themeSystem;

  /// Option : thème clair.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get themeLight;

  /// Option : thème sombre.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get themeDark;

  /// Section à propos.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get aboutSection;

  /// Relance l'écran d'accueil.
  ///
  /// In fr, this message translates to:
  /// **'Revoir l\'introduction'**
  String get replayOnboarding;

  /// Ouvre la boîte « à propos ».
  ///
  /// In fr, this message translates to:
  /// **'À propos de Miam'**
  String get aboutApp;

  /// Mentions légales et crédits.
  ///
  /// In fr, this message translates to:
  /// **'Photos : TheMealDB.com. Recettes adaptées pour l\'application.'**
  String get appLegalese;

  /// Version de l'application.
  ///
  /// In fr, this message translates to:
  /// **'Version {version}'**
  String appVersion(String version);

  /// Titre de la page 1 de l'introduction.
  ///
  /// In fr, this message translates to:
  /// **'Des recettes qui donnent faim'**
  String get onboardingTitle1;

  /// Texte de la page 1 de l'introduction.
  ///
  /// In fr, this message translates to:
  /// **'Un carnet de recettes simples, du petit-déjeuner au dessert, en français et en anglais.'**
  String get onboardingBody1;

  /// Titre de la page 2 de l'introduction.
  ///
  /// In fr, this message translates to:
  /// **'Des portions sur mesure'**
  String get onboardingTitle2;

  /// Texte de la page 2 de l'introduction.
  ///
  /// In fr, this message translates to:
  /// **'Les quantités se recalculent automatiquement selon le nombre d\'invités.'**
  String get onboardingBody2;

  /// Titre de la page 3 de l'introduction.
  ///
  /// In fr, this message translates to:
  /// **'Des courses sans effort'**
  String get onboardingTitle3;

  /// Texte de la page 3 de l'introduction.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez les ingrédients à votre liste : les doublons sont additionnés pour vous.'**
  String get onboardingBody3;

  /// Bouton pour ignorer l'introduction.
  ///
  /// In fr, this message translates to:
  /// **'Passer'**
  String get onboardingSkip;

  /// Bouton : page suivante de l'introduction.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get onboardingNext;

  /// Bouton final de l'introduction.
  ///
  /// In fr, this message translates to:
  /// **'C\'est parti !'**
  String get onboardingStart;

  /// Indicateur de page accessible.
  ///
  /// In fr, this message translates to:
  /// **'Page {current} sur {total}'**
  String onboardingPageIndicator(int current, int total);

  /// Symbole du gramme.
  ///
  /// In fr, this message translates to:
  /// **'g'**
  String get unitGram;

  /// Symbole du kilogramme.
  ///
  /// In fr, this message translates to:
  /// **'kg'**
  String get unitKilogram;

  /// Symbole du millilitre.
  ///
  /// In fr, this message translates to:
  /// **'ml'**
  String get unitMilliliter;

  /// Symbole du litre.
  ///
  /// In fr, this message translates to:
  /// **'l'**
  String get unitLiter;

  /// Cuillère à soupe (abrégé).
  ///
  /// In fr, this message translates to:
  /// **'c. à soupe'**
  String get unitTablespoon;

  /// Cuillère à café (abrégé).
  ///
  /// In fr, this message translates to:
  /// **'c. à café'**
  String get unitTeaspoon;

  /// Pincée, accordée au nombre.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{pincée} other{pincées}}'**
  String unitPinch(num count);

  /// Gousse (d'ail), accordée au nombre.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{gousse} other{gousses}}'**
  String unitClove(num count);

  /// Tranche, accordée au nombre.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{tranche} other{tranches}}'**
  String unitSlice(num count);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
