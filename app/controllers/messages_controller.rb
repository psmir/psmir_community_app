class MessagesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def index
    @messages = @messages.by_newest.page(params[:page])
  end

  def new
  end

  def create
    if @message.save
      flash[:notice] = 'The message has been sent'
      redirect_to messages_path
    else
      flash[:alert] = 'The message has not been sent'
      render action: 'new'
    end
  end

  def show
  end

  def destroy
    @message.destroy
    redirect_to messages_path
  end
end
