import 'package:hive/hive.dart';
import '../models/part.dart';

class FavoritesStorage {
  static const String _boxName = 'favorites';

  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PartAdapter());
    }
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<Part>(_boxName);
    }
  }

  static List<Part> getAll() => _box.values.toList();

  static void add(Part part) => _box.put(part.id, part);

  static void remove(String id) => _box.delete(id);

  static bool contains(String id) => _box.containsKey(id);
  static Box<Part> get _box {
    if (!Hive.isBoxOpen(_boxName)) {
      throw HiveError('Box $_boxName is not open. Call init() first.');
    }
    return Hive.box<Part>(_boxName);
  }
}
