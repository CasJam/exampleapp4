class ContactMailer < ApplicationMailer
  def contact_form_email(name:, email:, subject:, message:, page_url:)
    @name = name
    @email = email
    @subject = subject
    @message = message
    @page_url = page_url
    @app_name = Rails.application.class.module_parent_name

    # Find first admin user or use default
    admin_email = "admin@example.com"

    # Set up email
    mail(
      to: admin_email,
      reply_to: email,
      subject: t("contact_form.mailer.subject", app_name: @app_name, subject: subject, default: "[#{@app_name} Contact] #{subject}")
    )
  end
end
