import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/address.dart';

final addressesProvider =
    StateNotifierProvider<AddressesNotifier, AsyncValue<List<Address>>>((ref) {
      return AddressesNotifier();
    });

class AddressesNotifier extends StateNotifier<AsyncValue<List<Address>>> {
  final Box<Address> _box = Hive.box<Address>('addresses');
  final _supabase = Supabase.instance.client;

  AddressesNotifier() : super(const AsyncValue.loading()) {
    _loadLocalAddresses();
    _syncWithSupabase();
  }

  void _loadLocalAddresses() {
    try {
      final localAddresses = _box.values.toList();
      state = AsyncValue.data(localAddresses);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> _syncWithSupabase() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final response = await _supabase
          .from('addresses')
          .select()
          .eq('user_id', user.id);

      final remoteAddresses = (response as List)
          .map((json) => Address.fromJson(json))
          .toList();

      // حفظ العناوين السحابية محلياً
      await _box.clear();
      for (var address in remoteAddresses) {
        await _box.put(address.id, address);
      }

      state = AsyncValue.data(remoteAddresses);
    } catch (e) {
      print('خطأ في مزامنة العناوين: $e');
      // Keep local data on sync error
      final localAddresses = _box.values.toList();
      state = AsyncValue.data(localAddresses);
    }
  }

  Future<void> addAddress(Address address) async {
    try {
      // حفظ محلي
      await _box.put(address.id, address);
      final currentAddresses = state.asData?.value ?? [];
      state = AsyncValue.data([...currentAddresses, address]);

      // حفظ سحابي
      final user = _supabase.auth.currentUser;
      if (user != null) {
        await _supabase.from('addresses').insert(address.toJson());
      }
    } catch (e) {
      print('خطأ في إضافة العنوان: $e');
    }
  }

  Future<void> updateAddress(Address address) async {
    try {
      // تحديث محلي
      await _box.put(address.id, address);
      final currentAddresses = state.asData?.value ?? [];
      final updatedAddresses = currentAddresses
          .map((a) => a.id == address.id ? address : a)
          .toList();
      state = AsyncValue.data(updatedAddresses);

      // تحديث سحابي
      final user = _supabase.auth.currentUser;
      if (user != null) {
        await _supabase
            .from('addresses')
            .update(address.toJson())
            .eq('id', address.id);
      }
    } catch (e) {
      print('خطأ في تحديث العنوان: $e');
    }
  }

  Future<void> deleteAddress(String addressId) async {
    try {
      // حذف محلي
      await _box.delete(addressId);
      final currentAddresses = state.asData?.value ?? [];
      final filteredAddresses = currentAddresses
          .where((a) => a.id != addressId)
          .toList();
      state = AsyncValue.data(filteredAddresses);

      // حذف سحابي
      final user = _supabase.auth.currentUser;
      if (user != null) {
        await _supabase.from('addresses').delete().eq('id', addressId);
      }
    } catch (e) {
      print('خطأ في حذف العنوان: $e');
    }
  }

  Future<void> setDefaultAddress(String addressId) async {
    try {
      // إزالة الافتراضي من جميع العناوين
      final currentAddresses = state.asData?.value ?? [];
      final updatedAddresses = currentAddresses.map((address) {
        return Address(
          id: address.id,
          title: address.title,
          details: address.details,
          userId: address.userId,
          isDefault: address.id == addressId,
          phone: address.phone,
          city: address.city,
          country: address.country,
          createdAt: address.createdAt,
          updatedAt: DateTime.now(),
        );
      }).toList();

      // حفظ محلي
      await _box.clear();
      for (var address in updatedAddresses) {
        await _box.put(address.id, address);
      }
      state = AsyncValue.data(updatedAddresses);

      // تحديث سحابي
      final user = _supabase.auth.currentUser;
      if (user != null) {
        // إزالة الافتراضي من جميع العناوين
        await _supabase
            .from('addresses')
            .update({'is_default': false})
            .eq('user_id', user.id);

        // تعيين الافتراضي للعنوان المحدد
        await _supabase
            .from('addresses')
            .update({'is_default': true})
            .eq('id', addressId);
      }
    } catch (e) {
      print('خطأ في تعيين العنوان الافتراضي: $e');
    }
  }

  Address? get defaultAddress {
    final addresses = state.asData?.value ?? [];
    return addresses.where((a) => a.isDefault).firstOrNull;
  }
}
