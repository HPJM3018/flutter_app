import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miam/features/recipes/application/recipe_providers.dart';
import 'package:miam/features/recipes/data/recipe_repository.dart';
import 'package:miam/features/recipes/domain/recipe.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockRecipeRepository repository;

  ProviderContainer createContainer() => ProviderContainer.test(
    overrides: [recipeRepositoryProvider.overrideWithValue(repository)],
    retry: (_, _) => null,
  );

  setUp(() {
    repository = MockRecipeRepository();
    when(() => repository.fetchRecipes()).thenAnswer((_) async => sampleRecipes);
  });

  test('recipesProvider interroge le dépôt une seule fois', () async {
    final container = createContainer();

    await container.read(recipesProvider.future);
    await container.read(recipesProvider.future);

    verify(() => repository.fetchRecipes()).called(1);
  });

  test('filteredRecipesProvider applique la requête courante', () async {
    final container = createContainer();
    await container.read(recipesProvider.future);

    container.read(recipeQueryProvider.notifier)
      ..toggleCategory(RecipeCategory.breakfast)
      ..toggleVegetarian();

    final results = container.read(filteredRecipesProvider).requireValue;
    expect(results.map((recipe) => recipe.id), ['omelette']);
  });

  test('RecipeQueryNotifier : resélectionner une catégorie la retire, reset vide tout', () {
    final container = createContainer();
    final notifier = container.read(recipeQueryProvider.notifier);

    notifier.toggleCategory(RecipeCategory.main);
    expect(container.read(recipeQueryProvider).category, RecipeCategory.main);

    notifier.toggleCategory(RecipeCategory.main);
    expect(container.read(recipeQueryProvider).category, isNull);

    notifier
      ..setSearchTerm('tarte')
      ..toggleQuick()
      ..reset();
    expect(container.read(recipeQueryProvider).isEmpty, isTrue);
  });

  test('recipeProvider lève RecipeNotFoundException pour un id inconnu', () async {
    final container = createContainer();
    final subscription = container.listen(recipeProvider('inconnue'), (_, _) {});
    addTearDown(subscription.close);

    await expectLater(
      container.read(recipeProvider('inconnue').future),
      throwsA(isA<RecipeNotFoundException>()),
    );
    expect((await container.read(recipeProvider('boeuf').future)).servings, 6);
  });

  test('une erreur du dépôt est exposée puis récupérable via invalidate', () async {
    when(() => repository.fetchRecipes()).thenThrow(const RecipeParseException('boom'));
    final container = createContainer();
    final subscription = container.listen(recipesProvider, (_, _) {});
    addTearDown(subscription.close);

    await expectLater(container.read(recipesProvider.future), throwsA(isA<RecipeParseException>()));
    expect(container.read(filteredRecipesProvider).hasError, isTrue);

    when(() => repository.fetchRecipes()).thenAnswer((_) async => sampleRecipes);
    container.invalidate(recipesProvider);

    expect(await container.read(recipesProvider.future), hasLength(sampleRecipes.length));
  });
}
