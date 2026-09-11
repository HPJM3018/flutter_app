import 'package:equatable/equatable.dart';

import 'localized_text.dart';
import 'quantity.dart';

enum RecipeCategory {
  starter,
  main,
  dessert,
  breakfast;

  static RecipeCategory fromName(String name) => RecipeCategory.values.firstWhere(
    (category) => category.name == name,
    orElse: () => throw FormatException('Catégorie inconnue : $name'),
  );
}

enum Difficulty {
  easy,
  medium,
  hard;

  static Difficulty fromName(String name) => Difficulty.values.firstWhere(
    (difficulty) => difficulty.name == name,
    orElse: () => throw FormatException('Difficulté inconnue : $name'),
  );
}

class Ingredient extends Equatable {
  const Ingredient({required this.id, required this.name, required this.unit, this.quantity});

  factory Ingredient.fromJson(Map<String, Object?> json) {
    return Ingredient(
      id: json['id']! as String,
      name: LocalizedText.fromJson(json['name']),
      quantity: (json['quantity'] as num?)?.toDouble(),
      unit: IngredientUnit.fromName(json['unit'] as String? ?? 'piece'),
    );
  }

  /// Identifiant stable, partagé entre recettes (`egg`, `butter`…) :
  /// il permet de fusionner les ingrédients dans la liste de courses.
  final String id;
  final LocalizedText name;

  /// `null` signifie « selon votre goût » (sel, poivre…).
  final double? quantity;
  final IngredientUnit unit;

  Quantity? get amount => quantity == null ? null : Quantity(quantity!, unit);

  Ingredient scaled(double factor) => Ingredient(
    id: id,
    name: name,
    quantity: quantity == null ? null : quantity! * factor,
    unit: unit,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name.toJson(),
    'quantity': quantity,
    'unit': unit.name,
  };

  @override
  List<Object?> get props => [id, name, quantity, unit];
}

class Recipe extends Equatable {
  const Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.difficulty,
    required this.prepMinutes,
    required this.cookMinutes,
    required this.servings,
    required this.ingredients,
    required this.steps,
    this.isVegetarian = false,
  }) : assert(servings > 0, 'Une recette sert au moins une personne.');

  factory Recipe.fromJson(Map<String, Object?> json) {
    return Recipe(
      id: json['id']! as String,
      title: LocalizedText.fromJson(json['title']),
      description: LocalizedText.fromJson(json['description']),
      imageUrl: json['imageUrl']! as String,
      category: RecipeCategory.fromName(json['category']! as String),
      difficulty: Difficulty.fromName(json['difficulty']! as String),
      prepMinutes: json['prepMinutes']! as int,
      cookMinutes: json['cookMinutes'] as int? ?? 0,
      servings: json['servings']! as int,
      isVegetarian: json['vegetarian'] as bool? ?? false,
      ingredients: [
        for (final item in json['ingredients']! as List<Object?>)
          Ingredient.fromJson(item! as Map<String, Object?>),
      ],
      steps: [for (final step in json['steps']! as List<Object?>) LocalizedText.fromJson(step)],
    );
  }

  static const minServings = 1;
  static const maxServings = 24;

  final String id;
  final LocalizedText title;
  final LocalizedText description;
  final String imageUrl;
  final RecipeCategory category;
  final Difficulty difficulty;
  final int prepMinutes;
  final int cookMinutes;
  final int servings;
  final bool isVegetarian;
  final List<Ingredient> ingredients;
  final List<LocalizedText> steps;

  int get totalMinutes => prepMinutes + cookMinutes;

  /// Ingrédients recalculés pour [targetServings] personnes.
  List<Ingredient> ingredientsFor(int targetServings) {
    if (targetServings < minServings) {
      throw ArgumentError.value(targetServings, 'targetServings', 'doit être ≥ $minServings');
    }
    if (targetServings == servings) return ingredients;
    final factor = targetServings / servings;
    return [for (final ingredient in ingredients) ingredient.scaled(factor)];
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    imageUrl,
    category,
    difficulty,
    prepMinutes,
    cookMinutes,
    servings,
    isVegetarian,
    ingredients,
    steps,
  ];
}
