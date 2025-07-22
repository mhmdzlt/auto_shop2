import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/address.dart';
import '../providers/addresses_provider.dart';

class AddressesPage extends ConsumerWidget {
  const AddressesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesAsync = ref.watch(addressesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'addresses'.tr(),
          style: const TextStyle(color: Color(0xFF181111)),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF181111)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: LanguageSelector(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddressDialog(context, ref),
        backgroundColor: const Color(0xFFF93838),
        tooltip: 'add_address'.tr(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: addressesAsync.when(
        data: (addresses) => addresses.isEmpty
            ? Center(
                child: Text(
                  'no_addresses'.tr(),
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(18),
                itemCount: addresses.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, i) {
                  final addr = addresses[i];
                  return ListTile(
                    leading: Icon(
                      addr.isDefault ? Icons.home : Icons.location_on,
                      color: addr.isDefault
                          ? Colors.green
                          : const Color(0xFFF93838),
                    ),
                    title: Text(
                      addr.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF181111),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          addr.details,
                          style: const TextStyle(fontSize: 13),
                        ),
                        if (addr.isDefault)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'default_address'.tr(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) => _handleAddressAction(
                        context,
                        ref,
                        value,
                        addr,
                        addresses,
                      ),
                      itemBuilder: (context) => [
                        if (!addr.isDefault)
                          PopupMenuItem(
                            value: 'set_default',
                            child: Row(
                              children: [
                                const Icon(Icons.home, size: 16),
                                const SizedBox(width: 8),
                                Text('set_as_default'.tr()),
                              ],
                            ),
                          ),
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              const Icon(Icons.edit, size: 16),
                              const SizedBox(width: 8),
                              Text('edit'.tr()),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.delete,
                                size: 16,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'delete'.tr(),
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text('error_loading_addresses'.tr()),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.refresh(addressesProvider),
                child: Text('retry'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAddressAction(
    BuildContext context,
    WidgetRef ref,
    String action,
    Address address,
    List<Address> addresses,
  ) async {
    switch (action) {
      case 'set_default':
        await ref
            .read(addressesProvider.notifier)
            .setDefaultAddress(address.id);
        break;
      case 'edit':
        await _showAddressDialog(context, ref, address: address);
        break;
      case 'delete':
        _showDeleteDialog(context, ref, address);
        break;
    }
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Address address) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('delete_address'.tr()),
        content: Text('are_you_sure_delete'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(addressesProvider.notifier)
                  .deleteAddress(address.id);
            },
            child: Text(
              'delete'.tr(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddressDialog(
    BuildContext context,
    WidgetRef ref, {
    Address? address,
  }) async {
    final result = await showDialog<Address>(
      context: context,
      builder: (_) => AddressDialog(address: address),
    );

    if (result != null) {
      if (address == null) {
        // Adding new address
        await ref.read(addressesProvider.notifier).addAddress(result);
      } else {
        // Editing existing address
        await ref.read(addressesProvider.notifier).updateAddress(result);
      }
    }
  }
}

class AddressDialog extends StatefulWidget {
  final Address? address;
  const AddressDialog({super.key, this.address});
  @override
  State<AddressDialog> createState() => _AddressDialogState();
}

class _AddressDialogState extends State<AddressDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController detailsController;
  late TextEditingController phoneController;
  late TextEditingController cityController;
  late TextEditingController countryController;
  bool isDefault = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.address?.title ?? '');
    detailsController = TextEditingController(
      text: widget.address?.details ?? '',
    );
    phoneController = TextEditingController(text: widget.address?.phone ?? '');
    cityController = TextEditingController(text: widget.address?.city ?? '');
    countryController = TextEditingController(
      text: widget.address?.country ?? '',
    );
    isDefault = widget.address?.isDefault ?? false;
  }

  @override
  void dispose() {
    titleController.dispose();
    detailsController.dispose();
    phoneController.dispose();
    cityController.dispose();
    countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.address == null ? 'add_address'.tr() : 'edit_address'.tr(),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'address_title'.tr(),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'required'.tr() : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: detailsController,
                decoration: InputDecoration(
                  labelText: 'address_details'.tr(),
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'required'.tr() : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'phone_number'.tr(),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: cityController,
                      decoration: InputDecoration(
                        labelText: 'city'.tr(),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: countryController,
                      decoration: InputDecoration(
                        labelText: 'country'.tr(),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: isDefault,
                    onChanged: (value) =>
                        setState(() => isDefault = value ?? false),
                  ),
                  Text('set_as_default'.tr()),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr()),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final address = Address(
                id:
                    widget.address?.id ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                title: titleController.text.trim(),
                details: detailsController.text.trim(),
                userId: Supabase.instance.client.auth.currentUser?.id ?? '',
                phone: phoneController.text.trim().isEmpty
                    ? null
                    : phoneController.text.trim(),
                city: cityController.text.trim().isEmpty
                    ? null
                    : cityController.text.trim(),
                country: countryController.text.trim().isEmpty
                    ? null
                    : countryController.text.trim(),
                isDefault: isDefault,
                createdAt: widget.address?.createdAt ?? DateTime.now(),
                updatedAt: DateTime.now(),
              );
              Navigator.pop(context, address);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF93838),
            foregroundColor: Colors.white,
          ),
          child: Text(widget.address == null ? 'add'.tr() : 'save'.tr()),
        ),
      ],
    );
  }
}

// ويدجت اختيار اللغة
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final locales = [
      {'locale': const Locale('ar'), 'name': 'العربية'},
      {'locale': const Locale('en'), 'name': 'English'},
      {'locale': const Locale('ku'), 'name': 'کوردی'},
    ];
    return DropdownButton<Locale>(
      value: context.locale,
      underline: const SizedBox(),
      icon: const Icon(Icons.language, color: Color(0xFF8c5f5f)),
      onChanged: (locale) {
        context.setLocale(locale!);
      },
      items: locales
          .map(
            (e) => DropdownMenuItem(
              value: e['locale'] as Locale,
              child: Text(e['name'] as String),
            ),
          )
          .toList(),
    );
  }
}
