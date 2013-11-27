FactoryGirl.define  do
  factory :article do
    sequence(:title) { |n| "title#{n}" }
    sequence(:content) { |n| "content#{n}" }
    association :user
  end
end
