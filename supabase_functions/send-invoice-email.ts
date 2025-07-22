import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const SENDGRID_API_KEY = Deno.env.get('SENDGRID_API_KEY')
const FROM_EMAIL = 'noreply@autoshop.com'

serve(async (req) => {
  try {
    const { to_email, customer_name, order_id, pdf_content } = await req.json()

    if (!SENDGRID_API_KEY) {
      return new Response(
        JSON.stringify({ success: false, error: 'SendGrid API key not configured' }),
        { headers: { "Content-Type": "application/json" }, status: 500 }
      )
    }

    const emailData = {
      personalizations: [
        {
          to: [
            {
              email: to_email,
              name: customer_name || 'Valued Customer',
            }
          ],
          subject: `Invoice for Order #${order_id} - Auto Shop`,
        }
      ],
      from: {
        email: FROM_EMAIL,
        name: 'Auto Shop',
      },
      content: [
        {
          type: 'text/html',
          value: buildEmailTemplate(order_id, customer_name),
        }
      ],
      attachments: [
        {
          content: pdf_content,
          filename: `invoice_${order_id}.pdf`,
          type: 'application/pdf',
          disposition: 'attachment',
        }
      ],
    }

    const response = await fetch('https://api.sendgrid.com/v3/mail/send', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${SENDGRID_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(emailData),
    })

    if (response.status === 202) {
      return new Response(
        JSON.stringify({ success: true, message: 'Email sent successfully' }),
        { headers: { "Content-Type": "application/json" } }
      )
    } else {
      const errorText = await response.text()
      console.error('SendGrid error:', errorText)
      return new Response(
        JSON.stringify({ success: false, error: 'Failed to send email' }),
        { headers: { "Content-Type": "application/json" }, status: 500 }
      )
    }
  } catch (error) {
    console.error('Error sending email:', error)
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { headers: { "Content-Type": "application/json" }, status: 500 }
    )
  }
})

function buildEmailTemplate(orderId: string, customerName?: string): string {
  return `
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Invoice - Auto Shop</title>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .header { background-color: #F93838; color: white; padding: 20px; text-align: center; }
        .content { padding: 20px; }
        .footer { background-color: #f4f4f4; padding: 15px; text-align: center; font-size: 12px; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Auto Shop</h1>
        <p>Your trusted car parts store</p>
    </div>
    <div class="content">
        <h2>Dear ${customerName || 'Valued Customer'},</h2>
        <p>Thank you for your recent purchase with Auto Shop!</p>
        <p>Please find attached your invoice for order <strong>#${orderId}</strong>.</p>
        <p>We appreciate your business and look forward to serving you again.</p>
        <p>If you have any questions about your order, please don't hesitate to contact us.</p>
        <br>
        <p>Best regards,<br>The Auto Shop Team</p>
    </div>
    <div class="footer">
        <p>&copy; 2025 Auto Shop. All rights reserved.</p>
        <p>This is an automated email. Please do not reply to this message.</p>
    </div>
</body>
</html>
  `
}
