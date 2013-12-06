FactoryGirl.define do
  factory :user, aliases: [:sender, :recipient] do
    sequence(:username) { |n| "user#{n}" }
    sequence(:email) { |n| "user#{n}@woopy.no" }
    password "password"
    password_confirmation "password"
  end
end
