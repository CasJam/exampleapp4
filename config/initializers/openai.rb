# OpenAI.configure do |config|
#   config.access_token = Rails.application.credentials.dig(:openai, :access_token)
#   config.organization_id = Rails.application.credentials.dig(:openai, :organization_id)
#   config.log_errors = Rails.application.credentials.dig(:openai, :log_errors) # Highly recommended in development, so you can see what errors OpenAI is returning. Not recommended in production because it could leak private data to your logs.
# end
