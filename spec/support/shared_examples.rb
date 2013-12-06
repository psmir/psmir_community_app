  shared_context 'authenticated user' do
    before do
      controller.stub :authenticate_user!
      @current_user = stub_model(User)
      controller.stub(:current_user).and_return @current_user
      controller.stub(:user_signed_in?).and_return true
    end
  end

  shared_context 'set up the ability' do
    before do
      @ability = Object.new
      @ability.extend CanCan::Ability
      @controller.stub(:current_ability).and_return @ability
    end
  end


  shared_examples 'requiring authentication' do
    it 'authenticates the user' do
      controller.should_receive :authenticate_user!
      do_request
    end
  end

  shared_examples 'requiring authorization' do
    it 'authorize the user' do
      controller.should_receive :authorize!
      do_request
    end
  end
