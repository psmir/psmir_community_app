module SeedHelpers
  def create_user!(attributes={})
    user = FactoryGirl.build(:user, attributes)
    user.save
    user.confirm!
    Factory(:profile, :user_id => user.id)
    user
  end
  
end

RSpec.configure do |config|
  config.include SeedHelpers
end

