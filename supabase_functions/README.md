# Supabase Edge Functions 🌐

هذا المجلد يحتوي على Supabase Edge Functions المطلوبة للمشروع.

## الوظائف المتاحة 📋

### 1. create-payment-intent.ts
**الوصف:** إنشاء Payment Intent لـ Stripe مع حفظ بيانات المعاملة

**الاستخدام:**
```typescript
POST /functions/v1/create-payment-intent
Content-Type: application/json

{
  "amount": 5000,        // بالسنت (50.00 دولار)
  "currency": "usd",     // اختياري (افتراضي: usd)
  "order_id": "order_123"
}
```

**الاستجابة:**
```json
{
  "success": true,
  "id": "pi_1234567890",
  "client_secret": "pi_1234567890_secret_xyz",
  "customer": "cus_1234567890",
  "ephemeral_key": "ek_1234567890",
  "publishable_key": "pk_test_..."
}
```

## متطلبات البيئة 🔧

يجب تعيين المتغيرات التالية في Supabase:

```bash
# Stripe Keys
STRIPE_SECRET_KEY=sk_test_...
STRIPE_PUBLISHABLE_KEY=pk_test_...

# Supabase Keys  
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiI...
```

## النشر 🚀

### 1. تثبيت Supabase CLI
```bash
npm install -g supabase
```

### 2. تسجيل الدخول
```bash
supabase login
```

### 3. ربط المشروع
```bash
supabase link --project-ref your-project-ref
```

### 4. نشر الوظائف
```bash
supabase functions deploy create-payment-intent
```

## الاختبار المحلي 🧪

### تشغيل محلي
```bash
supabase start
supabase functions serve
```

### اختبار الوظيفة
```bash
curl -X POST 'http://localhost:54321/functions/v1/create-payment-intent' \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer YOUR_ANON_KEY' \
  -d '{
    "amount": 5000,
    "currency": "usd", 
    "order_id": "test_order_123"
  }'
```

## الأمان 🔒

- ✅ جميع المتغيرات السرية محفوظة في البيئة
- ✅ CORS محدد بشكل صحيح
- ✅ التحقق من صحة المدخلات
- ✅ معالجة أخطاء شاملة
- ✅ تسجيل الأخطاء للمراقبة

## استكشاف الأخطاء 🔍

### خطأ في Stripe API
```
Error: Stripe API error: Unauthorized
```
**الحل:** تحقق من STRIPE_SECRET_KEY

### خطأ في قاعدة البيانات
```
Error: relation "payment_transactions" does not exist
```
**الحل:** تشغيل ملف SQL من مجلد supabase_tables

### خطأ CORS
```
Error: CORS policy
```
**الحل:** تحقق من إعدادات CORS في headers

## المراقبة 📊

يمكن مراقبة الوظائف من:
1. Supabase Dashboard → Edge Functions
2. Logs → Real-time logs
3. Metrics → Performance data

## التحديثات المستقبلية 🔮

- [ ] دعم PayPal
- [ ] دعم Apple Pay
- [ ] Webhooks للتأكيدات
- [ ] Cache للعملاء المتكررين

---
**آخر تحديث:** يوليو 2025
