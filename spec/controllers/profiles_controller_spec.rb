require 'spec_helper'

describe ProfilesController do

  shared_examples 'find user' do
    context 'with user_id' do
      before do
        User.stub(:find).with('1').and_return @user = stub_model(User)
        do_request(user_id: 1)
      end

      it { should assign_to(:user).with @user }
    end

    context 'without user_id' do
      context 'unsignded in user' do
        before { do_request }

        it { should redirect_to new_user_session_path }
      end

      context 'signed in user' do
        include_context 'authenticated user'

        before { do_request }

        it { should assign_to(:user).with @current_user }
      end
    end
  end

  shared_examples 'find profile' do
    it 'finds the profile' do
      profile = stub_model(Profile)
      user = stub_model(User)
      user.stub(:profile).and_return profile
      User.stub(:find).with('1').and_return user

      do_request(user_id: 1)

      assigns[:profile].should == profile
    end
  end

  describe 'GET #show' do
    def do_request(args={})
      get :show, args
    end

    it_behaves_like 'find user'
    it_behaves_like 'find profile'

  end

  describe 'GET #edit' do
    include_context 'authenticated user'

    before do
      @current_user.stub(:profile).and_return @profile = stub_model(Profile)
      get :edit
    end

    it { should assign_to(:profile).with @profile }

  end

  describe 'PUT #update' do
    include_context 'authenticated user'
    before do
      @current_user.stub(:profile).and_return @profile = stub_model(Profile)
    end


    context 'with valid params' do
      before do
        @profile.should_receive(:update_attributes).with('params').and_return true
        put :update, profile: 'params'
      end

      it { flash[:notice].should == 'The profile has been updated' }
      it { should redirect_to profile_path }

    end

    context 'with invalid params' do
      before do
        @profile.should_receive(:update_attributes).with('params').and_return false
        put :update, profile: 'params'
      end

      it { flash[:alert].should == 'The profile has not been updated' }
      it { should render_template :edit }

    end
  end

  describe 'GET #avatar' do
    before do
      @profile = mock_model(Profile).as_null_object
      Profile.stub(:find).with('1').and_return @profile
    end

    it 'fetches the profile to the @profile' do
      get :avatar, id: 1, style: 'style'
      assigns[:profile].should == @profile
    end

    it 'should send the avatar' do
      @profile.stub(:get_avatar_file).with('style').and_return 'avatar_file'
      @profile.stub(:avatar_content_type).and_return 'content_type'
      controller.stub :render
      controller.should_receive(:send_data).with('avatar_file', type: 'content_type', disposition: 'inline' )
      get :avatar, { id: 1, style: 'style' }
    end
  end
end
