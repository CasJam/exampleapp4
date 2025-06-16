class OpenaiPromptController < ApplicationController
  def index
    @openai_service = OpenaiService.new
  end

  def create
    @openai_service = OpenaiService.new

    prompt = params[:prompt]
    options = {
      system_instructions: params[:system_instructions],
      model: params[:model],
      max_tokens: params[:max_tokens].to_i.positive? ? params[:max_tokens].to_i : nil,
      temperature: params[:temperature].present? ? params[:temperature].to_f : nil,
      top_p: params[:top_p].present? ? params[:top_p].to_f : nil,
      frequency_penalty: params[:frequency_penalty].present? ? params[:frequency_penalty].to_f : nil,
      presence_penalty: params[:presence_penalty].present? ? params[:presence_penalty].to_f : nil
    }.compact

    @response = @openai_service.generate_response(prompt, options)
    @prompt = prompt
    @options = options

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to openai_prompt_index_path }
    end
  rescue => e
    @error = e.message
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.update("response", partial: "error") }
      format.html { redirect_to openai_prompt_index_path, alert: t("openai.error.default_message", default: "An unexpected error occurred. Please try again.") }
    end
  end
end
