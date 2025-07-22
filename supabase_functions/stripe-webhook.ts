// Supabase Edge Function for handling Stripe Webhooks
// Save this as supabase/functions/stripe-webhook/index.ts

// @deno-types="https://deno.land/std@0.224.0/http/server.d.ts"
// @ts-ignore: Deno std library import
import { serve } from "https://deno.land/std@0.224.0/http/server.ts"
// @deno-types="https://esm.sh/@supabase/supabase-js@2/dist/module/index.d.ts"
// @ts-ignore: supabase client import
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, stripe-signature',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

// Declare Deno globals for environment access
declare const Deno: any;
serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  // Only allow POST requests
  if (req.method !== 'POST') {
    return new Response(
      JSON.stringify({ error: 'Method not allowed' }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 405 
      }
    )
  }

  try {
    const signature = req.headers.get('stripe-signature')
    const webhookSecret = Deno.env.get('STRIPE_WEBHOOK_SECRET')
    
    if (!signature || !webhookSecret) {
      throw new Error('Missing webhook signature or secret')
    }

    const body = await req.text()
    
    // Verify webhook signature (simplified - in production use proper crypto verification)
    // const event = stripe.webhooks.constructEvent(body, signature, webhookSecret)
    
    // For now, parse the JSON directly (add proper verification in production)
    const event = JSON.parse(body)
    
    console.log('Received webhook:', event.type)

    // Initialize Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
    
    if (!supabaseUrl || !supabaseServiceKey) {
      throw new Error('Supabase configuration missing')
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // Handle different event types
    switch (event.type) {
      case 'payment_intent.succeeded':
        await handlePaymentSucceeded(supabase, event.data.object)
        break
        
      case 'payment_intent.payment_failed':
        await handlePaymentFailed(supabase, event.data.object)
        break
        
      case 'payment_intent.canceled':
        await handlePaymentCanceled(supabase, event.data.object)
        break
        
      default:
        console.log(`Unhandled event type: ${event.type}`)
    }

    return new Response(
      JSON.stringify({ received: true }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )
  } catch (error) {
    console.error('Webhook Error:', error)
    
    return new Response(
      JSON.stringify({ 
        error: error instanceof Error ? error.message : 'Webhook processing failed',
        timestamp: new Date().toISOString(),
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400,
      }
    )
  }
})

// Helper function to handle successful payments
async function handlePaymentSucceeded(supabase: any, paymentIntent: any) {
  try {
    // First update payment status
    const { error, data } = await supabase
      .from('payment_transactions')
      .update({ 
        status: 'completed',
        updated_at: new Date().toISOString(),
        stripe_data: paymentIntent,
        payment_confirmed_at: new Date().toISOString(),
      })
      .eq('payment_intent_id', paymentIntent.id)
      .select()
      .single()

    if (error) {
      console.error('Error updating payment status:', error)
      throw error
    }

    // Next, fetch the order associated with this payment
    if (data && data.order_id) {
      // Update order status to paid
      const { error: orderError } = await supabase
        .from('orders')
        .update({ 
          status: 'paid',
          payment_status: 'completed',
          updated_at: new Date().toISOString(),
        })
        .eq('id', data.order_id)

      if (orderError) {
        console.error('Error updating order status:', orderError)
      } else {
        console.log(`Order status updated for order: ${data.order_id}`)
      }
    }

    console.log(`Payment succeeded for intent: ${paymentIntent.id}`)
  } catch (error) {
    console.error('Error in handlePaymentSucceeded:', error)
    throw error
  }
}

// Helper function to handle failed payments
async function handlePaymentFailed(supabase: any, paymentIntent: any) {
  const { error } = await supabase
    .from('payment_transactions')
    .update({ 
      status: 'failed',
      updated_at: new Date().toISOString(),
      failure_reason: paymentIntent.last_payment_error?.message || 'Payment failed',
      stripe_data: paymentIntent,
    })
    .eq('payment_intent_id', paymentIntent.id)

  if (error) {
    console.error('Error updating payment status:', error)
    throw error
  }

  console.log(`Payment failed for intent: ${paymentIntent.id}`)
}

// Helper function to handle canceled payments
async function handlePaymentCanceled(supabase: any, paymentIntent: any) {
  const { error } = await supabase
    .from('payment_transactions')
    .update({ 
      status: 'canceled',
      updated_at: new Date().toISOString(),
      stripe_data: paymentIntent,
    })
    .eq('payment_intent_id', paymentIntent.id)

  if (error) {
    console.error('Error updating payment status:', error)
    throw error
  }

  console.log(`Payment canceled for intent: ${paymentIntent.id}`)
}
