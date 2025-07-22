import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/app_preferences.dart';

final preferencesProvider =
    StateNotifierProvider<PreferencesNotifier, AppPreferences>((ref) {
      final box = Hive.box<AppPreferences>('preferences');
      final saved =
          box.get('prefs') ??
          AppPreferences(
            notificationsEnabled: true,
            isDarkMode: false,
            languageCode: 'ar',
          );
      return PreferencesNotifier(saved);
    });

class PreferencesNotifier extends StateNotifier<AppPreferences> {
  final Box<AppPreferences> _box = Hive.box<AppPreferences>('preferences');

  PreferencesNotifier(super.prefs) {
    // حفظ التفضيلات الأولية إذا لم تكن محفوظة
    if (_box.get('prefs') == null) {
      _savePreferences();
    }
  }

  void _savePreferences() {
    _box.put('prefs', state);
  }

  void toggleNotifications() {
    state = AppPreferences(
      notificationsEnabled: !state.notificationsEnabled,
      isDarkMode: state.isDarkMode,
      languageCode: state.languageCode,
    );
    _savePreferences();
  }

  void toggleDarkMode() {
    state = AppPreferences(
      notificationsEnabled: state.notificationsEnabled,
      isDarkMode: !state.isDarkMode,
      languageCode: state.languageCode,
    );
    _savePreferences();
  }

  void setLanguage(String code) {
    state = AppPreferences(
      notificationsEnabled: state.notificationsEnabled,
      isDarkMode: state.isDarkMode,
      languageCode: code,
    );
    _savePreferences();
  }
}
