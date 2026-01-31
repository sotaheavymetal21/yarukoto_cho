# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_before_action :verify_authenticity_token, only: [:google_oauth2, :github]

    def google_oauth2
      handle_oauth("Google")
    end

    def github
      handle_oauth("GitHub")
    end

    def failure
      redirect_to root_path, alert: t("devise.omniauth_callbacks.failure", reason: failure_message)
    end

    private

    def handle_oauth(provider_name)
      @user = User.from_omniauth(request.env["omniauth.auth"])

      if @user.nil?
        redirect_to new_user_registration_url, alert: t("devise.omniauth_callbacks.invalid_credentials")
        return
      end

      if @user.persisted?
        flash[:notice] = t("devise.omniauth_callbacks.success", kind: provider_name)
        sign_in_and_redirect @user, event: :authentication
      else
        session["devise.oauth_data"] = request.env["omniauth.auth"].except(:extra)
        redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
      end
    end

    def failure_message
      exception = request.env["omniauth.error"]
      error_type = request.env["omniauth.error.type"]

      if exception
        Rails.logger.error("OmniAuth failure: #{exception.class} - #{exception.message}")
      end

      I18n.t("devise.omniauth_callbacks.#{error_type}", default: error_type.to_s.humanize)
    end
  end
end
