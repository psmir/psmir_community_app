module SeedHelpers
  def create_user!(attributes={})
    user = FactoryGirl.build(:user, attributes)
    user.save
    user.confirm!
    FactoryGirl.create(:profile, :user => user)
    user
  end

end

RSpec.configure do |config|
  config.include SeedHelpers
end

