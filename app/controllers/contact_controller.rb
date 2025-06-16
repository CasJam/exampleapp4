class ContactController < ApplicationController
  allow_unauthenticated_access

  before_action :validate_cloudflare_turnstile, only: [ :contact_form_submission ]
  rescue_from RailsCloudflareTurnstile::Forbidden, with: :handle_turnstile_error

  def index; end

  def contact_form_submission
    ContactMailer.contact_form_email(
      name: params[:name],
      email: params[:email],
      subject: params[:subject],
      message: params[:message],
      page_url: request.referer
    ).deliver_later

    redirect_to contact_path(sent: true)
  end

  private

  def handle_turnstile_error
    redirect_to contact_path, alert: t("contact_form.error.turnstile", default: "Something went wrong. Please try again.")
  end
end
