require 'spec_helper'

describe UsersController do

  shared_context '#follow/#unfollow common context' do
    include_context 'authenticated user'   
 
    before do
      User.stub(:find).with('1').and_return @blogger = stub('blogger')
    end
  end

  shared_examples 'wrong blogger id handler' do 

    before do
      User.should_receive(:find).with('1').and_return nil
      do_request
    end

    it 'sets a message that the blogger was not found' do
      flash[:alert].should == 'The user was not found'
    end

    it 'redirects to the root' do
      response.should redirect_to root_path
    end
  end

  describe 'POST #follow' do
    include_context '#follow/#unfollow common context'
    before do
      @current_user.stub(:follow)
    end
 
    def do_request(args = {})
      post :follow, { id: 1 }.merge(args)
    end

    it_behaves_like 'requiring authentication'

    it 'finds the blogger' do
      do_request
      assigns[:blogger].should == @blogger
    end

    it "adds the blogger to user's list of favorite bloggers" do
      @current_user.should_receive(:follow).with(@blogger)
      do_request
    end
  
    it "redirects to the blogger's blog" do
      do_request
      response.should redirect_to user_articles_path(@blogger)
    end

    it_behaves_like 'wrong blogger id handler'
  end

  describe 'POST #unfollow' do
    include_context '#follow/#unfollow common context'
    before do
      @current_user.stub(:unfollow)
    end

    def do_request(args = {})
      post :unfollow, { id: 1 }.merge(args)
    end

    it_behaves_like 'requiring authentication'

    it 'finds the blogger' do
      do_request
      assigns[:blogger].should == @blogger
    end

    it "adds the blogger to the user's list of favorite bloggers" do
      @current_user.should_receive(:unfollow).with(@blogger)
      do_request
    end
  
    it "redirects to the blogger's blog" do
      do_request
      response.should redirect_to user_articles_path(@blogger)
    end

    it_behaves_like 'wrong blogger id handler'
  end

end
