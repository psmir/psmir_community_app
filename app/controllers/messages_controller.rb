class MessagesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_message, :only => [:show, :destroy]  
  before_filter :recipient, :only => [:show]

  def index
    @messages = current_user.incoming_messages.order('created_at desc').page params[:page] 
  end
  
  def new
    @message = Message.new
  end
  
  def create
    @message = Message.new(params[:message])
    @message.sender = current_user

    if @message.save
      flash[:notice] = 'The message has been sent'
      redirect_to messages_path
    else
      flash[:alert] = 'The message has not been sent'
      render :action => 'new'
    end
  end
  
  def show
    
  end
  
  def destroy
    @message.destroy
    redirect_to messages_path
  end

private 

  def find_message
    @message = Message.find params[:id]
    if @message.nil?
      flash[:alert] = 'The message was not found'
      redirect_to messages_path
    end
  end

  def recipient
    if current_user != @message.recipient
      redirect_to messages_path
    end
  end
 
end
