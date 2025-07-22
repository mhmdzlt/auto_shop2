// Supabase Edge Function for creating Stripe Payment Intent
// Save this as supabase/functions/create-payment-intent/index.ts

// @deno-types="https://deno.land/std@0.224.0/http/server.d.ts"
// @ts-ignore: Deno std library import
import { serve } from "https://deno.land/std@0.224.0/http/server.ts"
// @deno-types="https://esm.sh/@supabase/supabase-js@2/dist/module/index.d.ts"
// @ts-ignore: supabase client import
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// Declare Deno globals for environment access
declare const Deno: any;

// CORS headers for cross-origin requests
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

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
    // Parse and validate request body
    const body = await req.json()
    const { amount, currency = 'usd', order_id } = body

    // Input validation
    if (!amount || amount <= 0) {
      return new Response(
        JSON.stringify({ error: 'Invalid amount' }),
        { 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 400 
        }
      )
    }

    if (!order_id) {
      return new Response(
        JSON.stringify({ error: 'Order ID is required' }),
        { 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 400 
        }
      )
    }

    // Initialize Stripe with environment variables
    const stripeSecretKey = Deno.env.get('STRIPE_SECRET_KEY')
    if (!stripeSecretKey) {
      throw new Error('Stripe secret key not configured')
    }
    // Stripe API helper functions
    const stripe = {
      createPaymentIntent: async (params: {
        amount: number;
        currency: string;
        metadata: { order_id: string };
      }) => {
        const response = await fetch('https://api.stripe.com/v1/payment_intents', {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${stripeSecretKey}`,
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: new URLSearchParams({
            amount: params.amount.toString(),
            currency: params.currency,
            'metadata[order_id]': params.metadata.order_id,
            'automatic_payment_methods[enabled]': 'true',
          }),
        })
        
        if (!response.ok) {
          throw new Error(`Stripe API error: ${response.statusText}`)
        }
        
        return await response.json()
      },

      createCustomer: async () => {
        const response = await fetch('https://api.stripe.com/v1/customers', {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${stripeSecretKey}`,
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        })
        
        if (!response.ok) {
          throw new Error(`Stripe Customer API error: ${response.statusText}`)
        }
        
        return await response.json()
      },

      createEphemeralKey: async (customerId: string) => {
        const response = await fetch('https://api.stripe.com/v1/ephemeral_keys', {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${stripeSecretKey}`,
            'Content-Type': 'application/x-www-form-urlencoded',
            'Stripe-Version': '2023-10-16', // Updated to latest API version
          },
          body: new URLSearchParams({
            customer: customerId,
          }),
        })
        
        if (!response.ok) {
          throw new Error(`Stripe Ephemeral Key API error: ${response.statusText}`)
        }
        
        return await response.json()
      }
    }

    // Create Stripe resources
    const customer = await stripe.createCustomer()
    
    if (!customer.id) {
      throw new Error('Failed to create Stripe customer')
    }

    const paymentIntent = await stripe.createPaymentIntent({
      amount,
      currency,
      metadata: {
        order_id,
      },
    })

    if (!paymentIntent.id || !paymentIntent.client_secret) {
      throw new Error('Failed to create payment intent')
    }

    const ephemeralKey = await stripe.createEphemeralKey(customer.id)

    if (!ephemeralKey.secret) {
      throw new Error('Failed to create ephemeral key')
    }

    // Initialize Supabase client with validation
    const supabaseUrl = Deno.env.get('SUPABASE_URL')
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
    
    if (!supabaseUrl || !supabaseServiceKey) {
      throw new Error('Supabase configuration missing')
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // Save payment transaction record with error handling
    const { data, error } = await supabase.from('payment_transactions').insert({
      order_id,
      payment_intent_id: paymentIntent.id,
      amount: amount / 100, // Convert from cents
      currency: currency.toUpperCase(),
      status: 'pending',
      gateway: 'stripe',
      created_at: new Date().toISOString(),
    })

    if (error) {
      console.error('Database error:', error)
      // Don't fail the payment, just log the error
    }

    // Return successful response
    return new Response(
      JSON.stringify({
        success: true,
        id: paymentIntent.id,
        client_secret: paymentIntent.client_secret,
        customer: customer.id,
        ephemeral_key: ephemeralKey.secret,
        publishable_key: Deno.env.get('STRIPE_PUBLISHABLE_KEY'),
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )
  } catch (error) {
    console.error('Payment Intent Error:', error)
    
    // Return appropriate error response
    const errorMessage = error instanceof Error ? error.message : 'Unknown error occurred'
    const statusCode = errorMessage.includes('Invalid') ? 400 : 500
    
    return new Response(
      JSON.stringify({ 
        success: false,
        error: errorMessage,
        timestamp: new Date().toISOString(),
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: statusCode,
      }
    )
  }
})
