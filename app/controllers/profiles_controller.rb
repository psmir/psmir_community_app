class ProfilesController < ApplicationController
  before_filter :authenticate_user!, except: [:show, :avatar]
  before_filter :find_user, only: [:show]
  before_filter :find_profile, only: [:show]
  before_filter :find_current_user_profile, only: [:edit, :update]
  helper_method :favorite_bloggers

  def show
  end

  def edit
  end

  def update
    if @profile.update_attributes params[:profile]
      flash[:notice] = 'The profile has been updated'
      redirect_to profile_path
    else
      flash[:alert] = 'The profile has not been updated'
      render :action => 'edit'
    end
  end

  def avatar
    @profile = Profile.find(params[:id])
    @avatar = @profile.get_avatar_file params[:style]
    send_data(@avatar, :type => @profile.avatar_content_type, :disposition => 'inline')
  end

  private

  def find_user
    @user = User.find(params[:user_id]) if params[:user_id]
    @user ||= current_user
    redirect_to new_user_session_path unless @user
  end

  def find_profile
    @profile = @user.profile
  end

  def find_current_user_profile
    @profile = current_user.profile
  end

  def favorite_bloggers
    @favorite_bloggers ||= @user.bloggers.page params[:page]
  end
end
