require 'spec_helper'

describe MessagesController do
  include_context 'set up the ability'

  describe '#index' do
    include_context 'authenticated user'

    before do
      @ability.can :read, Message
      controller.instance_variable_set(:@messages, Message)
      Message.should_receive(:by_newest).and_return @messages
      @messages.should_receive(:page).with('1').and_return @messages
      get :index, page: 1
    end

    it { should assign_to(:messages).with @messages }
  end

  describe '#new' do

    include_context 'authenticated user'

    before do
      @ability.can :create, Message, sender_id: @current_user.id
      get :new
    end

    it { assigns[:message].should be_instance_of Message }
    it { assigns[:message].sender_id.should == @current_user.id }
    it { should render_template :new }
  end

  describe '#create' do
    include_context 'authenticated user'

    before do
      @ability.can :create, Message, sender_id: @current_user.id
    end

    context 'save with valid attributes' do
      before do
        Message.any_instance.stub(:save).and_return true
        post :create
      end

      it { flash[:notice].should == 'The message has been sent' }
      it { should redirect_to messages_path }
    end

    context 'save with invalid attributes' do
      before do
        Message.any_instance.stub(:save).and_return false
        post :create, message: {}
      end

      it { flash[:alert].should == 'The message has not been sent' }
      it { should render_template :new }
    end
  end

  describe '#show' do
    include_context 'authenticated user'

    before do
      @ability.can :read, Message, recipient_id: @current_user.id
      Message.stub(:find).with('1').and_return @message = stub_model(Message, recipient: @current_user)
      get :show, id: 1
    end

    it { should assign_to(:message).with @message }
    it { should render_template :show }

  end

  describe '#destroy' do
    include_context 'authenticated user'

    before do
      @ability.can :destroy, Message, recipient_id: @current_user.id
      Message.stub(:find).with('1').and_return @message = stub_model(Message, recipient: @current_user)
      @message.should_receive :destroy
      delete :destroy, id: 1
    end

    it { should redirect_to messages_path }
  end
end
