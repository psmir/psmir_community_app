FactoryGirl.define do
  factory :user, aliases: [:sender, :recipient] do
    username { Faker::Internet.user_name }
    email { Faker::Internet.email }
    association :profile
    confirmed_at { (rand(10) + 20).days.ago }
    password "password"
    password_confirmation "password"

    trait :admin do
      admin true
    end
  end
end
