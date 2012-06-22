Factory.define :message do |message|
  message.sequence(:title) { |n| "title#{n}" }
  message.sequence(:message) { |n| "message#{n}" }
end
