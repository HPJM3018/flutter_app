import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'core/l10n/l10n.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/application/settings_providers.dart';

class MiamApp extends ConsumerWidget {
  const MiamApp({super.key});

  static const localizationsDelegates = <LocalizationsDelegate<Object?>>[
    AppLocalizations.delegate,
    ...GlobalMaterialLocalizations.delegates,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    // `select` : l'app ne se reconstruit que si le thème ou la langue
    // changent, pas quand l'onboarding est validé.
    final theme = ref.watch(settingsProvider.select((settings) => settings.theme));
    final languageCode = ref.watch(
      settingsProvider.select((settings) => settings.language.languageCode),
    );

    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: theme.themeMode,
      locale: languageCode == null ? null : Locale(languageCode),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: localizationsDelegates,
      routerConfig: router,
    );
  }
}
