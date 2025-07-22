-- جدول كوبونات الخصم
CREATE TABLE promo_codes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  code VARCHAR(50) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  
  -- نوع الخصم
  discount_type VARCHAR(20) NOT NULL CHECK (discount_type IN ('percentage', 'fixed_amount')),
  discount_value DECIMAL(10,2) NOT NULL,
  
  -- شروط الاستخدام
  min_order_amount DECIMAL(10,2) DEFAULT 0,
  max_discount_amount DECIMAL(10,2), -- الحد الأقصى للخصم (للنسبة المئوية)
  usage_limit INTEGER, -- عدد مرات الاستخدام المسموح
  usage_count INTEGER DEFAULT 0, -- عدد مرات الاستخدام الحالي
  user_usage_limit INTEGER DEFAULT 1, -- عدد مرات الاستخدام لكل مستخدم
  
  -- التواريخ
  valid_from TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  valid_until TIMESTAMP WITH TIME ZONE,
  
  -- حالة الكوبون
  is_active BOOLEAN DEFAULT true,
  
  -- معلومات إضافية
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- جدول استخدام الكوبونات لكل مستخدم
CREATE TABLE promo_code_usage (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  promo_code_id UUID REFERENCES promo_codes(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  order_id VARCHAR(255),
  used_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  discount_applied DECIMAL(10,2) NOT NULL,
  
  UNIQUE(promo_code_id, user_id, order_id)
);

-- فهارس لتحسين الأداء
CREATE INDEX idx_promo_codes_code ON promo_codes(code);
CREATE INDEX idx_promo_codes_active ON promo_codes(is_active) WHERE is_active = true;
CREATE INDEX idx_promo_codes_valid_period ON promo_codes(valid_from, valid_until);
CREATE INDEX idx_promo_code_usage_user ON promo_code_usage(user_id);
CREATE INDEX idx_promo_code_usage_promo ON promo_code_usage(promo_code_id);

-- دالة لتحديث عداد الاستخدام
CREATE OR REPLACE FUNCTION update_promo_code_usage_count()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE promo_codes 
  SET usage_count = usage_count + 1,
      updated_at = NOW()
  WHERE id = NEW.promo_code_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ترايجر لتحديث العداد عند الاستخدام
CREATE TRIGGER trigger_update_usage_count
  AFTER INSERT ON promo_code_usage
  FOR EACH ROW
  EXECUTE FUNCTION update_promo_code_usage_count();

-- دالة للتحقق من صلاحية الكوبون
CREATE OR REPLACE FUNCTION validate_promo_code(
  p_code TEXT,
  p_user_id UUID,
  p_order_amount DECIMAL(10,2)
)
RETURNS JSON AS $$
DECLARE
  v_promo promo_codes%ROWTYPE;
  v_user_usage_count INTEGER;
  v_result JSON;
BEGIN
  -- البحث عن الكوبون
  SELECT * INTO v_promo 
  FROM promo_codes 
  WHERE code = p_code AND is_active = true;
  
  -- التحقق من وجود الكوبون
  IF NOT FOUND THEN
    RETURN json_build_object(
      'valid', false,
      'error', 'كود الخصم غير موجود أو غير صالح'
    );
  END IF;
  
  -- التحقق من صلاحية التاريخ
  IF v_promo.valid_from > NOW() THEN
    RETURN json_build_object(
      'valid', false,
      'error', 'كود الخصم لم يبدأ بعد'
    );
  END IF;
  
  IF v_promo.valid_until IS NOT NULL AND v_promo.valid_until < NOW() THEN
    RETURN json_build_object(
      'valid', false,
      'error', 'انتهت صلاحية كود الخصم'
    );
  END IF;
  
  -- التحقق من الحد الأدنى للطلب
  IF p_order_amount < v_promo.min_order_amount THEN
    RETURN json_build_object(
      'valid', false,
      'error', format('الحد الأدنى للطلب %s', v_promo.min_order_amount)
    );
  END IF;
  
  -- التحقق من عدد مرات الاستخدام الإجمالي
  IF v_promo.usage_limit IS NOT NULL AND v_promo.usage_count >= v_promo.usage_limit THEN
    RETURN json_build_object(
      'valid', false,
      'error', 'تم استنفاد عدد مرات استخدام هذا الكود'
    );
  END IF;
  
  -- التحقق من عدد مرات استخدام المستخدم
  SELECT COUNT(*) INTO v_user_usage_count
  FROM promo_code_usage
  WHERE promo_code_id = v_promo.id AND user_id = p_user_id;
  
  IF v_user_usage_count >= v_promo.user_usage_limit THEN
    RETURN json_build_object(
      'valid', false,
      'error', 'لقد استخدمت هذا الكود من قبل'
    );
  END IF;
  
  -- الكوبون صالح، إرجاع التفاصيل
  RETURN json_build_object(
    'valid', true,
    'promo_code', row_to_json(v_promo),
    'user_usage_count', v_user_usage_count
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- دالة حساب قيمة الخصم
CREATE OR REPLACE FUNCTION calculate_discount(
  p_promo_id UUID,
  p_order_amount DECIMAL(10,2)
)
RETURNS DECIMAL(10,2) AS $$
DECLARE
  v_promo promo_codes%ROWTYPE;
  v_discount DECIMAL(10,2);
BEGIN
  SELECT * INTO v_promo FROM promo_codes WHERE id = p_promo_id;
  
  IF v_promo.discount_type = 'percentage' THEN
    v_discount := p_order_amount * (v_promo.discount_value / 100);
    
    -- تطبيق الحد الأقصى للخصم إن وُجد
    IF v_promo.max_discount_amount IS NOT NULL THEN
      v_discount := LEAST(v_discount, v_promo.max_discount_amount);
    END IF;
  ELSE
    -- خصم ثابت
    v_discount := LEAST(v_promo.discount_value, p_order_amount);
  END IF;
  
  RETURN v_discount;
END;
$$ LANGUAGE plpgsql;

-- إدراج بعض الكوبونات التجريبية
INSERT INTO promo_codes (code, name, description, discount_type, discount_value, min_order_amount, max_discount_amount, usage_limit, valid_until) VALUES
('WELCOME10', 'خصم الترحيب', 'خصم 10% للعملاء الجدد', 'percentage', 10.00, 50.00, 20.00, 100, NOW() + INTERVAL '30 days'),
('SAVE20', 'وفر 20', 'خصم 20 دولار على الطلبات فوق 100 دولار', 'fixed_amount', 20.00, 100.00, NULL, 50, NOW() + INTERVAL '15 days'),
('FLASH25', 'عرض خاطف', 'خصم 25% لفترة محدودة', 'percentage', 25.00, 30.00, 50.00, 20, NOW() + INTERVAL '7 days'),
('FREESHIP', 'شحن مجاني', 'خصم 5 دولار لتغطية الشحن', 'fixed_amount', 5.00, 25.00, NULL, NULL, NOW() + INTERVAL '60 days');

-- Row Level Security
ALTER TABLE promo_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE promo_code_usage ENABLE ROW LEVEL SECURITY;

-- سماح للجميع بقراءة الكوبونات النشطة
CREATE POLICY "Allow public read active promo codes" ON promo_codes
  FOR SELECT USING (is_active = true);

-- سماح للمستخدمين المسجلين بإدراج استخدام الكوبونات
CREATE POLICY "Allow authenticated users to insert usage" ON promo_code_usage
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

-- سماح للمستخدمين بقراءة استخدامهم الخاص
CREATE POLICY "Allow users to read own usage" ON promo_code_usage
  FOR SELECT TO authenticated USING (auth.uid() = user_id);
