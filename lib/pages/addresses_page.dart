import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AddressesPage extends StatefulWidget {
  final List<Map<String, String>> addresses;

  const AddressesPage({super.key, required this.addresses});

  @override
  State<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  late List<Map<String, String>> addresses;

  @override
  void initState() {
    super.initState();
    addresses = List.from(widget.addresses);
  }

  void _addAddress() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => AddressDialog(),
    );
    if (result != null) {
      setState(() {
        addresses.add(result);
      });
    }
  }

  void _editAddress(int idx) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => AddressDialog(address: addresses[idx]),
    );
    if (result != null) {
      setState(() {
        addresses[idx] = result;
      });
    }
  }

  void _deleteAddress(int idx) {
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
            onPressed: () {
              setState(() {
                addresses.removeAt(idx);
              });
              Navigator.pop(context);
            },
            child: Text('delete'.tr(), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('addresses'.tr(), style: const TextStyle(color: Color(0xFF181111))),
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
        onPressed: _addAddress,
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color(0xFFF93838),
        tooltip: 'add_address'.tr(),
      ),
      body: addresses.isEmpty
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
                  leading: const Icon(Icons.location_on, color: Color(0xFFF93838)),
                  title: Text(
                    addr['title'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF181111)),
                  ),
                  subtitle: Text(addr['details'] ?? '', style: const TextStyle(fontSize: 13)),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'edit') _editAddress(i);
                      if (v == 'delete') _deleteAddress(i);
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'edit', child: Text('edit'.tr())),
                      PopupMenuItem(value: 'delete', child: Text('delete'.tr(), style: const TextStyle(color: Colors.red))),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class AddressDialog extends StatefulWidget {
  final Map<String, String>? address;
  const AddressDialog({super.key, this.address});
  @override
  State<AddressDialog> createState() => _AddressDialogState();
}

class _AddressDialogState extends State<AddressDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController detailsController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.address?['title'] ?? '');
    detailsController = TextEditingController(text: widget.address?['details'] ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.address == null ? 'add_address'.tr() : 'edit_address'.tr()),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'address_title'.tr()),
              validator: (v) => v == null || v.trim().isEmpty ? 'required'.tr() : null,
            ),
            TextFormField(
              controller: detailsController,
              decoration: InputDecoration(labelText: 'address_details'.tr()),
              validator: (v) => v == null || v.trim().isEmpty ? 'required'.tr() : null,
            ),
          ],
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
              Navigator.pop(context, {
                'title': titleController.text.trim(),
                'details': detailsController.text.trim(),
              });
            }
          },
          child: Text(widget.address == null ? 'add'.tr() : 'save'.tr()),
        ),
      ],
    );
  }
}

// ويدجت اختيار اللغة
class LanguageSelector extends StatelessWidget {
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
