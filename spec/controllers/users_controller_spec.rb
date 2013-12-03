require 'spec_helper'

describe UsersController do

  include_context 'authenticated user'

  before do
    User.stub(:find).with('1').and_return @blogger = stub('blogger')
  end


  describe '#follow' do

    before do
      @current_user.should_receive(:follow).with @blogger
      post :follow, id: 1
    end

    it { should redirect_to user_articles_path(@blogger) }
  end

  describe '#unfollow' do

    before do
      @current_user.should_receive(:unfollow).with @blogger
      post :unfollow, id: 1
    end

    it { should redirect_to user_articles_path(@blogger) }
  end
end
