import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/app_info.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/router/app_router.dart';
import '../application/settings_providers.dart';
import '../domain/app_settings.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _SectionHeader(l10n.languageSection),
          RadioGroup<LanguagePreference>(
            groupValue: settings.language,
            onChanged: (value) {
              if (value != null) notifier.setLanguage(value);
            },
            child: Column(
              children: [
                for (final language in LanguagePreference.values)
                  RadioListTile<LanguagePreference>(
                    value: language,
                    title: _LanguageLabel(language),
                  ),
              ],
            ),
          ),
          const Divider(),
          _SectionHeader(l10n.themeSection),
          RadioGroup<ThemePreference>(
            groupValue: settings.theme,
            onChanged: (value) {
              if (value != null) notifier.setTheme(value);
            },
            child: Column(
              children: [
                for (final theme in ThemePreference.values)
                  RadioListTile<ThemePreference>(
                    value: theme,
                    title: Text(switch (theme) {
                      ThemePreference.system => l10n.themeSystem,
                      ThemePreference.light => l10n.themeLight,
                      ThemePreference.dark => l10n.themeDark,
                    }),
                    secondary: ExcludeSemantics(
                      child: Icon(switch (theme) {
                        ThemePreference.system => Icons.brightness_auto_outlined,
                        ThemePreference.light => Icons.light_mode_outlined,
                        ThemePreference.dark => Icons.dark_mode_outlined,
                      }),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(),
          _SectionHeader(l10n.aboutSection),
          ListTile(
            leading: const Icon(Icons.replay),
            title: Text(l10n.replayOnboarding),
            onTap: () async {
              await notifier.resetOnboarding();
              if (context.mounted) context.go(AppRoutes.onboarding);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.aboutApp),
            subtitle: Text(l10n.appVersion(AppInfo.version)),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: AppInfo.name,
              applicationVersion: AppInfo.version,
              applicationLegalese: l10n.appLegalese,
              applicationIcon: const Icon(Icons.restaurant_menu, size: 40),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Semantics(
        header: true,
        child: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary),
        ),
      ),
    );
  }
}

/// Le nom de chaque langue est écrit dans cette langue et balisé comme tel,
/// pour que le lecteur d'écran le prononce correctement.
class _LanguageLabel extends StatelessWidget {
  const _LanguageLabel(this.language);

  final LanguagePreference language;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final label = switch (language) {
      LanguagePreference.system => l10n.languageSystem,
      LanguagePreference.french => l10n.languageFrench,
      LanguagePreference.english => l10n.languageEnglish,
    };
    final code = language.languageCode;
    return Text.rich(TextSpan(text: label, locale: code == null ? null : Locale(code)));
  }
}
