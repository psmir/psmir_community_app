FactoryGirl.define do
  factory :profile do
    name 'Real name'
    gender 'male'
    birthday Date.civil(1990, 03, 15)
    info 'Some information'
    interest_list 'interest1, interest2'
    association :user
  end
end
