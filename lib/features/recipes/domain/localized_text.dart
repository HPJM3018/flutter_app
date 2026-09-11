import 'package:equatable/equatable.dart';

/// Texte de contenu disponible en plusieurs langues (`{"fr": ..., "en": ...}`).
///
/// L'interface est traduite via ARB ; ce type sert au *contenu* des recettes.
class LocalizedText extends Equatable {
  const LocalizedText(this.translations);

  /// Accepte une chaîne simple (non traduite) ou une map langue → texte.
  factory LocalizedText.fromJson(Object? json) {
    return switch (json) {
      final String text => LocalizedText({fallbackLanguage: text}),
      final Map<String, Object?> map => LocalizedText({
        for (final entry in map.entries)
          if (entry.value case final String value) entry.key: value,
      }),
      _ => throw FormatException('Texte localisé invalide : $json'),
    };
  }

  /// Langue utilisée quand la traduction demandée est absente.
  static const fallbackLanguage = 'en';

  final Map<String, String> translations;

  /// Texte dans [languageCode], sinon en anglais, sinon la première valeur.
  String resolve(String languageCode) {
    return translations[languageCode] ??
        translations[fallbackLanguage] ??
        (translations.isEmpty ? '' : translations.values.first);
  }

  /// Toutes les variantes, utile pour une recherche multilingue.
  Iterable<String> get allValues => translations.values;

  Map<String, String> toJson() => translations;

  @override
  List<Object?> get props => [translations];
}
