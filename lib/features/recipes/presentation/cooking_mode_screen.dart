import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/widgets/status_views.dart';
import '../application/recipe_providers.dart';
import '../domain/recipe.dart';

/// Mode cuisine : une étape par page, en grand, navigable au doigt,
/// aux boutons ou aux flèches du clavier.
class CookingModeScreen extends ConsumerWidget {
  const CookingModeScreen({required this.recipeId, super.key});

  final String recipeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(recipeProvider(recipeId))
        .when(
          data: (recipe) => _CookingView(recipe: recipe),
          loading: () => Scaffold(appBar: AppBar(), body: const LoadingView()),
          error: (_, _) => Scaffold(
            appBar: AppBar(),
            body: ErrorView(message: context.l10n.recipeNotFound),
          ),
        );
  }
}

class _CookingView extends HookWidget {
  const _CookingView({required this.recipe});

  static const _pageTransition = Duration(milliseconds: 300);

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = usePageController();
    final page = useState(0);
    final total = recipe.steps.length;
    final isFirst = page.value == 0;
    final isLast = page.value == total - 1;

    void goTo(int index) {
      if (index < 0 || index >= total) return;
      controller.animateToPage(index, duration: _pageTransition, curve: Curves.easeInOut);
    }

    void finish() {
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(SnackBar(content: Text(l10n.cookingDone)));
    }

    final progressLabel = l10n.cookingStepProgress(page.value + 1, total);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowRight): () => goTo(page.value + 1),
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () => goTo(page.value - 1),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(
            leading: const CloseButton(),
            title: Text(context.tr(recipe.title)),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(4),
              child: LinearProgressIndicator(
                value: (page.value + 1) / total,
                semanticsLabel: progressLabel,
              ),
            ),
          ),
          body: PageView.builder(
            controller: controller,
            itemCount: total,
            onPageChanged: (index) => page.value = index,
            itemBuilder: (context, index) => _StepPage(
              label: l10n.cookingStepProgress(index + 1, total),
              text: context.tr(recipe.steps[index]),
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: isFirst ? null : () => goTo(page.value - 1),
                    icon: const Icon(Icons.arrow_back),
                    label: Text(l10n.previousStep),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: isLast ? finish : () => goTo(page.value + 1),
                    icon: Icon(isLast ? Icons.check : Icons.arrow_forward),
                    label: Text(isLast ? l10n.finishCooking : l10n.nextStep),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StepPage extends StatelessWidget {
  const _StepPage({required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Semantics(
            liveRegion: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary),
                ),
                const SizedBox(height: 16),
                Text(text, style: theme.textTheme.headlineSmall?.copyWith(height: 1.4)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
