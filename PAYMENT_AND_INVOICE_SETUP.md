# 💳 دليل إعداد الدفع الإلكتروني + فواتير PDF

## 🎯 الميزات المضافة

### ✅ الدفع الحقيقي مع Stripe
- ✅ **دفع آمن**: معالجة آمنة للبطاقات الائتمانية
- ✅ **بيئة اختبار**: إمكانية اختبار الدفع بدون تكاليف
- ✅ **تتبع المدفوعات**: حفظ تفاصيل المعاملات في قاعدة البيانات
- ✅ **دعم متعدد العملات**: USD افتراضياً مع إمكانية التوسع

### ✅ توليد الفواتير PDF
- ✅ **فواتير احترافية**: تصميم جميل بالعربية والإنجليزية
- ✅ **تحميل ومشاركة**: إمكانية تحميل أو مشاركة الفاتورة
- ✅ **متاحة بعد الدفع**: الفواتير متاحة فقط للطلبات المدفوعة
- ✅ **معلومات شاملة**: تفاصيل الطلب، المنتجات، والدفع

## 🛠️ خطوات الإعداد

### 1. إعداد Stripe

#### أ) إنشاء حساب Stripe
1. اذهب إلى [Stripe Dashboard](https://dashboard.stripe.com)
2. أنشئ حساب جديد أو سجل دخول
3. انتقل إلى **Developers** → **API keys**

#### ب) الحصول على المفاتيح
```bash
# مفاتيح التطوير (Test Mode)
Publishable key: pk_test_xxxxxxxxxxxxx
Secret key: sk_test_xxxxxxxxxxxxx

# مفاتيح الإنتاج (Live Mode) - استخدمها لاحقاً
Publishable key: pk_live_xxxxxxxxxxxxx  
Secret key: sk_live_xxxxxxxxxxxxx
```

#### ج) تحديث PaymentService
في ملف `lib/services/payment_service.dart`:
```dart
static const String _publishableKey = 'pk_test_YOUR_KEY_HERE';
```

### 2. إعداد Supabase

#### أ) تشغيل الجداول
قم بتشغيل ملف `supabase_tables/payment_transactions.sql` في Supabase SQL Editor:
```sql
-- سيتم إنشاء جدول payment_transactions
-- وتحديث جدول orders لدعم الدفع
```

#### ب) إعداد Edge Function
1. أنشئ مجلد `supabase/functions/create-payment-intent/`
2. انسخ محتوى `supabase_functions/create-payment-intent.ts`
3. أضف المتغيرات البيئية:
```bash
STRIPE_SECRET_KEY=sk_test_xxxxxxxxxxxxx
SUPABASE_URL=your_supabase_url
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
```

#### ج) نشر Edge Function
```bash
supabase functions deploy create-payment-intent
```

### 3. إعداد جدول الدردشة
قم بتشغيل ملف `supabase_tables/support_chat.sql` في Supabase SQL Editor.

## 🧪 اختبار النظام

### بطاقات الاختبار
```
رقم البطاقة: 4242 4242 4242 4242
انتهاء الصلاحية: أي تاريخ مستقبلي (مثل: 12/25)
CVC: أي 3 أرقام (مثل: 123)
```

### سيناريوهات الاختبار
1. **دفع ناجح**: استخدم البطاقة أعلاه
2. **دفع فاشل**: `4000 0000 0000 0002`
3. **يتطلب مصادقة**: `4000 0025 0000 3155`

## 📱 استخدام التطبيق

### 1. إجراء طلب
1. أضف منتجات إلى السلة
2. انتقل إلى صفحة الدفع
3. اختر **"الدفع عبر Stripe"**
4. اتبع التعليمات لإكمال الدفع

### 2. تحميل الفاتورة
1. انتقل إلى **"طلباتي"**
2. اختر طلب مدفوع
3. اضغط **"تحميل الفاتورة"** أو **"مشاركة الفاتورة"**

## 🔧 ملفات النظام

### خدمات جديدة
- `lib/services/payment_service.dart` - خدمة الدفع الإلكتروني
- `lib/services/invoice_service.dart` - خدمة توليد الفواتير

### صفحات محدثة
- `lib/pages/checkout_page.dart` - صفحة الدفع مع Stripe
- `lib/pages/order_details_page.dart` - عرض وتحميل الفواتير
- `lib/pages/support_chat_page.dart` - دردشة مباشرة مع الدعم

### قاعدة البيانات
- `supabase_tables/payment_transactions.sql` - جدول المعاملات
- `supabase_tables/support_chat.sql` - جدول الدردشة

### Edge Functions
- `supabase_functions/create-payment-intent.ts` - إنشاء Payment Intent

## 🚀 الانتقال للإنتاج

### 1. تحديث مفاتيح Stripe
```dart
// في PaymentService
static const String _publishableKey = 'pk_live_xxxxxxxxxxxxx';
```

### 2. تحديث Edge Function
```typescript
const stripeSecretKey = Deno.env.get('STRIPE_SECRET_KEY')! // sk_live_xxxxxxxxxxxxx
```

### 3. إعداد Webhooks
في Stripe Dashboard → Webhooks، أضف:
```
Endpoint: https://your-project.supabase.co/functions/v1/stripe-webhook
Events: payment_intent.succeeded, payment_intent.payment_failed
```

## 🛡️ الأمان

- ✅ **PCI Compliance**: Stripe معتمد PCI DSS Level 1
- ✅ **تشفير البيانات**: جميع البيانات مشفرة أثناء النقل والتخزين
- ✅ **Row Level Security**: حماية بيانات المستخدمين في Supabase
- ✅ **لا تخزين لبيانات البطاقات**: تتم معالجتها عبر Stripe فقط

## 📞 الدعم الفني

للمساعدة في الإعداد أو حل المشاكل:
- 📧 البريد الإلكتروني: support@autoshop.com
- 💬 الدردشة المباشرة: متاحة داخل التطبيق
- 📚 الوثائق: [Stripe Docs](https://stripe.com/docs) | [Supabase Docs](https://supabase.com/docs)

---
**تم التطوير بواسطة GitHub Copilot** 🤖
