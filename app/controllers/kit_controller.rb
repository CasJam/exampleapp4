class KitController < ApplicationController

  # If using Rails 8 authentication, and you want to allow non-logged-in users to subscribe to your Kit form, keep this line.
  allow_unauthenticated_access

  before_action :validate_cloudflare_turnstile, only: [ :create ]
  rescue_from RailsCloudflareTurnstile::Forbidden, with: :handle_turnstile_error

  def create
    email = params[:email]
    form_type = params[:form_type]

    if email.blank?
      redirect_back(fallback_location: root_path, alert: t("kit.error.email_required", default: "Email address is required."))
    end

    unless valid_email?(email)
      redirect_back(fallback_location: root_path, alert: t("kit.error.invalid_email", default: "Please enter a valid email address."))
    end

    tag_ids = []
    custom_fields = {}

    # Example tags
    # tag_ids << 1234567 # ID of a tag in your Kit account
    # tag_ids << 2345678 # ID of another tag in your Kit account

    # Example custom fields
    # custom_fields['interests'] = { value: 'cursor', append: true }
    # custom_fields['favorite_team'] = { value: 'Knicks', append: false }

    # Subscribe via Kit API
    kit_service = KitService.new
    result = kit_service.subscribe(email, tag_ids: tag_ids, custom_fields: custom_fields)

    if result[:success]
      redirect_to subscribed_path(for: form_type), notice: t("kit.success.subscribed", default: "Successfully subscribed!")
    else
      redirect_back(fallback_location: root_path, alert: t("kit.error.subscription_failed", default: "There was an error processing your subscription. Please try again."))
    end
  end

  def subscribe
  end

  def subscribed
    @form_type = params[:for]
  end

  private

  def valid_email?(email)
    email.match?(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)
  end

  def handle_turnstile_error
    redirect_to subscribe_path, alert: t("kit.error.turnstile", default: "Something went wrong. Please try again.")
  end
end
