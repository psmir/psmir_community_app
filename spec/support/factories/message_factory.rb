FactoryGirl.define do
  factory :message do
    sequence(:title) { |n| "title#{n}" }
    sequence(:message) { |n| "message#{n}" }
    association :sender, factory: :user
    association :recipient, factory: :user
  end
end
