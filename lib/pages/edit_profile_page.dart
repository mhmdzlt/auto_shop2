import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
// import 'package:image_picker/image_picker.dart'; // لاستقبال صورة جديدة (يمكن إضافتها لاحقاً)

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController emailController;
  // String? avatarUrl;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user['name'] ?? '');
    emailController = TextEditingController(text: widget.user['email'] ?? '');
    // avatarUrl = widget.user['avatar'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('edit_profile'.tr(), style: const TextStyle(color: Color(0xFF181111))),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF181111)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // زر تغيير الصورة يمكن تفعيله لاحقاً
              Center(
                child: CircleAvatar(
                  radius: 44,
                  backgroundColor: const Color(0xFFF5F0F0),
                  backgroundImage: widget.user['avatar'] != null
                      ? NetworkImage(widget.user['avatar'])
                      : null,
                  child: widget.user['avatar'] == null
                      ? Icon(Icons.person, size: 48, color: Colors.grey[500])
                      : null,
                ),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'name'.tr(),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'required'.tr() : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'email'.tr(),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  prefixIcon: const Icon(Icons.email),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'required'.tr() : null,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 22),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF93838),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // أرسل التعديلات للسيرفر/Supabase ثم أرجع للصفحة السابقة مع البيانات الجديدة
                    Navigator.pop(context, {
                      'name': nameController.text.trim(),
                      'email': emailController.text.trim(),
                      // 'avatar': avatarUrl,
                    });
                  }
                },
                child: Text('save'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
