class AnthropicService
  DEFAULT_MODEL = "claude-3-haiku-20240307"
  DEFAULT_MAX_TOKENS = 1000
  DEFAULT_TEMPERATURE = 0.7

  def initialize
    @client = Anthropic::Client.new
  end

  def generate_response(prompt, options = {})
    # Validate required prompt
    raise ArgumentError, "Prompt is required" if prompt.blank?

    # Extract options with defaults - Anthropic uses different parameter names
    system_message = options[:system_instructions] || "You are a helpful assistant."
    model = options[:model] || DEFAULT_MODEL
    max_tokens = options[:max_tokens] || DEFAULT_MAX_TOKENS
    temperature = options[:temperature] || DEFAULT_TEMPERATURE
    top_p = options[:top_p] || nil
    top_k = options[:top_k] || nil

    # Build messages array (Anthropic doesn't use system role in messages)
    messages = [
      { role: "user", content: prompt }
    ]

    # Build parameters hash
    parameters = {
      model: model,
      system: system_message,
      messages: messages,
      max_tokens: max_tokens,
      temperature: temperature
    }

    # Add optional parameters if provided
    parameters[:top_p] = top_p if top_p.present?
    parameters[:top_k] = top_k if top_k.present?

    begin
      response = @client.messages(parameters: parameters)

      {
        success: true,
        content: response.dig("content", 0, "text"),
        usage: response["usage"],
        model: response["model"],
        finish_reason: response["stop_reason"]
      }
    rescue => e
      Rails.logger.error "Anthropic API Error: #{e.message}"
      {
        success: false,
        error: e.message
      }
    end
  end

  def available_models
    [
      "claude-3-5-sonnet-20241022",
      "claude-3-5-sonnet-20240620",
      "claude-3-5-haiku-20241022",
      "claude-3-opus-20240229",
      "claude-3-sonnet-20240229",
      "claude-3-haiku-20240307"
    ]
  end

  private

  attr_reader :client
end
