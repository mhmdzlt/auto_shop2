import 'package:hive_flutter/hive_flutter.dart';

class FavoritesStorage {
  static const String _favoritesBox = 'favorites';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(_favoritesBox);
  }

  static Future<void> addFavorite(String itemId) async {
    final box = Hive.box<String>(_favoritesBox);
    await box.put(itemId, itemId);
  }

  static Future<void> removeFavorite(String itemId) async {
    final box = Hive.box<String>(_favoritesBox);
    await box.delete(itemId);
  }

  static List<String> getFavorites() {
    final box = Hive.box<String>(_favoritesBox);
    return box.values.toList();
  }

  static bool isFavorite(String itemId) {
    final box = Hive.box<String>(_favoritesBox);
    return box.containsKey(itemId);
  }
}
