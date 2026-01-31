# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    password { "password123" }
    password_confirmation { "password123" }
    confirmed_at { Time.current }

    trait :unconfirmed do
      confirmed_at { nil }
    end

    trait :with_google_oauth do
      provider { "google_oauth2" }
      uid { Faker::Number.unique.number(digits: 10).to_s }
    end

    trait :with_github_oauth do
      provider { "github" }
      uid { Faker::Number.unique.number(digits: 10).to_s }
    end

    trait :with_avatar do
      avatar { Faker::Avatar.image }
    end
  end
end
