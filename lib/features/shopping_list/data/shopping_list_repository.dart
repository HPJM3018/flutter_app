import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/shopping_list.dart';

class ShoppingListRepository {
  const ShoppingListRepository(this._prefs);

  static const storageKey = 'shopping_list.items.v1';

  final SharedPreferences _prefs;

  /// Une donnée corrompue ne doit jamais empêcher l'app de démarrer :
  /// on repart d'une liste vide.
  ShoppingList load() {
    final raw = _prefs.getString(storageKey);
    if (raw == null) return const ShoppingList();
    try {
      return ShoppingList.fromJson(jsonDecode(raw) as List<Object?>);
    } on Object catch (error) {
      debugPrint('Liste de courses illisible, réinitialisée : $error');
      return const ShoppingList();
    }
  }

  Future<void> save(ShoppingList list) => _prefs.setString(storageKey, jsonEncode(list.toJson()));
}
