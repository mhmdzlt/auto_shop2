// Supabase Edge Function for handling Stripe Webhooks
// Save this as supabase/functions/stripe-webhook/index.ts

// @deno-types="https://deno.land/std@0.224.0/http/server.d.ts"
// @ts-ignore: Deno std library import
import { serve } from "https://deno.land/std@0.224.0/http/server.ts"
// @deno-types="https://esm.sh/@supabase/supabase-js@2/dist/module/index.d.ts"
// @ts-ignore: supabase client import
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// CORS headers for cross-origin requests
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
    // Get the stripe signature from headers
    const signature = req.headers.get('stripe-signature')
    const webhookSecret = Deno.env.get('STRIPE_WEBHOOK_SECRET')

    if (!signature || !webhookSecret) {
      throw new Error('Missing webhook signature or secret')
    }

    const body = await req.text()
    // Parse the webhook body
    const event = JSON.parse(body)

    // Initialize Supabase client with validation
    const supabaseUrl = Deno.env.get('SUPABASE_URL')
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
    
    if (!supabaseUrl || !supabaseServiceKey) {
      throw new Error('Supabase configuration missing')
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    console.log(`Processing Stripe event: ${event.type}`)

    // Handle different types of events
    if (event.type === 'checkout.session.completed') {
      // Handle checkout session completed
      const session = event.data.object
      const orderId = session.metadata.order_id
      const transactionId = session.payment_intent

      if (!orderId) {
        throw new Error('Order ID missing in metadata')
      }

      console.log(`Updating order ${orderId} with transaction ${transactionId}`)

      // Update the order status in Supabase
      const { error: orderError } = await supabase.from('orders')
        .update({
          payment_status: 'success',
          transaction_id: transactionId,
          updated_at: new Date().toISOString()
        })
        .eq('id', orderId)

      if (orderError) {
        throw new Error(`Failed to update order: ${orderError.message}`)
      }

      // Also update payment_transactions if it exists
      const { error: transactionError } = await supabase.from('payment_transactions')
        .update({
          status: 'completed',
          updated_at: new Date().toISOString()
        })
        .eq('payment_intent_id', transactionId)
        .eq('order_id', orderId)

      if (transactionError) {
        console.error(`Warning: Failed to update transaction: ${transactionError.message}`)
        // Don't throw error here, as the order was successfully updated
      }

      return new Response(
        JSON.stringify({ success: true, message: 'تم التحديث بنجاح' }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 200,
        }
      )
    } else if (event.type === 'payment_intent.succeeded') {
      // Handle payment intent succeeded
      const paymentIntent = event.data.object
      const orderId = paymentIntent.metadata.order_id

      if (!orderId) {
        throw new Error('Order ID missing in metadata')
      }

      // Update the order status in Supabase
      const { error } = await supabase.from('orders')
        .update({
          payment_status: 'success',
          transaction_id: paymentIntent.id,
          updated_at: new Date().toISOString()
        })
        .eq('id', orderId)

      if (error) {
        throw new Error(`Failed to update order: ${error.message}`)
      }

      return new Response(
        JSON.stringify({ success: true, message: 'تم التحديث بنجاح' }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 200,
        }
      )
    }

    // For other event types
    return new Response(
      JSON.stringify({ success: true, message: 'تم استلام الحدث بنجاح' }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )

  } catch (error) {
    console.error('Webhook Error:', error)
    
    // Return appropriate error response
    const errorMessage = error instanceof Error ? error.message : 'Unknown error occurred'
    
    return new Response(
      JSON.stringify({ 
        success: false,
        error: errorMessage,
        timestamp: new Date().toISOString(),
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400,
      }
    )
  }
})
