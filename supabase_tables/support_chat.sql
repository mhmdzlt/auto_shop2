-- Support Chat Table for real-time customer support
-- Run this SQL in your Supabase SQL Editor

CREATE TABLE IF NOT EXISTS public.support_chat (
    id BIGSERIAL PRIMARY KEY,
    user_id TEXT NOT NULL,
    from_type TEXT NOT NULL CHECK (from_type IN ('user', 'support')),
    text TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.support_chat ENABLE ROW LEVEL SECURITY;

-- Policy to allow users to see their own messages and all support messages
CREATE POLICY "Users can view their own messages and support responses" ON public.support_chat
    FOR SELECT USING (
        user_id = auth.uid()::text OR from_type = 'support'
    );

-- Policy to allow users to insert their own messages
CREATE POLICY "Users can insert their own messages" ON public.support_chat
    FOR INSERT WITH CHECK (
        user_id = auth.uid()::text AND from_type = 'user'
    );

-- Policy to allow support team to insert support messages
CREATE POLICY "Support can insert support messages" ON public.support_chat
    FOR INSERT WITH CHECK (
        from_type = 'support'
    );

-- Enable real-time subscriptions
ALTER PUBLICATION supabase_realtime ADD TABLE public.support_chat;

-- Create index for better performance
CREATE INDEX IF NOT EXISTS idx_support_chat_user_id ON public.support_chat(user_id);
CREATE INDEX IF NOT EXISTS idx_support_chat_created_at ON public.support_chat(created_at);
