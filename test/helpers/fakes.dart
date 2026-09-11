import 'dart:typed_data';

import 'package:flutter/painting.dart';
import 'package:miam/features/recipes/data/recipe_repository.dart';
import 'package:miam/features/recipes/domain/recipe.dart';
import 'package:mocktail/mocktail.dart';

class MockRecipeRepository extends Mock implements RecipeRepository {}

/// Dépôt en mémoire, avec compteur d'appels et erreur optionnelle.
class FakeRecipeRepository implements RecipeRepository {
  FakeRecipeRepository(this.recipes, {this.error});

  final List<Recipe> recipes;
  Object? error;
  int fetchCount = 0;

  @override
  Future<List<Recipe>> fetchRecipes() async {
    fetchCount++;
    if (error case final Object error) throw error;
    return recipes;
  }

  @override
  Future<Recipe> fetchRecipe(String id) async {
    final all = await fetchRecipes();
    return all.firstWhere(
      (recipe) => recipe.id == id,
      orElse: () => throw RecipeNotFoundException(id),
    );
  }
}

/// PNG transparent de 1×1 pixel : les tests n'accèdent jamais au réseau.
final Uint8List transparentPng = Uint8List.fromList(const [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, //
  0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F,
  0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00,
  0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

ImageProvider testImageProviderBuilder(String url, {int? cacheWidth}) =>
    MemoryImage(transparentPng);
