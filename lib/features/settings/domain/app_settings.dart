import 'package:equatable/equatable.dart';

enum ThemePreference { system, light, dark }

/// Langue choisie par l'utilisateur ; [system] suit la langue de l'appareil.
enum LanguagePreference {
  system(null),
  french('fr'),
  english('en');

  const LanguagePreference(this.languageCode);

  final String? languageCode;

  static LanguagePreference fromCode(String? code) => LanguagePreference.values.firstWhere(
    (preference) => preference.languageCode == code,
    orElse: () => system,
  );
}

class AppSettings extends Equatable {
  const AppSettings({
    this.theme = ThemePreference.system,
    this.language = LanguagePreference.system,
    this.onboardingCompleted = false,
  });

  final ThemePreference theme;
  final LanguagePreference language;
  final bool onboardingCompleted;

  AppSettings copyWith({
    ThemePreference? theme,
    LanguagePreference? language,
    bool? onboardingCompleted,
  }) {
    return AppSettings(
      theme: theme ?? this.theme,
      language: language ?? this.language,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }

  @override
  List<Object?> get props => [theme, language, onboardingCompleted];
}
