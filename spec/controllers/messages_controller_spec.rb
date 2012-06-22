require 'spec_helper'

describe MessagesController do

  shared_examples 'handler of a wrong message id' do
    context 'when the wrong message id is received' do
      before do
        Message.stub(:find).with('1').and_return nil
        do_request
      end
  
      it 'sets a warning that the message was not found' do
        flash[:alert].should == 'The message was not found'
      end

      it 'redirects to the page with incoming messages' do
        response.should redirect_to messages_path
      end
    end
  end

  shared_examples 'requiring the current user to be the recipient of the message' do
    context 'when the current user is not the recipient of the message' do
      before do
        @message.stub(:recipient).and_return(mock_model(User))
        do_request
      end

      it 'redirects to the page with incoming messages' do
        response.should redirect_to messages_path
      end
    end
  end

  describe 'GET #index' do
    include_context 'authenticated user'

    before do
      @messages = stub('messages').as_null_object
      @current_user.stub_chain(:incoming_messages, :order).with('created_at desc').and_return @messages
    end

    def do_request(args = {})
      get :index, args
    end

    it_behaves_like 'requiring authentication'

    it 'finds the incoming messages' do
      do_request
      assigns[:messages].should == @messages
    end

    it 'paginates the messages' do
      @messages.stub(:page).with('1').and_return messages = stub('paginated messages')
      do_request page: 1
      assigns[:messages].should == messages
    end
   
  end

  describe 'GET #new' do
    include_context 'authenticated user'

    def do_request(args = {})
      get :new, args
    end

    it_behaves_like 'requiring authentication'

    it 'creates a new message' do
      do_request
      assigns[:message].should be_instance_of Message
    end

    it 'renders the :new template' do
      do_request
      response.should render_template :new
    end
  end

  describe 'POST #create' do
    include_context 'authenticated user'

    before do
      @message = stub_model(Message)
      Message.stub(:new).with('params').and_return @message
    end

    def do_request(args = {})
      post :create, { message: 'params'}.merge(args)
    end

   it_behaves_like 'requiring authentication'
 
    it 'creates a new message and assigns it to the @message' do
      do_request
      assigns[:message].should == @message
    end

    it 'sets the message sender to the current user' do
      @message.should_receive(:sender=).with(@current_user)
      do_request
    end
  
    context 'save with valid attributes' do
      before do
        @message.stub(:save).and_return true
        do_request
      end
      
      it 'sets a notice that the message has been sent' do
        flash[:notice].should == 'The message has been sent'
      end
      
      it 'redirects to the page with incoming messages' do
        response.should redirect_to messages_path
      end
    end

    context 'save with invalid attributes' do
      before do
        @message.stub(:save).and_return false
        do_request
      end
      
      it 'sets a warning that the message has been sent' do
        flash[:alert].should == 'The message has not been sent'
      end
      
      it 'renders the :new template' do
        response.should render_template :new
      end
    end
  end

  describe 'GET #show' do
    include_context 'authenticated user'

    before do
      Message.stub(:find).with('1').and_return @message = stub_model(Message, recipient: @current_user)
    end

    def do_request(args = {})
      get :show, { id: 1 }.merge(args)
    end
  
    it_behaves_like 'requiring authentication'

    it 'finds the message' do
      do_request
      assigns[:message].should == @message
    end

    it_behaves_like 'handler of a wrong message id'
    it_behaves_like 'requiring the current user to be the recipient of the message'

    it 'renders the :show template' do
      do_request
      response.should render_template :show
    end

  end

  describe 'DELETE #destroy' do
    include_context 'authenticated user'

    before do
      controller.stub :render
      Message.stub(:find).with('1').and_return @message = stub_model(Message, user: @current_user) 
      @message.stub :destroy
    end
    
    def do_request(args = {})
      delete :destroy, { id: 1 }.merge(args)
    end

    it_behaves_like 'requiring authentication'

    it 'finds the message' do
      do_request
      assigns[:message].should == @message
    end

    it_behaves_like 'handler of a wrong message id'
    it_behaves_like 'requiring the current user to be the recipient of the message'    

    it 'deletes the message' do
      @message.should_receive :destroy
      do_request
    end
    
    it 'redirects to the page with incoming messages' do
      do_request
      response.should redirect_to messages_path
    end
  end
  
end
