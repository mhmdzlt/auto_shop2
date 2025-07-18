# 🚗 Auto Shop 2 – Flutter + Supabase

تطبيق جوّال متعدد المنصّات (Android، iOS، Web) لإدارة متجر أو ورشة لقطع غيار السيارات.

## 🎯 الميزات
- تسجيل الدخول وإنشاء حساب باستخدام Supabase
- استعراض قائمة القطع وتفاصيلها
- حفظ القطع كمفضّلة، حتى بدون اتصال (Offline-first عبر Hive)
- تعرّف ذكي على القطعة عبر التصوير وتحليل الصورة
- دعم التوطين الكامل (عربي، إنجليزي، كردي)
- ثيم مخصص وخطوط عربية باستخدام GoogleFonts
- واجهات جاهزة لأتمتة CI/CD عبر GitHub Actions (قريبًا)

## ⚙️ التقنيات المستخدمة
| التقنية           | الاستخدام                                 |
|------------------|-------------------------------------------|
| Flutter          | تطوير الواجهات متعددة المنصات             |
| Supabase         | مصادقة المستخدم، قاعدة البيانات            |
| Hive             | تخزين محلي للمفضلات والمنتجات             |
| Easy Localization| الترجمة بين اللغات الثلاثة                |
| Riverpod (قريبًا)| إدارة الحالة                               |
| GitHub Actions   | اختبارات تلقائية وتشغيل CI (تحت الإعداد)   |

## 🛠️ التثبيت والتشغيل

```bash
flutter pub get
flutter run
```

لإعداد Supabase:
أنشئ مشروع جديد من Supabase.io

انسخ anonKey و url إلى ملف main.dart

أنشئ الجداول التالية:

- parts مع الحقول (id, name, image_url, description, price)
- favorites مع الحقول (user_id, part_id)

📦 بنية المشروع
```
auto_shop2/
├─ lib/
│   ├─ models/               ← نموذج البيانات (Part)
│   ├─ pages/                ← صفحات الواجهة
│   ├─ storage/              ← تخزين محلي (Hive)
│   ├─ services/             ← مزامنة البيانات
│   ├─ main.dart             ← نقطة الانطلاق
├─ assets/translations/     ← ملفات JSON للترجمة
├─ test/                    ← اختبارات الوحدة
├─ README.md                ← ملف التوثيق
```

🧪 الاختبارات
لتشغيل اختبارات التخزين:

```bash
flutter test test/favorites_storage_test.dart
```

🤝 المساهمة
Fork المشروع

أنشئ فرع جديد feature/اسم-الميزة

أرسل Pull Request

تأكّد من أن الكود يمر بالاختبارات قبل الدمج

📌 ملاحظة مستقبلية: سيتم دعم:

- عربة التسوق والدفع الإلكتروني
- إدارة الطلبات والإشعارات (Push)
- مزامنة ثنائية بين Hive و Supabase
- توثيق لكل صفحة ومكوّن (بأمثلة)
