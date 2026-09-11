import 'package:miam/features/recipes/domain/localized_text.dart';
import 'package:miam/features/recipes/domain/quantity.dart';
import 'package:miam/features/recipes/domain/recipe.dart';

LocalizedText text(String fr, [String? en]) => LocalizedText({'fr': fr, 'en': en ?? fr});

Ingredient ingredient(
  String id, {
  double? quantity,
  IngredientUnit unit = IngredientUnit.piece,
  String? fr,
  String? en,
}) {
  return Ingredient(id: id, name: text(fr ?? id, en ?? id), quantity: quantity, unit: unit);
}

Recipe buildRecipe({
  String id = 'crepes',
  String titleFr = 'Crêpes de la Chandeleur',
  String titleEn = 'Candlemas crêpes',
  RecipeCategory category = RecipeCategory.dessert,
  Difficulty difficulty = Difficulty.easy,
  int prepMinutes = 10,
  int cookMinutes = 20,
  int servings = 4,
  bool isVegetarian = true,
  List<Ingredient>? ingredients,
  List<LocalizedText>? steps,
}) {
  return Recipe(
    id: id,
    title: text(titleFr, titleEn),
    description: text('Description $titleFr', 'Description $titleEn'),
    imageUrl: 'https://www.themealdb.com/images/media/meals/$id.jpg',
    category: category,
    difficulty: difficulty,
    prepMinutes: prepMinutes,
    cookMinutes: cookMinutes,
    servings: servings,
    isVegetarian: isVegetarian,
    ingredients:
        ingredients ??
        [
          ingredient('flour', quantity: 250, unit: IngredientUnit.gram, fr: 'Farine', en: 'Flour'),
          ingredient('egg', quantity: 3, fr: 'Œufs', en: 'Eggs'),
          ingredient(
            'milk',
            quantity: 500,
            unit: IngredientUnit.milliliter,
            fr: 'Lait',
            en: 'Milk',
          ),
          ingredient('salt', fr: 'Sel', en: 'Salt'),
        ],
    steps:
        steps ??
        [
          text('Mélanger la farine et les œufs.', 'Mix the flour and eggs.'),
          text('Ajouter le lait progressivement.', 'Gradually add the milk.'),
          text('Cuire dans une poêle chaude.', 'Cook in a hot pan.'),
        ],
  );
}

/// Petit catalogue varié couvrant chaque filtre.
final sampleRecipes = <Recipe>[
  buildRecipe(),
  buildRecipe(
    id: 'boeuf',
    titleFr: 'Bœuf bourguignon',
    titleEn: 'Beef bourguignon',
    category: RecipeCategory.main,
    difficulty: Difficulty.hard,
    prepMinutes: 30,
    cookMinutes: 180,
    servings: 6,
    isVegetarian: false,
    ingredients: [
      ingredient('beef', quantity: 1.2, unit: IngredientUnit.kilogram, fr: 'Bœuf', en: 'Beef'),
      ingredient('onion', quantity: 2, fr: 'Oignons', en: 'Onions'),
      ingredient(
        'red-wine',
        quantity: 750,
        unit: IngredientUnit.milliliter,
        fr: 'Vin rouge',
        en: 'Red wine',
      ),
    ],
  ),
  buildRecipe(
    id: 'salade',
    titleFr: 'Salade niçoise',
    titleEn: 'Niçoise salad',
    category: RecipeCategory.starter,
    prepMinutes: 15,
    cookMinutes: 0,
    servings: 2,
    isVegetarian: false,
    ingredients: [
      ingredient('tomato', quantity: 3, fr: 'Tomates', en: 'Tomatoes'),
      ingredient('egg', quantity: 2, fr: 'Œufs', en: 'Eggs'),
      ingredient('tuna', quantity: 150, unit: IngredientUnit.gram, fr: 'Thon', en: 'Tuna'),
    ],
  ),
  buildRecipe(
    id: 'omelette',
    titleFr: 'Omelette aux fines herbes',
    titleEn: 'Herb omelette',
    category: RecipeCategory.breakfast,
    prepMinutes: 5,
    cookMinutes: 5,
    servings: 1,
    ingredients: [
      ingredient('egg', quantity: 3, fr: 'Œufs', en: 'Eggs'),
      ingredient('butter', quantity: 15, unit: IngredientUnit.gram, fr: 'Beurre', en: 'Butter'),
      ingredient(
        'chives',
        quantity: 1,
        unit: IngredientUnit.tablespoon,
        fr: 'Ciboulette',
        en: 'Chives',
      ),
    ],
  ),
];
