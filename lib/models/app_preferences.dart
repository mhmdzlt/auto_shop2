import 'package:hive/hive.dart';
part 'app_preferences.g.dart';

@HiveType(typeId: 2)
class AppPreferences extends HiveObject {
  @HiveField(0)
  bool notificationsEnabled;

  @HiveField(1)
  bool isDarkMode;

  @HiveField(2)
  String languageCode;

  AppPreferences({
    required this.notificationsEnabled,
    required this.isDarkMode,
    required this.languageCode,
  });
}
