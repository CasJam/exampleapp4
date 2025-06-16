class OpenaiService
  DEFAULT_MODEL = "gpt-4o-mini"
  DEFAULT_MAX_TOKENS = 1000
  DEFAULT_TEMPERATURE = 0.7

  def initialize
    @client = OpenAI::Client.new
  end

  def generate_response(prompt, options = {})
    # Validate required prompt
    raise ArgumentError, "Prompt is required" if prompt.blank?

    # Extract options with defaults
    system_message = options[:system_instructions] || "You are a helpful assistant."
    model = options[:model] || DEFAULT_MODEL
    max_tokens = options[:max_tokens] || DEFAULT_MAX_TOKENS
    temperature = options[:temperature] || DEFAULT_TEMPERATURE
    top_p = options[:top_p] || 1.0
    frequency_penalty = options[:frequency_penalty] || 0.0
    presence_penalty = options[:presence_penalty] || 0.0

    # Build messages array
    messages = [
      { role: "system", content: system_message },
      { role: "user", content: prompt }
    ]

    begin
      response = @client.chat(
        parameters: {
          model: model,
          messages: messages,
          max_tokens: max_tokens,
          temperature: temperature,
          top_p: top_p,
          frequency_penalty: frequency_penalty,
          presence_penalty: presence_penalty
        }
      )

      {
        success: true,
        content: response.dig("choices", 0, "message", "content"),
        usage: response["usage"],
        model: response["model"],
        finish_reason: response.dig("choices", 0, "finish_reason")
      }
    rescue => e
      Rails.logger.error "OpenAI API Error: #{e.message}"
      {
        success: false,
        error: e.message
      }
    end
  end

  def available_models
    [
      "gpt-4o",
      "gpt-4o-mini",
      "gpt-4-turbo",
      "gpt-4",
      "gpt-3.5-turbo"
    ]
  end

  private

  attr_reader :client
end
