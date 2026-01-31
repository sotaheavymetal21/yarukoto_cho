# frozen_string_literal: true

OmniAuth.config.test_mode = true

module OmniAuthHelpers
  def mock_google_oauth2(email: "test@example.com", name: "Test User", uid: "123456", email_verified: true)
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: uid,
      info: {
        email: email,
        name: name,
        image: "https://example.com/avatar.jpg"
      },
      extra: {
        raw_info: {
          email_verified: email_verified
        }
      }
    )
  end

  def mock_github_oauth(email: "test@example.com", name: "Test User", uid: "654321")
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
      provider: "github",
      uid: uid,
      info: {
        email: email,
        name: name,
        image: "https://example.com/avatar.jpg"
      }
    )
  end

  def mock_oauth_failure(provider, error_type = :invalid_credentials)
    OmniAuth.config.mock_auth[provider] = error_type
  end

  def reset_omniauth_mocks
    OmniAuth.config.mock_auth[:google_oauth2] = nil
    OmniAuth.config.mock_auth[:github] = nil
  end
end

RSpec.configure do |config|
  config.include OmniAuthHelpers

  config.before(:each) do
    OmniAuth.config.mock_auth[:google_oauth2] = nil
    OmniAuth.config.mock_auth[:github] = nil
  end
end
