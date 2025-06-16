require "net/http"
require "uri"
require "json"

class KitService
  BASE_URL = "https://api.kit.com/v4"

  def initialize
    @api_key = Rails.application.credentials.dig(:kit, :api_key)
    raise "Kit API key not found in credentials" unless @api_key
  end

  def subscribe(email, options = {})
    # tag_ids is an array of tag IDs to subscribe the subscriber to
    tag_ids = options[:tag_ids] || []

    # custom_fields is a hash of custom fields to add to the subscriber
    # each key is the field's 'key' (in Kit, the 'key' is the field's 'label' turned into a slug), and the value is a hash with :value and :append keys
    # :value is the value to set for the field
    # :append is a boolean indicating whether to append the value to the existing value
    #   if :append is true, the value will be appended to the existing value (if it doesn't already exist)
    #   if :append is false, the value will overwrite the existing value
    #   if :append is not provided, the value will overwrite the existing value
    custom_fields = options[:custom_fields] || {}

    begin
      # First, try to get existing subscriber
      subscriber = get_subscriber(email)

      if subscriber
        update_subscriber(subscriber, tag_ids, custom_fields, email)
      else
        create_subscriber(email, tag_ids, custom_fields)
      end

      { success: true, message: "Subscriber processed successfully" }
    rescue => e
      Rails.logger.error "Kit API Error: #{e.message}"
      { success: false, message: e.message }
    end
  end

  private

  def get_subscriber(email)
    uri = URI("#{BASE_URL}/subscribers")
    uri.query = URI.encode_www_form(email_address: email)

    response = make_request(uri, :get)

    if response.code == "200"
      data = JSON.parse(response.body)
      data["subscribers"]&.first
    elsif response.code == "404"
      nil
    else
      raise "Failed to get subscriber: #{response.body}"
    end
  end

  def create_subscriber(email, tag_ids, custom_fields)
    uri = URI("#{BASE_URL}/subscribers")

    # Create subscriber with email and custom fields using Kit's documented structure
    payload = {
      email_address: email
    }

    # Add custom field(s) using field labels as keys (Kit's v4 API format)
    if custom_fields.any?
      payload[:fields] = {}
      custom_fields.each do |field_label, field_config|
        # For new subscribers, just use the value directly (no appending needed)
        normalized_key = normalize_field_key(field_label)
        payload[:fields][normalized_key] = field_config[:value]
      end
    end

    Rails.logger.info "Creating subscriber with payload: #{payload.to_json}"
    response = make_request(uri, :post, payload)

    unless response.code == "201"
      Rails.logger.error "Create subscriber response: #{response.code} - #{response.body}"
      raise "Failed to create subscriber: #{response.body}"
    end

    Rails.logger.info "Create subscriber response: #{response.code} - #{response.body}"

    subscriber_data = JSON.parse(response.body)
    subscriber_id = subscriber_data["subscriber"]["id"]

    # Now add tags separately (this is working)
    if tag_ids.any?
      tag_ids.each do |tag_id|
        subscribe_to_tag(subscriber_id, tag_id, email)
      end
    end

    subscriber_data
  end

  def update_subscriber(subscriber, tag_ids, custom_fields, email)
    subscriber_id = subscriber["id"]

    # Subscribe to tags if provided
    if tag_ids.any?
      tag_ids.each do |tag_id|
        subscribe_to_tag(subscriber_id, tag_id, email)
      end
    end

    # For existing subscribers, handle field appending logic
    if custom_fields.any?
      update_custom_fields(subscriber_id, custom_fields, subscriber)
    end
  end

  def subscribe_to_tag(subscriber_id, tag_id, email = nil)
    uri = URI("#{BASE_URL}/tags/#{tag_id}/subscribers")

    # Try with email_address if we have it, otherwise use id
    payload = if email
      { email_address: email }
    else
      { id: subscriber_id }
    end

    response = make_request(uri, :post, payload)

    unless [ "200", "201" ].include?(response.code)
      Rails.logger.warn "Failed to subscribe to tag #{tag_id}: #{response.body}"
    end
  end

  def update_custom_fields(subscriber_id, custom_fields, existing_subscriber = nil)
    uri = URI("#{BASE_URL}/subscribers/#{subscriber_id}")

    # Build fields object using field labels as keys
    fields_to_update = {}

    custom_fields.each do |field_label, field_config|
      new_value = field_config[:value]
      append_mode = field_config[:append] || false
      normalized_key = normalize_field_key(field_label)

      if append_mode && existing_subscriber
        # Get current value from existing subscriber using normalized key
        current_value = existing_subscriber.dig("fields", normalized_key) || ""

        # Parse current value as comma-separated array
        current_array = current_value.split(",").map(&:strip).reject(&:empty?)

        # Add new value if not already present
        unless current_array.include?(new_value)
          current_array << new_value
        end

        # Join back as comma-separated string
        fields_to_update[normalized_key] = current_array.join(", ")
      else
        # Overwrite mode or new subscriber
        fields_to_update[normalized_key] = new_value
      end
    end

    # Use Kit's documented payload structure
    payload = {
      fields: fields_to_update
    }

    Rails.logger.info "Updating custom fields for subscriber #{subscriber_id}: #{payload.to_json}"
    response = make_request(uri, :put, payload)

    if response.code == "200"
      Rails.logger.info "Successfully updated custom fields"
    else
      Rails.logger.warn "Failed to update custom fields: #{response.body}"
    end
  end

  def make_request(uri, method, payload = nil)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    case method
    when :get
      request = Net::HTTP::Get.new(uri)
    when :post
      request = Net::HTTP::Post.new(uri)
    when :put
      request = Net::HTTP::Put.new(uri)
    when :patch
      request = Net::HTTP::Patch.new(uri)
    end

    request["X-Kit-Api-Key"] = @api_key
    request["Content-Type"] = "application/json"

    if payload
      request.body = payload.to_json
    end

    http.request(request)
  end

  def normalize_field_key(field_name)
    # Convert to lowercase, replace spaces with underscores, remove special characters
    # Keep only letters, numbers, and underscores
    field_name.to_s.downcase.gsub(/\s+/, "_").gsub(/[^a-z0-9_]/, "")
  end
end
