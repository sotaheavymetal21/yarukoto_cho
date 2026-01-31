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

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name
      user.avatar = auth.info.image
      user.skip_confirmation!
    end
  end

  def admin_of?(organization)
    organization_memberships.exists?(organization: organization, role: :admin)
  end

  def member_of?(organization)
    organizations.exists?(id: organization.id)
  end
end
