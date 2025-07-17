import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/part.dart';
import '../storage/favorites_storage.dart';

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<Part>>(
  (ref) => FavoritesNotifier(),
);

class FavoritesNotifier extends StateNotifier<List<Part>> {
  FavoritesNotifier() : super(FavoritesStorage.getAll());

  void add(Part part) {
    FavoritesStorage.add(part);
    state = FavoritesStorage.getAll();
  }

  void remove(String id) {
    FavoritesStorage.remove(id);
    state = FavoritesStorage.getAll();
  }

  bool contains(String id) {
    return FavoritesStorage.contains(id);
  }

  void refresh() {
    state = FavoritesStorage.getAll();
  }
}
