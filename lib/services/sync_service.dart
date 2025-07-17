import 'package:supabase_flutter/supabase_flutter.dart';
import '../favorites_storage.dart';

class SyncService {
  static Future<void> syncFavoritesWithSupabase() async {
    final client = Supabase.instance.client;

    if (client.auth.currentSession == null) {
      return; // المستخدم غير متصل أو لم يسجل الدخول
    }

    final localFavorites = FavoritesStorage.getFavorites();

    for (var partId in localFavorites) {
      // تحقق من وجود القطعة في Supabase، وإذا لم تكن موجودة أضفها
      final response = await client
          .from('favorites')
          .select()
          .eq('part_id', partId)
          .maybeSingle();

      if (response == null) {
        await client.from('favorites').insert({
          'user_id': client.auth.currentUser!.id,
          'part_id': partId,
        });
      }
    }
  }
}
