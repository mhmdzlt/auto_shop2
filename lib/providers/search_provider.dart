import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final searchQueryProvider = StateNotifierProvider<SearchQueryNotifier, String>(
  (ref) => SearchQueryNotifier(),
);

class SearchQueryNotifier extends StateNotifier<String> {
  SearchQueryNotifier() : super('');
  void setQuery(String query) => state = query;
}

final searchResultsProvider = FutureProvider.autoDispose<List<dynamic>>((
  ref,
) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];
  final response = await Supabase.instance.client
      .from('products')
      .select()
      .ilike('name', '%$query%');
  return response;
});
