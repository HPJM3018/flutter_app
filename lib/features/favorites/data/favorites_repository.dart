import 'package:shared_preferences/shared_preferences.dart';

class FavoritesRepository {
  const FavoritesRepository(this._prefs);

  static const storageKey = 'favorites.ids.v1';

  final SharedPreferences _prefs;

  /// Les favoris sont stockés dans l'ordre d'ajout.
  List<String> load() => _prefs.getStringList(storageKey) ?? const [];

  Future<void> save(Iterable<String> ids) => _prefs.setStringList(storageKey, ids.toList());
}
