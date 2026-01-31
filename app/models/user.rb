# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :trackable,
         :omniauthable, omniauth_providers: [:google_oauth2, :github]

  has_many :organization_memberships, dependent: :destroy
  has_many :organizations, through: :organization_memberships
  has_many :project_members, dependent: :destroy
  has_many :projects, through: :project_members
  has_many :assigned_tasks, class_name: "TaskAssignment", dependent: :destroy
  has_many :tasks, through: :assigned_tasks
  has_many :comments, dependent: :destroy
  has_many :activities, dependent: :destroy
  has_many :notifications, dependent: :destroy

  has_one_attached :avatar_image

  validates :name, presence: true, length: { maximum: 100 }

  # Finds or creates a user from OmniAuth authentication data.
  #
  # @param auth [OmniAuth::AuthHash] The authentication hash from OmniAuth
  # @return [User, nil] The found or created user, or nil if authentication data is invalid
  # @raise [ActiveRecord::RecordInvalid] If user creation fails due to validation errors
  #
  # @example
  #   user = User.from_omniauth(request.env['omniauth.auth'])
  #
  def self.from_omniauth(auth)
    return nil unless auth&.provider.present? && auth&.uid.present?

    email = auth.info&.email
    return nil unless email.present? && email.match?(URI::MailTo::EMAIL_REGEXP)

    name = auth.info&.name.presence || email.split("@").first

    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = email
      user.password = Devise.friendly_token[0, 20]
      user.name = name
      user.avatar = auth.info&.image

      # Skip confirmation only for providers that verify email
      if email_verified_by_provider?(auth)
        user.skip_confirmation!
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("OmniAuth user creation failed: #{e.message}")
    nil
  end

  # Checks if the user is an admin of the given organization.
  #
  # @param organization [Organization] The organization to check
  # @return [Boolean] true if the user is an admin of the organization
  def admin_of?(organization)
    organization_memberships.exists?(organization: organization, role: :admin)
  end

  # Checks if the user is a member of the given organization.
  #
  # @param organization [Organization] The organization to check
  # @return [Boolean] true if the user is a member of the organization
  def member_of?(organization)
    organizations.exists?(id: organization.id)
  end

  private_class_method def self.email_verified_by_provider?(auth)
    provider = auth.provider.to_s

    case provider
    when "google_oauth2"
      auth.extra&.raw_info&.email_verified == true ||
        auth.extra&.raw_info&.email_verified == "true"
    when "github"
      # GitHub only returns the primary email if it's verified
      auth.info&.email.present?
    else
      false
    end
  end
end
