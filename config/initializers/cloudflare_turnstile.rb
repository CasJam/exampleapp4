# RailsCloudflareTurnstile.configure do |c|
#   c.site_key = Rails.application.credentials.dig(:cloudflare, :turnstile_site_key)
#   c.secret_key = Rails.application.credentials.dig(:cloudflare, :turnstile_secret_key)
#   c.fail_open = true
# end


# Add the following to your Rails application's credentials file:
# cloudflare:
#   turnstile_site_key: your_production_site_key
#   turnstile_secret_key: your_production_secret_key

#   The following test scenarios use keys found here:
#   https://developers.cloudflare.com/turnstile/troubleshooting/testing/

#   Test keys: Widget is visible, always passes
#   turnstile_site_key: 1x00000000000000000000AA
#   turnstile_secret_key: 1x0000000000000000000000000000000AA

#   # Test keys: Widget is invisible, always passes
#   turnstile_site_key: 1x00000000000000000000BB
#   turnstile_secret_key: 1x0000000000000000000000000000000AA

#   # Test keys: Widget is visible, always fails
#   turnstile_site_key: 2x00000000000000000000AB
#   turnstile_secret_key: 2x0000000000000000000000000000000AA

#   # Test keys: Widget is invisible, always fails
#   turnstile_site_key: 2x00000000000000000000BB
#   turnstile_secret_key: 2x0000000000000000000000000000000AA

#   # Test keys: Widget forces a challenge
#   turnstile_site_key: 3x00000000000000000000FF
#   turnstile_secret_key: 1x0000000000000000000000000000000AA
