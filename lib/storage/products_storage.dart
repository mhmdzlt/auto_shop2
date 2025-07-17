import 'package:hive/hive.dart';
import '../models/part.dart'; // استيراد فئة Part

class ProductsStorage {
  static Box<Part> get _box => Hive.box<Part>('products');

  static List<Part> getAll() => _box.values.toList();

  static void addAll(List<Part> parts) {
    for (var part in parts) {
      _box.put(part.id, part);
    }
  }

  static void clear() => _box.clear();
}
