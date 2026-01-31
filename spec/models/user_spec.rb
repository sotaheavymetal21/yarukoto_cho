# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(100) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  end

  describe "associations" do
    it { is_expected.to have_many(:organization_memberships).dependent(:destroy) }
    it { is_expected.to have_many(:organizations).through(:organization_memberships) }
    it { is_expected.to have_many(:project_members).dependent(:destroy) }
    it { is_expected.to have_many(:projects).through(:project_members) }
    it { is_expected.to have_many(:assigned_tasks).class_name("TaskAssignment").dependent(:destroy) }
    it { is_expected.to have_many(:tasks).through(:assigned_tasks) }
    it { is_expected.to have_many(:comments).dependent(:destroy) }
    it { is_expected.to have_many(:activities).dependent(:destroy) }
    it { is_expected.to have_many(:notifications).dependent(:destroy) }
  end

  describe ".from_omniauth" do
    let(:google_auth) do
      OmniAuth::AuthHash.new(
        provider: "google_oauth2",
        uid: "123456",
        info: {
          email: "test@example.com",
          name: "Test User",
          image: "https://example.com/avatar.jpg"
        },
        extra: {
          raw_info: {
            email_verified: true
          }
        }
      )
    end

    let(:github_auth) do
      OmniAuth::AuthHash.new(
        provider: "github",
        uid: "654321",
        info: {
          email: "github@example.com",
          name: "GitHub User",
          image: "https://example.com/github-avatar.jpg"
        }
      )
    end

    context "with valid Google OAuth data" do
      it "creates a new user" do
        expect { described_class.from_omniauth(google_auth) }.to change(described_class, :count).by(1)
      end

      it "sets the correct attributes" do
        user = described_class.from_omniauth(google_auth)

        expect(user.email).to eq("test@example.com")
        expect(user.name).to eq("Test User")
        expect(user.provider).to eq("google_oauth2")
        expect(user.uid).to eq("123456")
      end

      it "confirms the user when email is verified" do
        user = described_class.from_omniauth(google_auth)

        expect(user).to be_confirmed
      end

      it "returns existing user on subsequent calls" do
        first_user = described_class.from_omniauth(google_auth)
        second_user = described_class.from_omniauth(google_auth)

        expect(first_user.id).to eq(second_user.id)
      end
    end

    context "with valid GitHub OAuth data" do
      it "creates a new user" do
        expect { described_class.from_omniauth(github_auth) }.to change(described_class, :count).by(1)
      end

      it "confirms the user when email is present" do
        user = described_class.from_omniauth(github_auth)

        expect(user).to be_confirmed
      end
    end

    context "with invalid OAuth data" do
      it "returns nil when auth is nil" do
        expect(described_class.from_omniauth(nil)).to be_nil
      end

      it "returns nil when provider is missing" do
        invalid_auth = OmniAuth::AuthHash.new(uid: "123", info: { email: "test@example.com" })

        expect(described_class.from_omniauth(invalid_auth)).to be_nil
      end

      it "returns nil when uid is missing" do
        invalid_auth = OmniAuth::AuthHash.new(provider: "google_oauth2", info: { email: "test@example.com" })

        expect(described_class.from_omniauth(invalid_auth)).to be_nil
      end

      it "returns nil when email is missing" do
        invalid_auth = OmniAuth::AuthHash.new(
          provider: "google_oauth2",
          uid: "123",
          info: { name: "Test User" }
        )

        expect(described_class.from_omniauth(invalid_auth)).to be_nil
      end

      it "returns nil when email is invalid" do
        invalid_auth = OmniAuth::AuthHash.new(
          provider: "google_oauth2",
          uid: "123",
          info: { email: "invalid-email", name: "Test User" }
        )

        expect(described_class.from_omniauth(invalid_auth)).to be_nil
      end
    end

    context "when email is not verified by provider" do
      let(:unverified_auth) do
        OmniAuth::AuthHash.new(
          provider: "google_oauth2",
          uid: "789",
          info: {
            email: "unverified@example.com",
            name: "Unverified User"
          },
          extra: {
            raw_info: {
              email_verified: false
            }
          }
        )
      end

      it "creates unconfirmed user" do
        user = described_class.from_omniauth(unverified_auth)

        expect(user).not_to be_confirmed
      end
    end

    context "when name is missing" do
      let(:auth_without_name) do
        OmniAuth::AuthHash.new(
          provider: "google_oauth2",
          uid: "999",
          info: {
            email: "noname@example.com"
          },
          extra: {
            raw_info: {
              email_verified: true
            }
          }
        )
      end

      it "uses email prefix as name" do
        user = described_class.from_omniauth(auth_without_name)

        expect(user.name).to eq("noname")
      end
    end
  end

  describe "#admin_of?", pending: "Organization model not yet created" do
    let(:user) { create(:user) }
    let(:organization) { create(:organization) }

    context "when user is an admin" do
      before do
        create(:organization_membership, user: user, organization: organization, role: :admin)
      end

      it "returns true" do
        expect(user.admin_of?(organization)).to be true
      end
    end

    context "when user is a member but not admin" do
      before do
        create(:organization_membership, user: user, organization: organization, role: :member)
      end

      it "returns false" do
        expect(user.admin_of?(organization)).to be false
      end
    end

    context "when user is not a member" do
      it "returns false" do
        expect(user.admin_of?(organization)).to be false
      end
    end
  end

  describe "#member_of?", pending: "Organization model not yet created" do
    let(:user) { create(:user) }
    let(:organization) { create(:organization) }

    context "when user is a member" do
      before do
        create(:organization_membership, user: user, organization: organization)
      end

      it "returns true" do
        expect(user.member_of?(organization)).to be true
      end
    end

    context "when user is not a member" do
      it "returns false" do
        expect(user.member_of?(organization)).to be false
      end
    end
  end
end
