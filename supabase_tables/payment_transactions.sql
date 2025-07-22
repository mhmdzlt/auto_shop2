-- Payment Transactions Table for Stripe and other payment gateways
-- Run this SQL in your Supabase SQL Editor

CREATE TABLE IF NOT EXISTS public.payment_transactions (
    id BIGSERIAL PRIMARY KEY,
    order_id TEXT NOT NULL,
    payment_intent_id TEXT UNIQUE,
    amount DECIMAL(10,2) NOT NULL,
    currency TEXT DEFAULT 'USD',
    status TEXT NOT NULL CHECK (status IN ('pending', 'succeeded', 'failed', 'cancelled')),
    payment_method TEXT,
    gateway TEXT DEFAULT 'stripe',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    invoice_url TEXT,
    invoice_generated_at TIMESTAMP WITH TIME ZONE
);

-- Update existing orders table to support payment tracking
ALTER TABLE public.orders 
ADD COLUMN IF NOT EXISTS payment_status TEXT DEFAULT 'pending',
ADD COLUMN IF NOT EXISTS payment_type TEXT DEFAULT 'cod',
ADD COLUMN IF NOT EXISTS transaction_id TEXT,
ADD COLUMN IF NOT EXISTS invoice_generated BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS invoice_generated_at TIMESTAMP WITH TIME ZONE;

-- Enable Row Level Security
ALTER TABLE public.payment_transactions ENABLE ROW LEVEL SECURITY;

-- Policy to allow users to view their own payment transactions
CREATE POLICY "Users can view their own payment transactions" ON public.payment_transactions
    FOR SELECT USING (
        order_id IN (
            SELECT id FROM public.orders WHERE user_id = auth.uid()::text
        )
    );

-- Policy to allow inserting payment transactions
CREATE POLICY "Allow inserting payment transactions" ON public.payment_transactions
    FOR INSERT WITH CHECK (true);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_payment_transactions_order_id ON public.payment_transactions(order_id);
CREATE INDEX IF NOT EXISTS idx_payment_transactions_payment_intent_id ON public.payment_transactions(payment_intent_id);
CREATE INDEX IF NOT EXISTS idx_orders_payment_status ON public.orders(payment_status);
CREATE INDEX IF NOT EXISTS idx_orders_transaction_id ON public.orders(transaction_id);

-- Function to update payment status when transaction changes
CREATE OR REPLACE FUNCTION update_order_payment_status()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.orders 
    SET 
        payment_status = NEW.status,
        transaction_id = NEW.payment_intent_id,
        invoice_generated = NEW.invoice_url IS NOT NULL,
        invoice_generated_at = NEW.invoice_generated_at,
        updated_at = NOW()
    WHERE id = NEW.order_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically update order payment status
DROP TRIGGER IF EXISTS trigger_update_order_payment_status ON public.payment_transactions;
CREATE TRIGGER trigger_update_order_payment_status
    AFTER INSERT OR UPDATE ON public.payment_transactions
    FOR EACH ROW
    EXECUTE FUNCTION update_order_payment_status();
