class ApplicationController < ActionController::Base
  include ApplicationHelper

  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern

  def authorize_account_admin_user
    return unless @account.present?

    unless current_user.account_admin?(@account)
      redirect_to root_path, alert: t("teams.authorization.not_authorized", default: "You are not authorized to access this page.")
    end
  end

  def authorize_account_user
    return unless @account.present?

    unless current_user.account_user?(@account)
      redirect_to root_path, alert: t("teams.authorization.not_authorized", default: "You are not authorized to access this page.")
    end
  end


  def authorize_admin_user
    unless current_user&.admin? || impersonating?
      redirect_to root_path, alert: t("admin.common.unauthorized", default: "You are not authorized to access this page.")
    end
  end

end
