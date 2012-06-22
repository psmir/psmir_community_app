Factory.define :user do |user|
  user.sequence(:username) { |n| "user#{n}" }
  user.sequence(:email) { |n| "user#{n}@woopy.no" }
  user.password "password"
  user.password_confirmation "password"
end
