class AnthropicPromptController < ApplicationController
  def index
    @anthropic_service = AnthropicService.new
  end

  def create
    @anthropic_service = AnthropicService.new

    prompt = params[:prompt]
    options = {
      system_instructions: params[:system_instructions],
      model: params[:model],
      max_tokens: params[:max_tokens].to_i.positive? ? params[:max_tokens].to_i : nil,
      temperature: params[:temperature].present? ? params[:temperature].to_f : nil,
      top_p: params[:top_p].present? ? params[:top_p].to_f : nil,
      top_k: params[:top_k].present? ? params[:top_k].to_i : nil
    }.compact

    @response = @anthropic_service.generate_response(prompt, options)
    @prompt = prompt
    @options = options

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to anthropic_prompt_index_path }
    end
  rescue => e
    @error = e.message
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.update("response", partial: "error") }
      format.html { redirect_to anthropic_prompt_index_path, alert: t("anthropic.error.default_message", default: "An unexpected error occurred. Please try again.") }
    end
  end
end
