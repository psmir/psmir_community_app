require 'spec_helper'

describe ProfilesController do

  shared_examples 'profile fetching' do
    it 'fetches the profile to the @profile' do
      do_request
      assigns[:profile].should == @profile
    end

    context 'with wrong profile id' do
      before do
        Profile.stub(:fetch).and_return nil
        Profile.stub(:find).and_return nil
        do_request
      end

      it 'sets a message that the profile was not found' do
        flash[:alert].should == 'The profile was not found'
      end

      it 'redirects to the root page' do
        response.should redirect_to root_path
      end
    end
  end

  shared_examples 'accessible for an owner of the profile only' do
    context 'when current user is not the owner of the profile' do
      before do
        Profile.stub(:fetch).with('1').and_return @profile = stub_model(Profile, user: mock_model(User))
        Profile.stub(:find).with('1').and_return @profile = stub_model(Profile, user: mock_model(User))
        do_request
      end

      it 'sets a message that the user is not allowed to do so' do
        flash[:alert].should == 'You are not allowed to do so'
      end

      it 'redirects to the root page' do
        response.should redirect_to root_path
      end
    end
  end

  describe 'GET #show' do
    before do
      Profile.stub(:find).with('1').and_return @profile = stub('profile').as_null_object
    end

    def do_request(args = {})
      get :show, { id: 1 }.merge(args)
    end

    it 'renders :show template' do
      do_request
      response.should render_template :show
    end

    it_behaves_like 'profile fetching'

    it 'finds the list of favorite bloggers and paginates it' do
      @favorite_bloggers = stub('favorite bloggers')
      @profile.stub_chain(:user, :bloggers, :page).with('1').and_return @favorite_bloggers
      do_request page: 1
      assigns[:favorite_bloggers].should == @favorite_bloggers
    end

  end

  describe 'GET #edit' do
    include_context 'authenticated user'
    before do
      Profile.stub(:find).with('1').and_return @profile = stub_model(Profile, user: @current_user)
    end

    def do_request(args = {})
      get :edit, { id: 1 }.merge(args)
    end

    it_behaves_like 'requiring authentication'
    it_behaves_like 'profile fetching'
    it_behaves_like 'accessible for an owner of the profile only'
    it 'renders the edit template' do
      do_request
      response.should render_template :edit
    end
  end

  describe 'PUT #update' do
    include_context 'authenticated user'
    before do
      Profile.stub(:find).with('1').and_return @profile = stub_model(Profile, user: @current_user)
    end

    def do_request(args = {})
      put :update, { id: 1 }.merge(args)
    end

    it_behaves_like 'requiring authentication'
    it_behaves_like 'profile fetching'
    it_behaves_like 'accessible for an owner of the profile only'

    it 'updates the profile' do
      @profile.should_receive(:update_attributes).with('params')
      do_request profile: 'params'
    end

    context 'with valid params' do
      before do
        @profile.stub(:update_attributes).with('params').and_return true
        do_request profile: 'params'
      end

      it 'sets a message that the profile was saved' do
        flash[:notice].should == 'The profile has been updated'
      end

      it 'redirects to the profile page' do
        response.should redirect_to profile_path(@profile)
      end

    end

    context 'with invalid params' do
      before do
        @profile.stub(:update_attributes).with('params').and_return false
        do_request profile: 'params'
      end

      it 'sets a message that the profile was not saved' do
        flash[:alert].should == 'The profile has not been updated'
      end

      it 'renders the edit template' do
        response.should render_template :edit
      end
    end
  end

  describe 'GET #avatar' do
    before do
      @profile = mock_model(Profile).as_null_object
      Profile.stub(:find).with('1').and_return @profile
    end

    def do_request(args = {})
      get :avatar, { id: 1, style: 'style' }.merge(args)
    end

    it_behaves_like 'profile fetching'

    it 'should send the avatar' do
      @profile.stub(:get_avatar_file).with('style').and_return 'avatar_file'
      @profile.stub(:avatar_content_type).and_return 'content_type'
      controller.stub :render
      controller.should_receive(:send_data).with('avatar_file', type: 'content_type', disposition: 'inline' )
      do_request
    end
  end
end
