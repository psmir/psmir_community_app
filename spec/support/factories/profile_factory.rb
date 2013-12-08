FactoryGirl.define do
  factory :profile do
    name { Faker::Name.name }
    gender { ['male', 'female'].sample }
    birthday { Date.today - (rand(10) + 20).years }
    info { Faker::Lorem.sentences(3) }
    interest_list { Faker::Lorem.words(5) }
  end
end
