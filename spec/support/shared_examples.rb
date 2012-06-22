  shared_context 'authenticated user' do
    before do
      controller.stub :authenticate_user!
      @current_user = stub_model(User)
      controller.stub(:current_user).and_return @current_user
      controller.stub(:user_signed_in?).and_return true
    end
  end  


  shared_examples 'requiring authentication' do
    it 'authenticates the user' do
      controller.should_receive :authenticate_user!
      do_request
    end
  end

  shared_examples 'handler of a wrong user_id' do 
    context 'with a wrong user id' do
      before do
        User.stub(:fetch).with('1').and_return nil
        do_request
      end

      it 'redirects to the root page' do
        response.should redirect_to root_path
      end

      it 'informs that the user was not found' do
        flash[:alert].should == 'The user was not found'
      end
    end
  end

  shared_examples 'handler of a wrong article_id' do
    context 'with a wrong article id' do
      before do
        Article.stub(:fetch).with('1').and_return nil
        Article.stub(:find).with('1').and_return nil
        do_request
      end

      it 'redirects to the root page' do
        response.should redirect_to root_path
      end      

      it 'displays a message that article was not found' do
        flash[:alert].should == 'The article was not found'
      end
    end
  end
