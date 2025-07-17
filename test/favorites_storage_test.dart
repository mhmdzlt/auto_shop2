import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:auto_shop/models/part.dart';
import 'package:auto_shop/storage/favorites_storage.dart';

void main() {
  // مجلد مؤقت لبيانات Hive أثناء الاختبار
  Directory? tempDir;
  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp();
    Hive.init(tempDir!.path);
    Hive.registerAdapter(PartAdapter());
    await Hive.openBox<Part>('favorites');
  });

  tearDownAll(() async {
    await Hive.box<Part>('favorites').clear();
    await Hive.close();
    if (tempDir != null) {
      await tempDir!.delete(recursive: true);
    }
  });

  group('FavoritesStorage', () {
    test('initially empty', () {
      expect(FavoritesStorage.getAll(), isEmpty);
    });

    test('add and contains', () {
      final part = Part(
        id: 'p1',
        name: 'Test Part',
        description: 'Test Description',
        imageUrl: 'http://example.com/img.png',
        price: 42.0,
      );
      FavoritesStorage.add(part);

      expect(FavoritesStorage.contains('p1'), isTrue);
      expect(FavoritesStorage.getAll(), contains(part));
    });

    test('remove', () {
      FavoritesStorage.remove('p1');

      expect(FavoritesStorage.contains('p1'), isFalse);
      expect(FavoritesStorage.getAll(), isEmpty);
    });
  });
}
