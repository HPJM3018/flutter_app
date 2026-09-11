import 'package:equatable/equatable.dart';

import '../../recipes/domain/localized_text.dart';
import '../../recipes/domain/quantity.dart';
import '../../recipes/domain/recipe.dart';

class ShoppingItem extends Equatable {
  const ShoppingItem({
    required this.ingredientId,
    required this.name,
    required this.unit,
    this.quantity,
    this.isChecked = false,
    this.recipeIds = const {},
  });

  factory ShoppingItem.fromJson(Map<String, Object?> json) {
    return ShoppingItem(
      ingredientId: json['ingredientId']! as String,
      name: LocalizedText.fromJson(json['name']),
      quantity: (json['quantity'] as num?)?.toDouble(),
      unit: IngredientUnit.fromName(json['unit']! as String),
      isChecked: json['checked'] as bool? ?? false,
      recipeIds: {for (final id in json['recipeIds'] as List<Object?>? ?? const []) id! as String},
    );
  }

  /// Crée un article à partir d'un ingrédient, en unité de base (g, ml)
  /// pour qu'il puisse être additionné à d'autres.
  factory ShoppingItem.fromIngredient(Ingredient ingredient, {required String recipeId}) {
    final base = ingredient.amount?.toBase();
    return ShoppingItem(
      ingredientId: ingredient.id,
      name: ingredient.name,
      quantity: base?.value,
      unit: base?.unit ?? ingredient.unit.baseUnit,
      recipeIds: {recipeId},
    );
  }

  final String ingredientId;
  final LocalizedText name;

  /// Quantité en unité de base ; `null` = « selon votre goût ».
  final double? quantity;
  final IngredientUnit unit;
  final bool isChecked;

  /// Recettes ayant contribué à cet article.
  final Set<String> recipeIds;

  /// Deux ingrédients fusionnent s'ils ont le même identifiant et une
  /// unité de base compatible (200 g + 0,5 kg de farine = 700 g).
  String get key => '$ingredientId|${unit.baseUnit.name}';

  /// Quantité arrondie et exprimée dans l'unité la plus lisible.
  Quantity? get displayQuantity => quantity == null ? null : Quantity(quantity!, unit).normalized();

  ShoppingItem mergeWith(ShoppingItem other) {
    assert(other.key == key, 'Impossible de fusionner $key et ${other.key}');
    final mergedQuantity = switch ((quantity, other.quantity)) {
      (null, null) => null,
      (final double a, null) => a,
      (null, final double b) => b,
      (final double a, final double b) => a + b,
    };
    return ShoppingItem(
      ingredientId: ingredientId,
      name: name,
      quantity: mergedQuantity,
      unit: unit,
      // `isChecked` reste à false : un besoin supplémentaire « décoche »
      // l'article.
      recipeIds: {...recipeIds, ...other.recipeIds},
    );
  }

  ShoppingItem copyWith({bool? isChecked}) => ShoppingItem(
    ingredientId: ingredientId,
    name: name,
    quantity: quantity,
    unit: unit,
    isChecked: isChecked ?? this.isChecked,
    recipeIds: recipeIds,
  );

  Map<String, Object?> toJson() => {
    'ingredientId': ingredientId,
    'name': name.toJson(),
    'quantity': quantity,
    'unit': unit.name,
    'checked': isChecked,
    'recipeIds': recipeIds.toList(),
  };

  @override
  List<Object?> get props => [ingredientId, name, quantity, unit, isChecked, recipeIds];
}

/// Liste de courses immuable. Toute la logique de fusion vit ici pour être
/// testée sans Flutter.
class ShoppingList extends Equatable {
  const ShoppingList([this.items = const []]);

  factory ShoppingList.fromJson(List<Object?> json) => ShoppingList(
    List.unmodifiable([
      for (final item in json) ShoppingItem.fromJson(item! as Map<String, Object?>),
    ]),
  );

  final List<ShoppingItem> items;

  bool get isEmpty => items.isEmpty;

  int get remainingCount => items.where((item) => !item.isChecked).length;

  int get checkedCount => items.length - remainingCount;

  /// Articles à acheter d'abord, puis articles cochés, ordre d'ajout conservé.
  List<ShoppingItem> get sortedItems => [
    ...items.where((item) => !item.isChecked),
    ...items.where((item) => item.isChecked),
  ];

  bool containsRecipe(String recipeId) => items.any((item) => item.recipeIds.contains(recipeId));

  ShoppingList addIngredients(Iterable<Ingredient> ingredients, {required String recipeId}) {
    final byKey = <String, ShoppingItem>{for (final item in items) item.key: item};
    for (final ingredient in ingredients) {
      final incoming = ShoppingItem.fromIngredient(ingredient, recipeId: recipeId);
      byKey.update(
        incoming.key,
        (existing) => existing.mergeWith(incoming),
        ifAbsent: () => incoming,
      );
    }
    return ShoppingList(List.unmodifiable(byKey.values));
  }

  ShoppingList addRecipe(Recipe recipe, {required int servings}) =>
      addIngredients(recipe.ingredientsFor(servings), recipeId: recipe.id);

  ShoppingList toggle(String key) => ShoppingList(
    List.unmodifiable([
      for (final item in items) item.key == key ? item.copyWith(isChecked: !item.isChecked) : item,
    ]),
  );

  ShoppingList remove(String key) =>
      ShoppingList(List.unmodifiable(items.where((item) => item.key != key)));

  /// Réinsère un article supprimé (action « Annuler »).
  ShoppingList insert(int index, ShoppingItem item) {
    final next = [...items.where((existing) => existing.key != item.key)];
    next.insert(index.clamp(0, next.length), item);
    return ShoppingList(List.unmodifiable(next));
  }

  ShoppingList clearChecked() =>
      ShoppingList(List.unmodifiable(items.where((item) => !item.isChecked)));

  List<Object?> toJson() => [for (final item in items) item.toJson()];

  @override
  List<Object?> get props => [items];
}
