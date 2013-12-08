FactoryGirl.define do
  factory :message do
    title { Faker::Lorem.sentence(10) }
    message { Faker::Lorem.sentences(3).join(" ") }
    association :sender, factory: :user
    association :recipient, factory: :user
  end
end
